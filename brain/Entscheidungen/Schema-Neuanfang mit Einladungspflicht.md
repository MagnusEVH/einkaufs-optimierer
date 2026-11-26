---
type: entscheidung
status: gilt
datum: 2026-11-26
tags: [entscheidung]
---
# Schema-Neuanfang mit Einladungspflicht

**Kontext:** Die 7 alten Migrationen waren nicht installierbar und hatten Rechte-Lücken. Der Publishable Key steht öffentlich im Build, offene Registrierung würde Fremden Konten und Speicher geben.

**Entscheidung:** Alte Migrationen nach `supabase/archiv/`, neue schlanke Basis nur für Konten, Haushalte und Liste. Katalog, Filialen und Angebote bleiben in `app/assets`. Registrierung nur mit Einladungscode oder mit einer E-Mail auf `private.signup_allowlist` (nur per SQL). Keine Ausnahme für das erste Konto (sonst könnte ein Fremder zuerst kommen). Codes nur als SHA-256, der Klartext wird aus den Kontodaten entfernt. Haushalt erst nach bestätigter E-Mail. Anonyme Konten abgelehnt. Rechte werden mit PGlite getestet (kein Docker nötig), Schritt in der CI.

**Folgen:** Belege, Preise und weitere Tabellen kommen als eigene, additive Migrationen. Jede neue Tabelle braucht einen Negativtest in `supabase/tests/rls.test.mjs`.
