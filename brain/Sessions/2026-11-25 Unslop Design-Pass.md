---
type: session
datum: 2026-11-25
agent: Claude Code (Opus 5.5)
prs: []
tags: [session, design]
---
# 2026-11-25 – Unslop Design-Pass

Design-Durchgang nach dem Skill unslop von Damir Sokolovsky (@heydamir, CC BY 4.0).

## Richtung
- Produkt: Einkaufsliste, die auf die günstigsten Märkte in der Nähe aufteilt und im Laden je Markt abhakt
- Charakter: sparsam, genau, ein bisschen warm
- Welt: Kassenbon und Einkaufszettel
- Momente: Artikel-Icons in der Liste, Abschluss als Kassenbon
- Signatur: Preise und Zahlen in Tabellenziffern, rechtsbündig, Format `1,49 €`

## Erledigt
- [Theme](../../app/lib/core/theme/app_theme.dart): leicht warme Neutrale, drei Textrollen, Akzent `#047857` (weiße Schrift 5,5:1), Haarlinien, Gewichte 400–600, `AppText.figure`, Abschnittsköpfe ohne Großbuchstaben
- Alle Screens: Gewichte 700–900 → 600, Großbuchstaben-Labels → Satzschreibung, feste Farbcodes und `Colors.grey/red` → Theme, Schriftgrößen 9–12,5 → 12/13, Abstände auf 4er-Raster
- Angebote: Verlauf mit grünem Schatten → ruhige Zahlenkarte; Preise mit Komma über `euro()`; Ketten-Farben aus Listen entfernt; Aussage „Coupons fließen in die Planung ein“ entfernt (Optimierer nutzt keine Coupons)
- Onboarding: Emoji raus, Überschrift sagt, was die App tut, nummerierte Schritte, Knopf „Liste anlegen“
- Abschluss: Kassenbon mit gezackter Kante, Ersparnis als einzige grüne Zahl
- Einkaufsmodus „Vor der Kasse“ und Hinweisboxen neutral statt blau
- Profil: farbige Abschnitts-Icons und Emoji in Labels raus
- `bon.html`, `uebernehmen.html` auf dieselben Werte

## Offen
- Im Browser nicht angesehen (Screenshots hingen), Sichtprüfung nach Deploy
- Keine eigene Schrift gebündelt (Mono für Preise wäre ein Download), Signatur über Tabellenziffern
- `admin/` nicht angefasst (nur Debug)

## Gelernt
- `dart fix` macht Katalog-Fallbacks `const` → Listen unveränderlich, Laufzeitrisiko; zurückgenommen
