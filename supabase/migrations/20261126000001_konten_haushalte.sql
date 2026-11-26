-- ============================================================================
-- Konten und Haushalte (Neuanfang, die alten Migrationen liegen in supabase/archiv/)
--
-- Listen gehören einem Haushalt. Ein Konto kann in mehreren Haushalten
-- Mitglied sein (z. B. eigener Haushalt und der der Eltern).
-- Katalog, Filialen und Angebote bleiben vorerst in app/assets.
-- Belege und beobachtete Preise kommen mit einer eigenen Migration (Stufe 4).
--
-- Registrierung nur mit Einladungscode (der öffentliche Key steht im Build)
-- oder mit einer E-Mail aus private.signup_allowlist (per SQL gepflegt, z. B.
-- für den Betreiber). Haushalt gibt es erst nach bestätigter E-Mail.
-- Anonyme Konten sind ausgeschlossen.
--
-- Pflicht im Supabase-Dashboard: "Confirm email" an (sonst könnte jemand mit
-- einer Allowlist-Adresse zuvorkommen), Phone-Login und Anonymous Sign-ins aus.
--
-- Rechte: Jede Tabelle hat RLS. Mitgliedschaft prüft private.user_household_ids()
-- (security definer, vermeidet Rekursion). Beitritt, Einladung, Austritt und
-- Kontolöschung laufen nur über Funktionen. Tests: supabase/tests/rls.test.mjs
--
-- Regel für spätere Migrationen: nur additiv (alte App-Versionen laufen weiter),
-- sonst public.min_app_version() erhöhen.
-- ============================================================================

create schema if not exists private;

-- ----------------------------------------------------------------------------
-- Tabellen
-- ----------------------------------------------------------------------------

create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 60),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '' check (char_length(display_name) <= 60),
  last_household_id uuid references public.households (id) on delete set null,
  last_seen_on date,
  created_at timestamptz not null default now()
);

create type public.household_role as enum ('owner', 'member');

create table public.household_members (
  household_id uuid not null references public.households (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.household_role not null default 'member',
  joined_at timestamptz not null default now(),
  primary key (household_id, user_id)
);
create index household_members_user_idx on public.household_members (user_id);

-- Der Code selbst wird nie gespeichert, nur sein SHA-256.
create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  code_hash text not null unique,
  created_by uuid references auth.users (id) on delete set null,
  expires_at timestamptz not null default now() + interval '7 days',
  max_uses int not null default 1 check (max_uses between 1 and 10),
  used_count int not null default 0,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);
create index invitations_household_idx on public.invitations (household_id);

-- Einkaufsliste: id kommt vom Gerät (offline anlegbar, Upsert ist idempotent).
-- Abhaken setzt checked_at (null = wieder offen), Löschen setzt deleted_at.
-- updated_at setzt der Server. Abgleich holt alles mit updated_at > (letzter Abgleich - 5 Min.)
-- und entfernt Doppelte per id: später committende Transaktionen tragen frühere Zeiten.
create table public.shopping_items (
  id uuid primary key,
  household_id uuid not null references public.households (id) on delete cascade,
  raw_text text not null check (char_length(raw_text) between 1 and 200),
  product_id text,
  quantity numeric not null default 1 check (quantity > 0 and quantity <= 999),
  note text check (char_length(note) <= 200),
  category text check (char_length(category) <= 60),
  checked_at timestamptz,
  checked_by uuid references auth.users (id) on delete set null,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null
);
create index shopping_items_household_updated_idx on public.shopping_items (household_id, updated_at);

-- Admins werden nur per SQL eingetragen, nie über die App.
create table public.app_admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);

-- E-Mails, die sich ohne Einladung registrieren dürfen und einen eigenen
-- Haushalt bekommen. Nur per SQL im Dashboard: insert into private.signup_allowlist ...
create table private.signup_allowlist (
  email text primary key check (email = lower(email))
);

-- Einladung, mit der sich ein Konto registriert hat. Nicht in den Kontodaten,
-- weil Nutzer raw_user_meta_data selbst ändern können.
create table private.pending_invitations (
  user_id uuid primary key references auth.users (id) on delete cascade,
  invitation_id uuid not null references public.invitations (id) on delete cascade
);

-- Fehlversuche beim Einlösen von Einladungen (gegen Raten).
create table private.invite_attempts (
  user_id uuid not null,
  attempted_at timestamptz not null default now()
);
create index invite_attempts_user_idx on private.invite_attempts (user_id, attempted_at);

