-- ============================================================================
-- Realtime für die gemeinsame Liste (Stufe 3c). Rein additiv.
-- Die App nutzt Realtime nur als Signal "jetzt nachladen". Supabase prüft für
-- postgres_changes die RLS jedes Abonnenten: Es kommen nur Ereignisse aus
-- eigenen Haushalten an.
-- ============================================================================

alter publication supabase_realtime add table public.shopping_items;
