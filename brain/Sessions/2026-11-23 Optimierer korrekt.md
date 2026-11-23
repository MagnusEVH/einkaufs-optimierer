---
type: session
datum: 2026-11-23
agent: Claude Code (Opus)
prs: []
tags: [session]
---
# 2026-11-23 – Optimierer korrekt

Branch: `claude/phase1-optimierer` (baut auf `claude/phase0-ehrliche-texte` auf)

## Erledigt
- `optimizer_service.dart` neu:
  - kein Pauschalpreis mehr, Artikel ohne Preis stehen in `unpricedItems`
  - Filialen aus `rlpStores` (wie die Karte), gefiltert nach Umkreis und bevorzugten Ketten
  - Fahrtkosten ab Standort für jede Route, nur der Fußweg zwischen Märkten ≤ 800 m ist frei
  - abgehakte Artikel zählen nicht, Angebote nur bei exakter Produkt-ID und gültigem Datum
  - Ersparnis gegen den günstigsten Einzelmarkt inkl. Fahrt
- `catalog_service.dart`: Freitext-Zuordnung über ganze Wörter, Bio-Präferenz findet Bio-Varianten
- Optimizer-Screen lädt Einstellungen (Demo: im Speicher bis zum Neuladen) und zeigt Artikel ohne Preis
- Einkaufsabschluss: Ersparnis gegen den günstigsten Einzelmarkt statt Max-minus-Min
- `WeeklyOffer.productId` und `isValidAt()`
- `test/review_probes_test.dart`: Review-Sonden A1–A12 gegen echten Code, 37 Tests grün

## Offen
- A13 / Server-Optimizer (`optimize-route`) an die App angleichen
- Rückfrage bei unsicherer Freitext-Zuordnung (UI)
- Fahrtkosten über Luftlinie, nicht Straßenweg
- Angebotsdaten widersprüchlich (Angebotspreis teils über Katalogpreis)

## Gelernt
- Siehe [[Stolperfallen]]: Angebotspreise können über dem Katalogpreis liegen