-- ----------------------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------------------

create function private.user_household_ids()
returns setof uuid
language sql stable security definer set search_path = ''
as $$
  select household_id from public.household_members where user_id = (select auth.uid())
$$;

create function private.is_household_owner(p_household uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.household_members
    where household_id = p_household and user_id = (select auth.uid()) and role = 'owner'
  )
$$;

create function private.is_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.app_admins where user_id = (select auth.uid()))
$$;

create function private.code_hash(p_code text)
returns text
language sql immutable set search_path = ''
as $$
  select encode(sha256(convert_to(upper(replace(trim(coalesce(p_code, '')), ' ', '')), 'UTF8')), 'hex')
$$;

-- Gültige Einladung zum Code, gesperrt für die laufende Transaktion
create function private.find_invitation(p_code text)
returns public.invitations
language sql volatile security definer set search_path = ''
as $$
  select * from public.invitations
  where code_hash = private.code_hash(p_code)
    and revoked_at is null and expires_at > now() and used_count < max_uses
  for update
$$;

-- ----------------------------------------------------------------------------
-- RLS
-- ----------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.invitations enable row level security;
alter table public.shopping_items enable row level security;
alter table public.app_admins enable row level security; -- ohne Policies: nur Server

-- Profile: eigenes und die der Mitglieder gemeinsamer Haushalte (Namen anzeigen)
create policy profiles_select on public.profiles for select to authenticated
  using (
    id = (select auth.uid())
    or id in (
      select m.user_id from public.household_members m
      where m.household_id in (select private.user_household_ids())
    )
  );
create policy profiles_update on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy households_select on public.households for select to authenticated
  using (id in (select private.user_household_ids()));
create policy households_update on public.households for update to authenticated
  using ((select private.is_household_owner(id))) with check ((select private.is_household_owner(id)));

create policy members_select on public.household_members for select to authenticated
  using (household_id in (select private.user_household_ids()));

-- Owner sehen offene Einladungen (ohne Code, nur Hash) zum Widerrufen
create policy invitations_select on public.invitations for select to authenticated
  using ((select private.is_household_owner(household_id)));

create policy items_select on public.shopping_items for select to authenticated
  using (household_id in (select private.user_household_ids()));
create policy items_insert on public.shopping_items for insert to authenticated
  with check (household_id in (select private.user_household_ids()));
create policy items_update on public.shopping_items for update to authenticated
  using (household_id in (select private.user_household_ids()))
  with check (household_id in (select private.user_household_ids()));

-- Spalten, die der Server setzt, nicht das Gerät
create function private.stamp_shopping_item()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  new.updated_at := clock_timestamp();
  new.updated_by := (select auth.uid());
  if tg_op = 'INSERT' then
    new.created_at := new.updated_at;
    new.created_by := (select auth.uid());
  else
    new.id := old.id;
    new.household_id := old.household_id;
    new.created_at := old.created_at;
    new.created_by := old.created_by;
  end if;
  if new.checked_at is null then
    new.checked_by := null;
  elsif tg_op = 'INSERT' or old.checked_at is null then
    new.checked_by := (select auth.uid());
  else
    new.checked_at := old.checked_at;
    new.checked_by := old.checked_by;
  end if;
  return new;
end
$$;
create trigger shopping_items_stamp before insert or update on public.shopping_items
  for each row execute function private.stamp_shopping_item();

-- ----------------------------------------------------------------------------
-- Registrierung
-- 1. Vor dem Anlegen: Einladungscode prüfen (oder E-Mail auf der Allowlist).
--    Der Code wird aus den Kontodaten entfernt, gemerkt wird nur die
--    Einladungs-ID (allein nutzlos).
-- 2. Profil sofort, Haushalt erst mit bestätigter E-Mail. So verbraucht ein
--    Tippfehler in der Adresse keinen Code und erzeugt kein Phantom-Mitglied.
-- ----------------------------------------------------------------------------

create function private.before_new_user()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  v_inv public.invitations;
begin
  if coalesce(new.is_anonymous, false) then
    raise exception 'Anonyme Konten sind nicht erlaubt' using errcode = '42501';
  end if;
  v_inv := private.find_invitation(new.raw_user_meta_data ->> 'invite_code');
  new.raw_user_meta_data := coalesce(new.raw_user_meta_data, '{}'::jsonb) - 'invite_code';
  -- an den After-Trigger derselben Transaktion weitergeben
  perform set_config('app.pending_invitation', coalesce(v_inv.id::text, ''), true);
  if v_inv.id is null and not exists (select 1 from private.signup_allowlist where email = lower(new.email)) then
    raise exception 'Registrierung nur mit gültigem Einladungscode' using errcode = '42501';
  end if;
  return new;
