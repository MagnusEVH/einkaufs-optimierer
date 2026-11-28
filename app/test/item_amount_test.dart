// Menge auf der Liste: Eingabe lesen, Namen kürzen, Packungen rechnen.

import 'package:einkaufs_optimierer/core/models/item_amount.dart';
import 'package:einkaufs_optimierer/core/models/product.dart';
import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

Product _p(String name, {String? brand, double amount = 1, String unit = 'piece'}) =>
    Product(id: name, gtinBarcode: '', name: name, brand: brand, quantityAmount: amount, quantityUnit: unit);

void main() {
  group('Eingabe', () {
    void expectParsed(String input, String name, String label) {
      final p = parseItemInput(input);
      expect(p.name, name, reason: input);
      expect(p.amount.label, label, reason: input);
    }

    test('Ohne Menge: nur das Ding', () {
      expectParsed('Erdbeeren', 'Erdbeeren', '');
      expectParsed('  Milch 1,5 %  ', 'Milch 1,5 %', '');
      expectParsed('7Up', '7Up', '');
      // "X" am Wortanfang ist kein "mal"
      expectParsed('2 Xylit-Kaugummi', 'Xylit-Kaugummi', '2×');
    });
    test('Menge vorne', () {
      expectParsed('500 g Erdbeeren', 'Erdbeeren', '500 g');
      expectParsed('500g erdbeeren', 'Erdbeeren', '500 g');
      expectParsed('1,5 kg Kartoffeln', 'Kartoffeln', '1,5 kg');
      expectParsed('2 Liter Milch', 'Milch', '2 l');
      expectParsed('3 Äpfel', 'Äpfel', '3×');
      expectParsed('2x Milch', 'Milch', '2×');
      expectParsed('2 x Milch', 'Milch', '2×');
      expectParsed('2 Packungen Nudeln', 'Nudeln', '2 Packungen');
      expectParsed('1 Bund Petersilie', 'Petersilie', '1 Bund');
    });
    test('Menge hinten', () {
      expectParsed('Erdbeeren 500g', 'Erdbeeren', '500 g');
      expectParsed('Mehl 1 kg', 'Mehl', '1 kg');
      expectParsed('Milch x2', 'Milch', '2×');
      expectParsed('Sahne 200 ml', 'Sahne', '200 ml');
    });
    test('Einheit, die nach einem Wort aussieht, bleibt Name', () {
      expectParsed('2 Lauch', 'Lauch', '2×');
      expectParsed('Gurken', 'Gurken', '');
    });
    test('1500 g wird 1,5 kg, 1 Stück ist keine Angabe', () {
      expectParsed('1500 g Mehl', 'Mehl', '1,5 kg');
      expectParsed('1 Gurke', 'Gurke', '');
    });
  });

  group('Name auf der Liste', () {
    test('Größe, Prozent, Sortierung und Verpackung fallen weg, Marke bleibt', () {
      expect(genericName(_p('Erdbeeren 500g')), 'Erdbeeren');
      expect(genericName(_p('Skyr Vanille 500g', brand: 'Eigenmarke')), 'Skyr Vanille');
      expect(genericName(_p('Speisequark 20% 500g')), 'Speisequark');
      expect(genericName(_p('Freilandeier Gr. M/L 10er')), 'Freilandeier');
      expect(genericName(_p('Heinz Tomato Ketchup 500ml', brand: 'Heinz')), 'Heinz Tomato Ketchup');
      expect(genericName(_p('Coca-Cola Original 1,5L', brand: 'Coca-Cola')), 'Coca-Cola Original');
      expect(genericName(_p('Sprite 1,5L', brand: 'Sprite')), 'Sprite');
      expect(genericName(_p('Toilettenpapier 3-lagig 8x200 Blatt')), 'Toilettenpapier');
      expect(genericName(_p('Tempo Taschentücher 30x10er')), 'Tempo Taschentücher');
      expect(genericName(_p('Zitronen Netz 500g')), 'Zitronen');
      expect(genericName(_p('Gehackte Tomaten Dose 400g')), 'Gehackte Tomaten');
      expect(genericName(_p('Kamillentee 25 Beutel')), 'Kamillentee');
      expect(genericName(_p('Alufolie 30m')), 'Alufolie');
      expect(genericName(_p('Spaghetti No. 5 500g')), 'Spaghetti No. 5');
    });
    test('Alle Katalog-Produkte haben einen sinnvollen Namen', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await CatalogService.loadCatalog();
      for (final p in CatalogService.products) {
        final g = genericName(p);
        expect(g.trim(), isNotEmpty, reason: p.name);
        expect(RegExp(r'\d+\s*(g|ml|kg)\b').hasMatch(g), isFalse, reason: '${p.name} → $g');
      }
    });
  });

  group('Packungen', () {
    final schale = _p('Erdbeeren 500g', amount: 500, unit: 'g');
    final milch = _p('Milch 1L', amount: 1, unit: 'l');
    test('Gewicht und Volumen werden auf Packungen gerundet', () {
      expect(packsNeeded(const ItemAmount(750, AmountUnit.g), schale), 2);
      expect(packsNeeded(const ItemAmount(500, AmountUnit.g), schale), 1);
      expect(packsNeeded(const ItemAmount(1, AmountUnit.kg), schale), 2);
      expect(packsNeeded(const ItemAmount(100, AmountUnit.g), schale), 1);
      expect(packsNeeded(const ItemAmount(2.5, AmountUnit.l), milch), 3);
    });
    test('Stück, Packung, keine Angabe und unpassende Einheit', () {
      expect(packsNeeded(ItemAmount.none, schale), 1);
      expect(packsNeeded(const ItemAmount(3, AmountUnit.stk), schale), 3);
      expect(packsNeeded(const ItemAmount(2, AmountUnit.pck), milch), 2);
      expect(packsNeeded(const ItemAmount(500, AmountUnit.g), milch), 1);
      expect(packsNeeded(const ItemAmount(500, AmountUnit.g), null), 1);
    });
  });

  test('Plus/Minus in Schritten der Einheit, über Grenzen hinweg', () {
    expect(const ItemAmount(950, AmountUnit.g).stepBy(1).label, '1 kg');
    expect(const ItemAmount(1, AmountUnit.kg).stepBy(-1).label, '500 g');
    expect(const ItemAmount(50, AmountUnit.g).stepBy(-1).label, '50 g');
    // "1 Stück" ausdrücklich gewählt bleibt sichtbar (Knopf "Stück" tut etwas)
    expect(const ItemAmount(2, AmountUnit.stk).stepBy(-1).label, '1×');
    expect(const ItemAmount(1, AmountUnit.stk).isDefault, isFalse);
    expect(ItemAmount.none.stepBy(1).label, '2×');
  });
}
