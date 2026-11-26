---
type: entscheidung
status: gilt
datum: 2026-11-26
tags: [entscheidung]
---
# Schema-Neuanfang mit Einladungspflicht

**Kontext:** Die 7 alten Migrationen waren nicht installierbar und hatten Rechte-Lücken. Der Publishable Key steht öffentlich im Build, offene Registrierung würde Fremden Konten und Speicher geben.

**Entscheidung:** Alte Migrationen nach `supabase/archiv/`, neue schlanke Basis nur für Konten, Haushalte und Liste. Katalog, Filialen und Angebote bleiben in `app/assets`. Registrierung nur mit Einladungscode (Ausnahme: erstes Konto). Codes nur als SHA-256 gespeichert. Rechte werden mit PGlite getestet (kein Docker nötig), Schritt in der CI.

**Folgen:** Belege, Preise und weitere Tabellen kommen als eigene, additive Migrationen. Jede neue Tabelle braucht einen Negativtest in `supabase/tests/rls.test.mjs`.