end
$$;
create trigger before_auth_user_created before insert on auth.users
  for each row execute function private.before_new_user();

-- Codes, die später per Update in die Kontodaten geraten, sofort entfernen
create function private.strip_invite_code()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  if new.raw_user_meta_data ? 'invite_code' then
    new.raw_user_meta_data := new.raw_user_meta_data - 'invite_code';
  end if;
  return new;
end
$$;
create trigger before_auth_user_updated before update on auth.users
  for each row execute function private.strip_invite_code();

-- Haushalt zuordnen, sobald die E-Mail bestätigt ist (einmalig)
create function private.join_after_confirmation(p_user auth.users)
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
    insert into public.household_members (household_id, user_id, role) values (v_inv.household_id, p_user.id, 'member');
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

create function private.handle_new_user()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  v_pending text := nullif(current_setting('app.pending_invitation', true), '');
begin
  if v_pending is not null then
    insert into private.pending_invitations (user_id, invitation_id) values (new.id, v_pending::uuid);
    perform set_config('app.pending_invitation', '', true);
  end if;
  -- Name nur, wenn selbst angegeben (nicht aus der E-Mail ableiten)
  insert into public.profiles (id, display_name)
    values (new.id, left(coalesce(trim(new.raw_user_meta_data ->> 'display_name'), ''), 60));
  if new.email_confirmed_at is not null then
    perform private.join_after_confirmation(new);
  end if;
  return new;
end
$$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function private.handle_new_user();

create function private.handle_user_confirmed()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  perform private.join_after_confirmation(new);
  return new;
end
$$;
create trigger on_auth_user_confirmed after update of email_confirmed_at on auth.users
  for each row when (old.email_confirmed_at is null and new.email_confirmed_at is not null)
  execute function private.handle_user_confirmed();

-- Haushalt ohne Mitglieder wird gelöscht. Haushalt ohne Owner bekommt das
-- dienstälteste Mitglied als Owner. Greift bei Austritt und Kontolöschung.
-- Sperrt den Haushalt, damit gleichzeitige Austritte sich nacheinander sehen.
create function private.after_member_removed()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  v_next uuid;
begin
  perform 1 from public.households where id = old.household_id for update;
  if not found then
    return null; -- Haushalt wird gerade selbst gelöscht
  end if;
  if not exists (select 1 from public.household_members where household_id = old.household_id) then
    delete from public.households where id = old.household_id;
  elsif not exists (select 1 from public.household_members where household_id = old.household_id and role = 'owner') then
    select user_id into v_next from public.household_members
      where household_id = old.household_id order by joined_at, user_id limit 1;
    update public.household_members set role = 'owner' where household_id = old.household_id and user_id = v_next;
  end if;
  return null;
end
$$;
create trigger household_members_after_delete after delete on public.household_members
  for each row execute function private.after_member_removed();

-- ----------------------------------------------------------------------------
-- Funktionen für die App
-- ----------------------------------------------------------------------------

