-- ============================================================================
-- Gruppen für alle (Wunsch 26.11.): Jedes Konto darf Haushalte/Gruppen anlegen,
-- und Einladungen können als Mit-Owner gelten (z. B. Eltern mit denselben
-- Rechten wie Magnus). Rein additiv zu 20261126000001.
-- ============================================================================

alter table public.invitations
  add column role public.household_role not null default 'member';

-- Jedes Konto, höchstens 20 Mitgliedschaften (gegen Missbrauch)
create or replace function public.create_household(p_name text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_id uuid;
begin
  if v_uid is null then raise exception 'not authenticated' using errcode = '42501'; end if;
  if (select count(*) from public.household_members where user_id = v_uid) >= 20 then
    raise exception 'too many households' using errcode = 'P0001';
  end if;
  insert into public.households (name, created_by) values (trim(p_name), v_uid) returning id into v_id;
  insert into public.household_members (household_id, user_id, role) values (v_id, v_uid, 'owner');
  return v_id;
end
$$;

-- Neue Signatur mit Rolle; die alte wird ersetzt
drop function public.create_invitation(uuid, int);
create function public.create_invitation(p_household uuid, p_max_uses int default 1,
                                         p_role public.household_role default 'member')
returns text
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_hex text := upper(replace(gen_random_uuid()::text, '-', ''));
  v_code text;
begin
  if not private.is_household_owner(p_household) then
    raise exception 'only owners can invite' using errcode = '42501';
  end if;
  -- Version- (Stelle 13) und Variant-Nibble (Stelle 17) auslassen: 16 zufällige Zeichen = 64 Bit
  v_hex := substr(v_hex, 1, 12) || substr(v_hex, 14, 3) || substr(v_hex, 18, 1);
  v_code := substr(v_hex, 1, 4) || '-' || substr(v_hex, 5, 4) || '-' || substr(v_hex, 9, 4) || '-' || substr(v_hex, 13, 4);
  insert into public.invitations (household_id, code_hash, created_by, max_uses, role)
    values (p_household, private.code_hash(v_code), (select auth.uid()),
            greatest(1, least(coalesce(p_max_uses, 1), 10)), coalesce(p_role, 'member'));
  return v_code;
end
$$;

-- Beitritt übernimmt die Rolle aus der Einladung
create or replace function private.join_after_confirmation(p_user auth.users)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_inv public.invitations;
  v_household uuid;
  v_name text;
begin
  if exists (select 1 from public.household_members where user_id = p_user.id) then
    return;
  end if;
  select * into v_inv from public.invitations
    where id = (select invitation_id from private.pending_invitations where user_id = p_user.id)
      and revoked_at is null and expires_at > now() and used_count < max_uses
    for update;
  if v_inv.id is not null then
    insert into public.household_members (household_id, user_id, role) values (v_inv.household_id, p_user.id, v_inv.role);
    update public.invitations set used_count = used_count + 1 where id = v_inv.id;
    v_household := v_inv.household_id;
  elsif exists (select 1 from private.signup_allowlist where email = lower(p_user.email)) then
    select display_name into v_name from public.profiles where id = p_user.id;
    insert into public.households (name, created_by)
      values (case when coalesce(v_name, '') = '' then 'Mein Haushalt' else left('Haushalt ' || v_name, 60) end, p_user.id)
      returning id into v_household;
    insert into public.household_members (household_id, user_id, role) values (v_household, p_user.id, 'owner');
  else
    return; -- Einladung inzwischen ungültig: später per accept_invitation beitreten
  end if;
  update public.profiles set last_household_id = v_household where id = p_user.id;
  delete from private.pending_invitations where user_id = p_user.id;
end
$$;

create or replace function public.accept_invitation(p_code text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_inv public.invitations;
begin
  if v_uid is null then raise exception 'not authenticated' using errcode = '42501'; end if;
  if (select count(*) from private.invite_attempts
      where user_id = v_uid and attempted_at > now() - interval '1 hour') >= 10 then
    raise exception 'too many attempts' using errcode = 'P0001';
  end if;
  delete from private.invite_attempts where attempted_at < now() - interval '1 day';
  v_inv := private.find_invitation(p_code);
  if v_inv.id is null then
    -- kein raise: der Fehlversuch muss gespeichert bleiben (raise rollt zurück)
    insert into private.invite_attempts (user_id) values (v_uid);
    return null;
  end if;
  if exists (select 1 from public.household_members where household_id = v_inv.household_id and user_id = v_uid) then
    return v_inv.household_id; -- schon Mitglied, Code nicht verbrauchen
  end if;
  insert into public.household_members (household_id, user_id, role) values (v_inv.household_id, v_uid, v_inv.role);
  update public.invitations set used_count = used_count + 1 where id = v_inv.id;
  return v_inv.household_id;
end
$$;

-- Owner machen Mitglieder zu Owner oder zurück. Der letzte Owner kann sich
-- nicht selbst herabstufen (sonst Haushalt ohne Owner).
create function public.set_member_role(p_household uuid, p_user uuid, p_role public.household_role)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not private.is_household_owner(p_household) then
    raise exception 'only owners can change roles' using errcode = '42501';
  end if;
  perform 1 from public.households where id = p_household for update;
  if p_role = 'member' and not exists (
      select 1 from public.household_members
      where household_id = p_household and role = 'owner' and user_id <> p_user) then
    raise exception 'last owner' using errcode = 'P0001';
  end if;
  update public.household_members set role = p_role where household_id = p_household and user_id = p_user;
end
$$;

revoke all on function public.create_invitation(uuid, int, public.household_role), public.set_member_role(uuid, uuid, public.household_role)
  from public, anon;
grant execute on function public.create_invitation(uuid, int, public.household_role), public.set_member_role(uuid, uuid, public.household_role)
  to authenticated;
revoke all on function private.join_after_confirmation(auth.users) from public, anon, authenticated;
