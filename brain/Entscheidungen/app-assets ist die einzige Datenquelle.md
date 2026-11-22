---
type: entscheidung
status: gilt
datum: 2026-11-22
tags: [entscheidung]
---
# app-assets ist die einzige Datenquelle

**Kontext:** `test_data/` und `app/assets/` enthielten identische JSON-Dateien.

**Entscheidung:** Nur `app/assets/`; Node-Tests lesen dieselben Dateien.

**Folgen:** Tests dürfen diese Dateien nicht überschreiben (Temp-Ordner).
