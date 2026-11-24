---
type: home
aktualisiert: 2026-11-24
---
# 🧠 Einkaufs-Optimierer – Zweites Gehirn

Einstieg für Nutzer und Agenten. Regeln: [AGENTS.md](../AGENTS.md) · Ablauf: [[Arbeitsablauf]]

## Aktueller Stand
- `main` ist grün und live auf GitHub Pages (Deploy-Lauf #28).
- App läuft im **Demo-Modus** (ohne Supabase).
- Texte als Demo gekennzeichnet, Kartenlizenz-Hinweis da, Cockpit nur im Debug-Build (PR #11, gemergt).
- Optimierer rechnet korrekt (Umkreis, Fahrtkosten, keine Pauschalpreise), Review-Sonden als Tests, Rückfrage bei Freitext, Liste und Einstellungen werden gespeichert (PR #12, gemergt).
- Echte Angebote per Übernehmen-Knopf (`uebernehmen.html`, PR #13, gemergt). Praxistest: erkennt etwa die Hälfte, Preise teils falsch.
- Speichern im Browser repariert (`shared_preferences` statt `flutter_secure_storage`), Branch `claude/speichern-reparieren`.
- Letzte Session: [[2026-11-24 Speichern repariert]]

## Offene Baustellen
- [[Supabase-Anbindung]] – hoch, starkes Modell
- [[Carto-Key-Rotation]] – hoch, Aufgabe für den Nutzer
- [[Live-Scraper]] – ersetzt durch Übernehmen-Knopf
- [[CI-Analyze-Gate]] – niedrig
- [[Mobile-Builds]] – niedrig

Alle Baustellen, Entscheidungen und Sessions als Tabelle: [[Übersicht.base|Übersicht]]

## Wissen
- [[Architektur]] · [[Stolperfallen]] · [[Arbeitsablauf]]

## Ordner
`Baustellen/` · `Entscheidungen/` · `Sessions/` · `Wissen/` · `_Vorlagen/`
