---
type: session
datum: 2026-11-24
agent: Claude Code (Opus)
prs: []
tags: [session]
---
# 2026-11-24 – Wochenrunde, Bon-Scan, REWE-Erkennung

Branch: `claude/wochenrunde-bonscan`. Entscheidung: [[Bonpreise ersetzen Katalogpreise]]

## Erledigt
- Übernehmen-Knopf: eigene REWE-Regel (Kacheln `article.cor-offer-renderer-tile`, Preise aus dem `aria-label`, Gültigkeit aus `data-offer-week`, Artikelnummer als stabile ID). An einer gespeicherten echten Seite: 444 von 444 Kacheln mit richtigem Preis (vorher etwa die Hälfte, 21 falsch)
- Allgemeine Erkennung: Streichpreise (`<s>`, line-through) und "Niedrigster Preis der letzten 30 Tage" zählen nicht mehr als Angebotspreis, Titel aus Überschrift
- Neuer Import ersetzt alte Angebote derselben Kette und Woche; Warnhinweis bei unplausiblen Angeboten
- Wochenrunde im Angebote-Tab: Stand je Kette, Link zur Angebotsseite
- Bon-Scan: `bon.html` + `bon/parse.js` (Menge, Gewicht, Rabatt, Pfand, OCR-Lesefehler), Bonpreise im Optimierer, gemerkte Zuordnungen
- Tests: `test_bon_parse.js`, `test_uebernehmen_rewe.js` (nachgebaute Kacheln), 4 neue Flutter-Tests (54 grün). Lokaler Build in Chrome: Bonbild → Texterkennung → Vorschau in der App

## Offen
- Lidl, ALDI, Netto, dm, Rossmann: allgemeine Erkennung ungeprüft, je eine gespeicherte Seite nötig
- Links der Wochenrunde außer REWE zeigen auf die Startseite

## Gelernt
- Siehe [[Stolperfallen]]: Headless-Chrome und gespeicherte Händlerseiten
