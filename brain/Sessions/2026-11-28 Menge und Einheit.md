---
type: session
datum: 2026-11-28
modell: opus
status: erledigt
---

# 2026-11-28 Menge und Einheit

## Erledigt
- Zwei-Geräte-Test bestanden (iPhone + PC sehen dieselbe Liste)
- Liste zeigt nur das Ding an sich: gewähltes Produkt → Name ohne Größe/Verpackung ("Erdbeeren 500g" → "Erdbeeren"), Marke bleibt ("Coca-Cola Original")
- Menge freiwillig: beim Eintippen gelesen ("500 g Erdbeeren", "Milch 2 l", "3 Äpfel", "2x Milch") oder im Artikel-Blatt (Einheit, Schnellwahl, Plus/Minus, "Keine Angabe")
- Ohne Angabe steht nichts neben dem Namen, Plus/Minus aus der Listenzeile entfernt
- Optimierer rechnet Packungen: 750 g bei 500-g-Schale = 2
- Migration 4: Spalte `unit` (stk, g, kg, ml, l, pck, bund), `min_app_version` 2. 29 RLS-Tests, 150 Flutter-Tests grün
- Neu: `core/models/item_amount.dart`, `features/shopping_list/amount_editor.dart`

## Offen
- [ ] Migration live: erst Spalte (vor dem Merge), `min_app_version` 2 erst nach dem Deploy
- [ ] PR mergen, auf dem iPhone ausprobieren

## Gelernt
- Marke wegschneiden zerstört Markenprodukte ("Pringles Original" → "Original"), deshalb bleibt sie
