// Grundartikel: Suche zeigt "Eier", danach Sorte wählen.

import 'package:einkaufs_optimierer/core/models/list_item.dart';
import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:einkaufs_optimierer/core/services/item_groups.dart';
import 'package:einkaufs_optimierer/features/shopping_list/amount_editor.dart';
import 'package:einkaufs_optimierer/core/models/item_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await CatalogService.loadCatalog();
  });

  ItemGroup group(String name) => ItemGroups.all.firstWhere((g) => g.name == name);

  test('"eier" zeigt genau einen Vorschlag: Eier mit drei Sorten', () {
    final found = ItemGroups.search('eier');
    expect(found.first.name, 'Eier');
    expect(found.where((g) => g.name.contains('Eier')).length, 1);
    final eier = group('Eier');
    expect(eier.products.length, 3);
    expect(eier.products.map(eier.variantLabel).toSet(), {'Bodenhaltung', 'Freiland', 'Bio'});
  });

  test('Suchwörter führen zum Grundartikel', () {
    expect(ItemGroups.search('spaghetti').first.name, 'Nudeln');
    expect(ItemGroups.search('milch').first.name, 'Milch');
    expect(ItemGroups.search('ei').first.name, 'Eier');
    expect(ItemGroups.search('erdbeeren').first.name, 'Erdbeeren');
  });

  test('Ähnliche Wörter landen nicht in der falschen Gruppe', () {
    String of(String productName) =>
        ItemGroups.groupOf(CatalogService.products.firstWhere((p) => p.name == productName))!.name;
    expect(of('Butterkäse Scheiben 400g'), 'Käse');
    expect(of('Gehackte Tomaten Dose 400g'), 'Dosentomaten');
    expect(of('Milka Alpenmilch Schokolade 100g'), 'Schokolade');
    expect(of('Müller Milchreis Zimt 200g'), 'Milchreis & Dessert');
    expect(of('Thunfisch in Sonnenblumenöl 185g'), 'Thunfisch');
    expect(of('Paprika Dreierpack 500g'), 'Paprika');
    expect(of('Kartoffelchips Paprika 200g'), 'Kartoffelchips');
    expect(of('Bärenmarke Frische Alpenmilch 3,8% 1L'), 'Milch');
    expect(of('Veganes Hack 250g'), 'Vegane Alternativen');
  });

  test('Jedes Produkt gehört zu genau einem Grundartikel, Sorten-Namen sind eindeutig genug', () {
    final all = ItemGroups.all;
    final count = all.fold<int>(0, (n, g) => n + g.products.length);
    expect(count, CatalogService.products.length);
    for (final g in all.where((g) => g.hasVariants)) {
      for (final p in g.products) {
        expect(g.variantLabel(p).trim(), isNotEmpty, reason: '${g.name}: ${p.name}');
      }
    }
  });

  test('Gewählte Sorte bleibt gemerkt, "Egal" lässt die App suchen', () {
    final eier = group('Eier');
    final bio = eier.products.firstWhere((p) => p.isBio);
    const base = ShoppingListItem(id: '1', listId: 'l', rawText: 'Eier');
    final pinned = base.withVariant(bio);
    expect(pinned.pinned, isTrue);
    expect(pinned.matchedProduct, bio);
    final any = pinned.withVariant(null, fallback: eier.products.first);
    expect(any.pinned, isFalse);
    expect(ShoppingListItem.fromJson(pinned.toJson(), matched: bio).pinned, isTrue);
  });

  testWidgets('Knopf "Stück" setzt eine sichtbare Menge', (tester) async {
    ItemAmount? got;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AmountEditor(amount: ItemAmount.none, suggested: AmountUnit.g, onChanged: (a) => got = a),
      ),
    ));
    await tester.tap(find.byKey(const Key('amount_unit_stk')));
    expect(got, isNotNull);
    expect(got!.isDefault, isFalse);
    expect(got!.label, '1×');
  });
}
