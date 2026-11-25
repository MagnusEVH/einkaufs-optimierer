---
type: session
datum: 2026-11-25
agent: Claude Code (Opus 5.5)
prs: []
tags: [session, ux, performance]
---
# 2026-11-25 – Feinschliff nach Praxistest

Folgt auf [[2026-11-25 Benutzerreise]] (PR #16, gemergt). Branch `claude/feinschliff`.

## Erledigt
- **Flüssiger als Home-Bildschirm-App:**
  - WebAssembly-Build (`flutter build web --wasm`, auch in CI). Ältere Browser fallen automatisch auf JavaScript zurück.
  - Eigener Cache-Worker [sw.js](../../app/web/sw.js): Programm, Engine, Schriften und Emoji-Schrift ab dem 2. Start sofort aus dem Cache, Update im Hintergrund. Startseite immer zuerst aus dem Netz. Flutters veralteter Service Worker ist abgeschaltet ([flutter_bootstrap.js](../../app/web/flutter_bootstrap.js)).
  - Tabs werden erst beim ersten Öffnen gebaut (Karte und Standort nicht mehr beim Start, erledigt V19), Startdaten laden parallel.
  - `flutter_secure_storage` entfernt (verhinderte WebAssembly, nur noch für die Übernahme vom 24.11. nötig).
- **Onboarding:** ein Bildschirm mit drei Schritten statt drei Seiten zum Wischen.
- **Kacheln:** nicht volle Reihen werden auf die ganze Breite gestreckt (breite Kachel, Icon links).
- **Guthaben-Scan in der App:** „Stand scannen“ → Screenshot wählen → gespeichert. Texterkennung über [konto/scan.js](../../app/web/konto/scan.js) per `dart:js_interop`. Beim Zurückkommen aus der Händler-App (15 min) bietet die App den Scan an. `konto.html` entfernt.
- Korrektur: Emoji kommen aus Noto Color Emoji (Google), nicht aus dem System.

## Offen
- Auf dem iPhone prüfen: Startzeit ab dem 2. Start, Scrollen, Scan aus der Fotomediathek.

## Gelernt
- `dart.library.js_interop` für bedingte Importe (Tests laufen ohne Browser).
- `window.eoScanBalance` im Browser mit einem Canvas-Bild testbar (1,4 s).
