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

## Grundartikel und Sorte (Branch `claude/grundartikel`)
- Fehler: Knopf "Stück" tat nichts (1 Stück galt als keine Angabe). Jetzt: keine Angabe = ohne Einheit, "1×" ist eine Angabe
- Fehler aus #38: gewähltes Produkt wurde vom Optimierer überschrieben (er erkannte die Wahl am vollen Namen). Neu: Merkmal `pinned`, auf dem Server = `product_id` gesetzt
- Suche zeigt Grundartikel (`core/services/item_groups.dart`, Regeln mit Reihenfolge): "eier" → "Eier · 3 Sorten · ab …"
- Antippen → Artikel-Blatt mit Sorte (`variant_picker.dart`: Egal = günstigste, oder Bodenhaltung/Freiland/Bio mit Preis) und Menge
- Design-Pass durch Agent (Sorte, Menge, Vorschläge)
- 156 Tests grün vor dem Design-Pass
- Design-Pass (Agent): Sorte als Auswahlzeilen mit Häkchen, vollem Produktnamen und Preis; Menge als Feld mit Plus/Minus, Einheiten und Schnellwahl; Vorschläge mit 'n Sorten · ab …'. 156 Tests grün
- Offen: 7 Einheiten passen bei 390 px nicht ganz (seitlich scrollen); bei vielen Sorten (Käse, Kaffee) muss man zu 'Fertig' scrollen
