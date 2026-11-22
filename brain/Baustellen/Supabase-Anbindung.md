---
type: baustelle
status: offen
prioritaet: hoch
modell: stark
aktualisiert: 2026-11-22
tags: [baustelle]
---
# Supabase-Anbindung

App läuft ohne Supabase im Demo-Modus. Secrets `SUPABASE_URL` und `SUPABASE_ANON_KEY` (Publishable Key) sind in GitHub angelegt, werden aber noch nicht genutzt.

## Nächste Schritte
- [ ] Plan vorlegen (Migrationen gegen echtes Projekt prüfen, RLS, Edge Functions)
- [ ] Workflow: Secrets per `--dart-define` an den Build geben
- [ ] `main.dart`: `SupabaseService.initialize(url, anonKey)`
- [ ] Demo-Modus als Fallback behalten

> [!warning] Nur den Publishable/Anon-Key in die App – nie `service_role`/`sb_secret_…`.
