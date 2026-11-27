---
type: session
datum: 2026-11-27
agent: Claude Code (Opus 5.5)
prs: [32]
tags: [session]
---
# 2026-11-27 – Stufe 3c: Abgleich der Liste

## Erledigt
- `list_sync.dart`: Liste je Haushalt mit Zwischenspeicher, Warteschlange, Nachladen seit letztem Stand (2 Min. Überlappung), Realtime als Signal
- Änderungen als Patch (nur geänderte Felder), Löschen weich über `deleted_at`, Löschen gewinnt gegen Ändern
- Liste angemeldet mit Haushalt gemeinsam, sonst lokal wie bisher. Erste Anmeldung: Geräte-Liste übernehmen (fragen)
- Hinweise in der Liste: offline mit Zahl wartender Änderungen, Anmeldung abgelaufen, neue Version
- Migration `20261127000001_realtime_liste.sql` (Tabelle in `supabase_realtime`), Shim für PGlite ergänzt
- 114 Flutter-Tests grün (12 neue), 27 RLS-Tests grün, Gegenprobe mit absichtlichem Fehler wird rot

## Offen
- Migration 3 einspielen (Magnus klickt Run)
- Repo-Variablen `SUPABASE_URL`/`SUPABASE_KEY` setzen → App live mit Server
- Magnus registriert sich, dann Admin eintragen und echter Zwei-Geräte-Test
- Nicht umgesetzt: "nur ein Tab gleicht ab". Doppeltes Senden ist harmlos (Anlegen mit fester ID, Patches idempotent)

## Gelernt
- Nachladen per `updated_at` braucht Überlappung: `clock_timestamp()` liegt vor dem Commit, spät committete Zeilen fielen sonst durch
