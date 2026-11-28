-- ============================================================================
-- Menge mit Einheit für die gemeinsame Liste ("500 g Erdbeeren", "2 l Milch").
-- Additiv: neue Spalte, alte Zeilen bleiben gültig (keine Einheit = Stück).
-- Alte Apps würden "500" als 500 Stück zeigen, deshalb min_app_version 2:
-- sie bekommen den Hinweis "Neue Version da".
-- ============================================================================

alter table public.shopping_items
  add column unit text check (unit in ('stk', 'g', 'kg', 'ml', 'l', 'pck', 'bund'));

grant update (unit) on public.shopping_items to authenticated;

create or replace function public.min_app_version()
returns int
language sql immutable set search_path = ''
as $$ select 2 $$;
