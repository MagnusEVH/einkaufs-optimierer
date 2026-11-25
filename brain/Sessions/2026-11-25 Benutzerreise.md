---
type: session
datum: 2026-11-25
agent: Claude Code (Opus 5.5)
prs: []
tags: [session, ux]
---
# 2026-11-25 – Benutzerreise neu

Ablauf jetzt: **Liste bauen → Einkauf planen → Einkaufsmodus je Markt → Abschluss mit Bon-Scan**. Branch `claude/benutzerreise`.

## Erledigt
- Einheitliches Design: [app_theme.dart](../../app/lib/core/theme/app_theme.dart) (Farben, Abstände, Radien, Schrift, Demo-Abzeichen). iOS-Farben und `Colors.teal` ersetzt.
- Icons pro Artikel wie bei Bring!: [item_icons.dart](../../app/lib/core/services/item_icons.dart), alle Katalogprodukte haben ein eigenes Icon. Liste als Kacheln oder Zeilen, gruppiert nach Warengruppe, „Bitte prüfen“ oben (auch wenn Text und Produkt-Warengruppe sich widersprechen, z. B. „saft“ → Thunfisch).
- Angebotsstand je Kette über der Liste, Tippen öffnet die Wochenrunde.
- Planung: Vorschläge zum Wählen (empfohlen, ein Markt, eigene Wahl bis 3 Märkte), Vergleich inkl. Fahrtkosten, Weg zwischen Märkten ehrlich (zu Fuß nur bis 800 m).
- Meine Märkte: Filialen an/aus, Reihenfolge der Warengruppen je Kette ([my_stores_screen.dart](../../app/lib/features/stores_map/my_stores_screen.dart)). Optimierer nutzt nur aktive Märkte.
- Einkaufsmodus ([trip_screen.dart](../../app/lib/features/trip/trip_screen.dart)): Abhaken sofort, „Nicht da“ schiebt zum nächsten Markt (mit dessen Preis), Navigation (iPhone: Apple Karten), Kassen-Hinweis mit „App öffnen“. Zustand übersteht Neuladen.
- Meine Apps ehrlich: App öffnen per Universal Link (REWE `rewe.de/bonus/einloesen`, Rossmann) oder App Store. Guthaben per Screenshot-Scan (`konto.html`) oder Kassenbon (Bonus-/Punktezeilen in `bon/parse.js`).
- Entfernt: tote `settings_screen.dart`, Bon-Attrappe `price_report_screen.dart`, alter Abschluss-Dialog.
- Standortabfrage endet spätestens nach 12 s (sonst hing die Planung bei unbeantworteter Browser-Frage).
- Tests: 69 Flutter-Tests, neuer Node-Test `test_konto_parse.js`. Im lokalen Build in Chrome geprüft.

## Offen
- Praxistest auf dem iPhone: öffnet „App öffnen“ bei REWE direkt die App? Funktioniert der Screenshot-Scan mit der echten REWE- und PAYBACK-App?
- Bonus-Zeilen auf echten REWE-Bons prüfen (Muster sind geschätzt).
- Karte fragt den Standort weiter beim App-Start (V19), weil alle Tabs gleichzeitig gebaut werden.
- Alter Fake-Code in `WalletService` (linkApp/syncApp) wird von der Oberfläche nicht mehr genutzt, Tests hängen noch daran.

## Gelernt
- Händler veröffentlichen ihre iPhone-App-Links unter `/.well-known/apple-app-site-association`, App-Store-Nummern liefert `itunes.apple.com/lookup?bundleId=…`.
- Fremde Apps lassen sich nicht auslesen, nur öffnen. Punktestand daher nur per Scan.
