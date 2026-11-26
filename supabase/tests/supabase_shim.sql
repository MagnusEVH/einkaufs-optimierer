-- Nachbau der Teile von Supabase, die unsere Migrationen voraussetzen.
-- Nur für Tests mit PGlite. Grenzen: kein echtes GoTrue, kein Storage-Dienst,
-- Registrierungen laufen wie bei Supabase als Rolle supabase_auth_admin.

create role anon nologin noinherit;
create role authenticated nologin noinherit;
create role service_role nologin noinherit bypassrls;
-- GoTrue schreibt als supabase_auth_admin (kein Superuser)
create role supabase_auth_admin nologin noinherit;

create schema auth;
create table auth.users (
  id uuid primary key default gen_random_uuid(),
  email text,
  raw_user_meta_data jsonb not null default '{}'::jsonb,
  email_confirmed_at timestamptz,
  is_anonymous boolean not null default false,
  last_sign_in_at timestamptz,
  created_at timestamptz not null default now()
);

create function auth.uid() returns uuid language sql stable as $$
  select nullif(coalesce(current_setting('request.jwt.claim.sub', true),
                         (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')), '')::uuid
$$;
create function auth.role() returns text language sql stable as $$
  select nullif(current_setting('request.jwt.claim.role', true), '')
$$;
grant usage on schema auth to anon, authenticated, supabase_auth_admin;
grant all on auth.users to supabase_auth_admin;
grant execute on all functions in schema auth to anon, authenticated;

-- Supabase-Standard: API-Rollen bekommen alles im Schema public, RLS schützt.
grant usage on schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant execute on functions to anon, authenticated, service_role;
