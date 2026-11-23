---
type: session
datum: 2026-11-23
agent: Claude Code (Opus)
prs: []
tags: [session]
---
# 2026-11-23 – Ehrliche Texte und Kartenlizenz

Branch: `claude/phase0-ehrliche-texte`

## Erledigt
- Onboarding: keine "echten Live-Preise" mehr, Treue-Apps als "geplant"/Demo gekennzeichnet
- Meine Apps, Wallet, Profil: keine Aussagen mehr zu Secure Enclave, Verschlüsselung oder Synchronisierung, stattdessen "Demo-Verknüpfung"
- Konto löschen: Dialog und Meldung sagen ehrlich, dass in der Demo keine Serverdaten existieren
- Preisquellen und "verifiziert"-Label → "Beispieldaten (Demo)"
- Karte: Namensnennung OSM/CARTO/Esri unten links (`tileAttributionFor` in `map_tile_style.dart`)
- Entwickler-Cockpit im Profil nur noch im Debug-Build (`kDebugMode`)
- `flutter analyze` unverändert (nur Infos), `flutter test` und Backend-Tests grün

## Offen
- PR erstellen und mergen, Live-Seite prüfen
- Optimierer-Korrektheit (nächste Phase)

## Gelernt
- Einige Dart-Dateien haben CRLF-Zeilenenden: mehrzeilige Ersetzungen per Skript schlagen dort fehl
