---
type: session
datum: 2026-11-27
agent: Claude Code (Opus 5.5)
prs: [30]
tags: [session]
---
# 2026-11-27 – Stufe 3a: Konto

## Erledigt
- Migrationen 1+2 live im Supabase-Projekt (Magnus klickt Run), geprüft: 9 Tabellen mit RLS, 9 Policies, 4 Trigger auf `auth.users`. Allowlist mit Magnus' Adresse
- `SUPABASE_URL`/`SUPABASE_KEY` per `--dart-define`, in der CI aus Repo-Variablen (nicht gesetzt = lokal)
- Konto-Bildschirm: Anmelden, Registrieren mit Einladungscode, Bestätigen und Passwort vergessen per Link oder Code, Abmelden. Konto löschen im Profil (`delete_my_account`)
- Alte Aufrufe abgeschaltet: `list_items`, `user_preferences`, Analytics-Tabellen, Edge Function `optimize-route` (`SupabaseService.legacyBackend = false`)
- Lokaler Build gegen das echte Projekt: falsches Passwort und Registrierung ohne gültige Einladung zeigen die deutschen Texte
- 96 Flutter-Tests grün

## Offen
- 3b Haushalte, 3c Abgleich. Repo-Variablen erst nach 3c setzen
- SMTP: ohne eigenes SMTP lassen sich die Mail-Vorlagen nicht ändern, Mails enthalten nur Links

## Gelernt
- Siehe [[Stolperfallen]]: Mail-Vorlagen nur mit SMTP, PKCE-Links scheitern in Safari, Git Bash verbiegt `--base-href "/"`