-- Weitere Haushalte (z. B. "Eltern", den Magnus selbst pflegt): nur Admins
create function public.create_household(p_name text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_id uuid;
begin
  if not private.is_admin() then
    raise exception 'admins only' using errcode = '42501';
  end if;
  insert into public.households (name, created_by) values (trim(p_name), (select auth.uid())) returning id into v_id;
  insert into public.household_members (household_id, user_id, role) values (v_id, (select auth.uid()), 'owner');
  return v_id;
end
$$;

-- Liefert den Code genau einmal. 64 Bit Zufall, Format XXXX-XXXX-XXXX-XXXX.
create function public.create_invitation(p_household uuid, p_max_uses int default 1)
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
  insert into public.invitations (household_id, code_hash, created_by, max_uses)
    values (p_household, private.code_hash(v_code), (select auth.uid()), greatest(1, least(coalesce(p_max_uses, 1), 10)));
  return v_code;
end
$$;

create function public.revoke_invitation(p_invitation uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  update public.invitations set revoked_at = now()
  where id = p_invitation and private.is_household_owner(household_id) and revoked_at is null;
end
$$;

-- Bestehendes Konto tritt einem weiteren Haushalt bei. Ungültiger Code: null.
create function public.accept_invitation(p_code text)
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
  insert into public.household_members (household_id, user_id, role) values (v_inv.household_id, v_uid, 'member');
  update public.invitations set used_count = used_count + 1 where id = v_inv.id;
  return v_inv.household_id;
end
$$;

create function public.leave_household(p_household uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  delete from public.household_members where household_id = p_household and user_id = (select auth.uid());
end
$$;

create function public.remove_member(p_household uuid, p_user uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not private.is_household_owner(p_household) then
    raise exception 'only owners can remove members' using errcode = '42501';
  end if;
  if p_user = (select auth.uid()) then
    raise exception 'use leave_household' using errcode = 'P0001';
  end if;
  delete from public.household_members where household_id = p_household and user_id = p_user;
end
$$;

-- Konto löschen: Profil, Mitgliedschaften und verwaiste Haushalte gehen mit
-- (Fremdschlüssel + after_member_removed). Dateien im Storage räumt Stufe 4 auf.
create function public.delete_my_account()
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'not authenticated' using errcode = '42501'; end if;
  delete from auth.users where id = v_uid;
end
$$;

-- Höchstens ein Schreibzugriff pro Tag und Person, für "aktiv in 7/30 Tagen"
create function public.touch_last_seen()
returns void
language sql security definer set search_path = ''
as $$
  update public.profiles set last_seen_on = current_date
  where id = (select auth.uid()) and last_seen_on is distinct from current_date
$$;

-- Ältere App-Versionen zeigen darunter "Bitte neu laden"
create function public.min_app_version()
returns int
language sql immutable set search_path = ''
as $$ select 1 $$;

-- Nur Zahlen, keine Namen oder Produkte. Nur für Admins.
create function public.admin_stats()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'admins only' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'accounts', (select count(*) from public.profiles),
    'active_7d', (select count(*) from public.profiles where last_seen_on >= current_date - 6),
    'active_30d', (select count(*) from public.profiles where last_seen_on >= current_date - 29),
    'households', (select count(*) from public.households),
    'shared_households', (select count(*) from (
        select household_id from public.household_members group by household_id having count(*) > 1) s),
    'items_open', (select count(*) from public.shopping_items where checked_at is null and deleted_at is null),
    'db_bytes', pg_database_size(current_database())
  );
end
$$;

-- ----------------------------------------------------------------------------
-- Ausführrechte: Supabase gibt anon standardmäßig alles, deshalb ausdrücklich.
-- ----------------------------------------------------------------------------

grant usage on schema private to authenticated;
revoke all on all functions in schema private from public, anon, authenticated;
grant execute on function private.user_household_ids(), private.is_household_owner(uuid), private.is_admin()
  to authenticated;

revoke all on function public.create_household(text), public.create_invitation(uuid, int),
  public.revoke_invitation(uuid), public.accept_invitation(text), public.leave_household(uuid),
  public.remove_member(uuid, uuid), public.delete_my_account(), public.touch_last_seen(),
  public.admin_stats(), public.min_app_version()
  from public, anon;
grant execute on function public.create_household(text), public.create_invitation(uuid, int),
  public.revoke_invitation(uuid), public.accept_invitation(text), public.leave_household(uuid),
  public.remove_member(uuid, uuid), public.delete_my_account(), public.touch_last_seen(),
  public.admin_stats(), public.min_app_version()
  to authenticated;
grant execute on function public.min_app_version() to anon;

-- Tabellen: anon sieht nichts. authenticated nur, was die Policies brauchen,
-- Updates nur auf erlaubte Spalten (Supabase gibt per Default ALL).
revoke all on public.profiles, public.households, public.household_members, public.invitations,
  public.shopping_items, public.app_admins from anon, authenticated;
grant select on public.profiles, public.households, public.household_members, public.invitations,
  public.shopping_items, public.app_admins to authenticated;
grant update (display_name, last_household_id) on public.profiles to authenticated;
grant update (name) on public.households to authenticated;
grant insert on public.shopping_items to authenticated;
-- id und household_id nur, damit Upsert (on conflict do update) geht; der Trigger hält beide fest
grant update (id, household_id, raw_text, product_id, quantity, note, category, checked_at, deleted_at)
  on public.shopping_items to authenticated;

-- Später angelegte Funktionen sind nicht mehr automatisch für PUBLIC aufrufbar
-- (pro Schema lässt sich das nicht entziehen). Neue public-Funktionen brauchen
-- daher ein ausdrückliches grant execute.
alter default privileges revoke execute on functions from public;
alter default privileges in schema private revoke execute on functions from anon, authenticated;
