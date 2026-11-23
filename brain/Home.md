---
type: home
aktualisiert: 2026-11-22
---
# 🧠 Einkaufs-Optimierer – Zweites Gehirn

Einstieg für Nutzer und Agenten. Regeln: [AGENTS.md](../AGENTS.md) · Ablauf: [[Arbeitsablauf]]

## Aktueller Stand
- `main` ist grün und live auf GitHub Pages (Deploy-Lauf #28).
- App läuft im **Demo-Modus** (ohne Supabase).
- Texte als Demo gekennzeichnet, Kartenlizenz-Hinweis da, Cockpit nur im Debug-Build (PR #11, gemergt).
- Optimierer rechnet korrekt (Umkreis, Fahrtkosten, keine Pauschalpreise), Review-Sonden als Tests, Rückfrage bei Freitext, Liste und Einstellungen werden gespeichert (PR #12).
- Letzte Session: [[2026-11-23 Rueckfrage und Speichern]]

## Offene Baustellen
- [[Supabase-Anbindung]] – hoch, starkes Modell
- [[Carto-Key-Rotation]] – hoch, Aufgabe für den Nutzer
- [[Live-Scraper]] – mittel, starkes Modell
- [[CI-Analyze-Gate]] – niedrig
- [[Mobile-Builds]] – niedrig

Alle Baustellen, Entscheidungen und Sessions als Tabelle: [[Übersicht.base|Übersicht]]

## Wissen
- [[Architektur]] · [[Stolperfallen]] · [[Arbeitsablauf]]

## Ordner
`Baustellen/` · `Entscheidungen/` · `Sessions/` · `Wissen/` · `_Vorlagen/`
