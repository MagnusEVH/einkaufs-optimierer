---
type: baustelle
status: offen
prioritaet: niedrig
modell: mittel
aktualisiert: 2026-11-22
tags: [baustelle]
---
# CI-Analyze-Gate

`flutter analyze` läuft nicht im CI-Gate. Flutter-Version ist nicht fixiert (`stable`, aktuell 3.50.1). Seit 3.47 meldet analyze `material.dart` als veraltet (Info, in jeder Datei).

## Nächste Schritte
- [ ] Entscheiden: Infos ignorieren oder auf `material_ui` umstellen
- [ ] Danach `flutter analyze --no-fatal-infos` ins Gate
- [ ] Flutter-Version fixieren
