---
type: entscheidung
status: gilt
datum: 2026-11-22
tags: [entscheidung]
---
# Pages-Deploy in eigenem Job

**Kontext:** `deploy-pages` fand das Artefakt 1 s nach dem Upload im selben Job nicht; Re-runs hinterließen mehrere Artefakte.

**Entscheidung:** Jobs `test` → `build` → `deploy`; Artefaktname pro Versuch (`github-pages-<attempt>`).

**Folgen:** Fehlgeschlagene Deploys lassen sich wieder per Re-run starten.
