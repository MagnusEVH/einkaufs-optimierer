---
type: baustelle
status: in Arbeit
prioritaet: hoch
modell: stark
aktualisiert: 2026-11-28
tags: [baustelle]
---
# Supabase-Anbindung

App läuft ohne Supabase im Demo-Modus. Secrets `SUPABASE_URL` und `SUPABASE_ANON_KEY` (Publishable Key) sind in GitHub angelegt, werden aber noch nicht genutzt.

## Nächste Schritte
- [x] Plan vorlegen – 2026-11-26 (Stufen 0–7, liegt privat beim Nutzer)
- [x] Neue Basis-Migration Konten/Haushalte mit RLS-Tests (PGlite) – 2026-11-26
- [ ] Stufe 0 beim Nutzer: Region, SMTP, Registrierung, alte Edge Functions
- [ ] Migration ins Projekt einspielen
- [ ] Workflow: Secrets per `--dart-define` an den Build geben
- [ ] `main.dart`: `SupabaseService.initialize(url, anonKey)`
- [ ] Demo-Modus als Fallback behalten

> [!warning] Nur den Publishable/Anon-Key in die App – nie `service_role`/`sb_secret_…`.

- [x] SMTP (Brevo) und Mail-Vorlagen mit Code, siehe [[Mail-Versand einrichten]] – 2026-11-28
- [x] Admin eingetragen – 2026-11-28
- [ ] Zwei-Geräte-Test (iPhone + PC)
- [x] Anmelde-System per Code, ohne Sackgassen (PR #36) – 2026-11-28
