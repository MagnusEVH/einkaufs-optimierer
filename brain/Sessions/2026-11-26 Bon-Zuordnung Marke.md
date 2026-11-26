---
type: session
datum: 2026-11-26
agent: Claude Code (Opus 5.5)
prs: [22]
tags: [session]
---
# 2026-11-26 – Bon-Zuordnung bevorzugt die Marke

## Erledigt
- "KERRYGOLD BUTTER" vom Bon wurde "Deutsche Markenbutter" zugeordnet: Die Aliase "kerrygold" und "butter" sind gleich lang, die Eigenmarke gewann. Jetzt gewinnt bei Gleichstand das Produkt, dessen Name und Marke mehr Wörter des Texts enthalten (`CatalogService.matchCandidates`, Stufe 2).
- Test `app/test/catalog_match_test.dart`, schlägt ohne die Änderung fehl.

## Offen
- `Home.md` wird mit dem PR der dm-Regel aktualisiert (gleiche Datei, sonst Konflikt).

## Gelernt
- Gleich lange Alias-Treffer sind häufig bei "Marke + Warengruppe" auf Bons.
