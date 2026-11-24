---
type: session
datum: 2026-11-24
agent: Claude Code (Opus)
prs: []
tags: [session]
---
# 2026-11-24 – Speichern repariert, Praxistest Übernehmen-Knopf

Branch: `claude/speichern-reparieren`

## Erledigt
- Liste ging nach dem Neuladen verloren (Praxistest). Ursache: Web-Variante von `flutter_secure_storage` erzeugt den Schlüssel ohne Sperre; parallele erste Schreibvorgänge erzeugen mehrere Schlüssel, die übrigen Werte sind danach unlesbar
- `PreferencesStorage` nutzt jetzt `shared_preferences` (localStorage), alte Werte werden einmalig übernommen, soweit lesbar
- Tests simulieren echtes Neuladen (kein Zwischenspeicher mehr), neuer Test für parallele Schreibvorgänge; 50 Flutter-Tests grün
- Lokaler Web-Build in Headless-Chrome geprüft: Liste leeren, 2 Artikel hinzufügen, neu laden → Liste bleibt
- Open Prices geprüft: 0 Filialen in Bingen/Oberwesel, ~2.700 DE-Preise der eigenen Ketten seit Mai, automatische Zuordnung zum Katalog unzuverlässig (Katalog ohne echte EAN)

## Offen
- Übernehmen-Knopf: erkennt nur etwa die Hälfte der REWE-Karten, Preis teils falsch (Streichpreis oder falscher Wert). Braucht eine gespeicherte echte Seite zum Nachschärfen
- Open Prices: Einbau erst mit echter EAN im Katalog sinnvoll (V29)

## Gelernt
- Siehe [[Stolperfallen]]: `flutter_secure_storage` im Web
