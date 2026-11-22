---
type: entscheidung
status: gilt
datum: 2026-11-22
tags: [entscheidung]
---
# Carto-Key nur per dart-define

**Kontext:** Der Key stand base64-kodiert im Quellcode.

**Entscheidung:** Key nur per `--dart-define=CARTO_API_KEY` bzw. GitHub-Secret; ohne Key OSM-Kacheln.

**Folgen:** Bei Flutter Web bleibt der Key im Bundle sichtbar → bei Carto auf Domain beschränken.
