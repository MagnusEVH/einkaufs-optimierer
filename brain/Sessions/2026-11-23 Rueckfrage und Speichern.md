---
type: session
datum: 2026-11-23
agent: Claude Code (Opus)
prs: [12]
tags: [session]
---
# 2026-11-23 – Rückfrage und Speichern

Branch: `claude/phase1-optimierer` (PR #12). Vorher: [[2026-11-23 Optimierer korrekt]]

## Erledigt
- Freitext: `CatalogService.matchCandidates()` mit `MatchLevel`; Marke zählt mit; Wortende-Treffer nur als Vorschlag
- Liste markiert unsichere Artikel, Tippen öffnet Auswahl (`assignProduct`); Optimierer behält ausdrücklich gewählte Produkte
- Liste und Einstellungen werden lokal gespeichert (`PreferencesStorage`, Web: localStorage)
- Angebote: nur gültige, abgelaufene ausgeblendet, als Beispieldaten gekennzeichnet
- 43 Flutter-Tests grün

## Offen
- Server-Optimizer (`optimize-route`) erst mit dem Backend angleichen (Phase 3)
- Speichern im echten Browser einmal prüfen (Tests decken nur den Zwischenspeicher ab)
- Echte Datenquelle braucht Entscheidung D1

## Gelernt
- `flutter_secure_storage` hat im Test kein Plugin → `PreferencesStorage` arbeitet dann nur mit dem Zwischenspeicher
