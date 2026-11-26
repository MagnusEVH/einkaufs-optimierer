---
type: session
datum: 2026-11-26
agent: Claude Code (Opus 5.5)
prs: []
tags: [session]
---
# 2026-11-26 – Konten-Schema (Stufe 1)

## Erledigt
- Recherche mit drei parallelen Agenten (Hosting/Kosten, Datenmodell/Sync, Belege/Dashboard), Plan im privaten Vault, Plan-Review durch einen weiteren Agenten
- Neue Migration `20261126000001_konten_haushalte.sql`, alte nach `supabase/archiv/`
- 22 RLS-Tests mit PGlite (Registrierung als `supabase_auth_admin`), Schritt in der CI. Gegenprobe: absichtlich aufgeweichte Regeln fallen auf
- Sicherheitsprüfung (Agent, Opus): 4 wichtige Funde, alle behoben – Klartext-Code in Kontodaten, "erstes Konto" kaperbar, Beitritt vor E-Mail-Bestätigung, Race beim Austritt. Dazu Spaltenrechte, TRUNCATE, 64-Bit-Codes, anonyme Konten
- Entscheidungen: [[Haushalte statt Kontowechsel]], [[Schema-Neuanfang mit Einladungspflicht]]

## Offen
- Stufe 0 (Nutzer): Region des Supabase-Projekts prüfen, SMTP, Registrierung, alte Edge Functions
- Migration ins echte Projekt einspielen erst nach Stufe 0
- Stufe 2/3: Anmelden, Haushalt wählen, gemeinsame Liste mit Abgleich

## Gelernt
- Siehe [[Stolperfallen]]: `raise` rollt auch das Protokoll von Fehlversuchen zurück
