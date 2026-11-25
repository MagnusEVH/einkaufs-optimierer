// Phase 2b (V46): Icons, Meine Märkte, eigene Marktwahl, Einkaufsmodus, Treue-Apps.


import 'package:einkaufs_optimierer/core/models/list_item.dart';
import 'package:einkaufs_optimierer/core/models/product.dart';
import 'package:einkaufs_optimierer/core/models/store.dart';
import 'package:einkaufs_optimierer/core/models/user_preferences.dart';
import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:einkaufs_optimierer/core/services/item_icons.dart';
import 'package:einkaufs_optimierer/core/services/location_service.dart';
import 'package:einkaufs_optimierer/core/services/loyalty_service.dart';
import 'package:einkaufs_optimierer/core/services/my_stores_service.dart';
import 'package:einkaufs_optimierer/core/services/optimizer_service.dart';
import 'package:einkaufs_optimierer/core/services/preferences_storage.dart';
import 'package:einkaufs_optimierer/features/shopping_list/shopping_list_controller.dart';
import 'package:einkaufs_optimierer/features/trip/trip_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prodA = Product(id: 'a', gtinBarcode: '0001', name: 'Zzprobe Alpha', prices: {'lidl': 100, 'rewe': 300, 'netto': 90});
const _prodB = Product(id: 'b', gtinBarcode: '0002', name: 'Zzprobe Beta', prices: {'lidl': 300, 'rewe': 100, 'netto': 400});

const _lidl = Store(id: 's-lidl', chain: SupermarketChain.lidl, name: 'Lidl Test', address: 'A', latitude: 49.9667, longitude: 7.9000);
const _rewe = Store(id: 's-rewe', chain: SupermarketChain.rewe, name: 'REWE Test', address: 'B', latitude: 49.9668, longitude: 7.9001);
const _netto = Store(id: 's-netto', chain: SupermarketChain.netto, name: 'Netto Test', address: 'C', latitude: 49.9669, longitude: 7.9002);
const _user = UserLocation(latitude: 49.9667, longitude: 7.9000);

ShoppingListItem _item(String id, Product p) => ShoppingListItem(id: id, listId: 'l', rawText: p.name, matchedProduct: p);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PreferencesStorage.simulateReload();
    MyStoresService.reset();
    LoyaltyService.reset();
  });

  group('Icons wie bei Bring!', () {
    test('zusammengesetzte Namen bekommen das richtige Icon', () {
      final cases = {
        'Gurke': '🥒',
        'Hackfleisch gemischt (Rind & Schwein) 500g': '🥩',
        'Thunfisch in eigenem Saft 185g': '🐟',
        'Basmati Reis 1kg': '🍚',
        'Kartoffelchips Paprika 200g': '🥔',
        'Butterkeks 400g': '🍪',
        'Butterkäse Scheiben 400g': '🧀',
        'Butter Toastbrot 500g': '🍞',
        'Apfelsaft naturtrüb 100% 1L': '🧃',
        'Eistee Zitrone 1,5L': '🧋',
        'Vollmilchschokolade 100g': '🍫',
        'Spezialsalz Spülmaschine 2kg': '🧽',
        'Lachsschinken 100g': '🥓',
        'Veganes Hack 250g': '🌱',
        'Wassermelone': '🍉',
        'Rotwein': '🍷',
        'Paprika Dreierpack 500g': '🫑',
        'Rucola 125g': '🥬',
        'Gehackte Tomaten Dose 400g': '🥫',
        'saft': '🧃',
      };
      cases.forEach((text, icon) => expect(ItemIcons.iconFor(text), icon, reason: text));
    });

    test('jedes Katalogprodukt hat ein eigenes Icon', () async {
      await CatalogService.loadCatalog();
      expect(CatalogService.products, isNotEmpty);
      final generic = CatalogService.products.where((p) => ItemIcons.iconFor(p.name, product: p) == ItemIcons.fallbackIcon).map((p) => p.name);
      expect(generic, isEmpty);
    });

    test('kein Katalogprodukt widerspricht seiner eigenen Warengruppe', () async {
      await CatalogService.loadCatalog();
      final wrong = CatalogService.products.where((p) => ItemIcons.contradicts(p.name, p)).map((p) => p.name);
      expect(wrong, isEmpty);
    });

    test('Freitext ohne Katalog bekommt eine Warengruppe, Unbekanntes das Einkaufswagen-Icon', () {
      expect(ItemIcons.categoryFor('gurke').name, 'Obst & Gemüse');
      expect(ItemIcons.iconFor('Geschenkpapier'), ItemIcons.fallbackIcon);
      expect(ItemIcons.categoryFor('Geschenkpapier').id, ItemIcons.other.id);
    });
  });

  group('Meine Märkte und eigene Wahl', () {
    test('abgeschalteter Markt wird nicht genutzt', () {
      final r = OptimizerService.runLocal(
        userLocation: _user,
        items: [_item('1', _prodA)],
        preferences: const UserPreferences(maxStops: 1),
        stores: const [_lidl, _rewe, _netto],
        excludedStoreIds: {'s-netto'},
        now: DateTime(2026, 11, 25),
      );
      expect(r.stops.single.storeId, 's-lidl');
    });

    test('eigene Wahl verteilt auf genau diese Märkte und setzt die Listen-ID', () {
      final r = OptimizerService.runLocal(
        userLocation: _user,
        items: [_item('1', _prodA), _item('2', _prodB)],
        preferences: const UserPreferences(maxStops: 1),
        stores: const [_lidl, _rewe, _netto],
        fixedRoute: const [_rewe, _lidl],
        now: DateTime(2026, 11, 25),
      );
      expect(r.stops.map((s) => s.storeId), ['s-rewe', 's-lidl']);
      expect(r.stops[0].items.single.listItemId, '2');
      expect(r.stops[1].items.single.listItemId, '1');
    });

    test('eigene Wahl ohne Artikel für einen Markt lässt den Stopp weg', () {
      final r = OptimizerService.runLocal(
        userLocation: _user,
        items: [_item('1', _prodA)],
        preferences: const UserPreferences(),
        stores: const [_lidl, _rewe],
        fixedRoute: const [_lidl, _rewe],
        now: DateTime(2026, 11, 25),
      );
      expect(r.stops.map((s) => s.storeId), ['s-lidl']);
    });

    test('Reihenfolge der Warengruppen wird gespeichert', () async {
      final order = ItemIcons.defaultOrder.reversed.toList();
      await MyStoresService.setCategoryOrder('rewe', order);
      MyStoresService.reset();
      PreferencesStorage.simulateReload();
      await MyStoresService.load();
      expect(MyStoresService.categoryOrder('rewe'), order);
      expect(MyStoresService.categoryOrder('lidl'), ItemIcons.defaultOrder);
    });
  });

  group('Einkaufsmodus', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });
    tearDown(() => container.dispose());

    Future<void> startTrip() async {
      final list = container.read(shoppingListProvider.notifier);
      await list.loadInitialItems();
      list.clearList();
      list.addItem(_prodA.name, matchedProduct: _prodA);
      list.addItem(_prodB.name, matchedProduct: _prodB);
      final items = container.read(shoppingListProvider).items;
      final r = OptimizerService.runLocal(
        userLocation: _user,
        items: items,
        preferences: const UserPreferences(),
        stores: const [_lidl, _rewe],
        fixedRoute: const [_lidl, _rewe],
        now: DateTime(2026, 11, 25),
      );
      container.read(tripProvider.notifier).start(r);
    }

    test('Nicht da schiebt den Artikel zum nächsten Markt', () async {
      await startTrip();
      final trip = container.read(tripProvider)!;
      final first = trip.stops[0].items.single;
      container.read(tripProvider.notifier).markMissing(0, first.listItemId);
      final after = container.read(tripProvider)!;
      expect(after.stops[0].items, isEmpty);
      expect(after.stops[1].items.map((i) => i.listItemId), contains(first.listItemId));
      // Preis der neuen Kette statt des alten (Alpha: Lidl 1,00 €, REWE 3,00 €)
      expect(after.stops[1].items.firstWhere((i) => i.listItemId == first.listItemId).priceCents, 300);
    });

    test('Abschluss entfernt nur Gekauftes von der Liste', () async {
      await startTrip();
      final trip = container.read(tripProvider)!;
      final bought = trip.stops[0].items.single.listItemId;
      container.read(tripProvider.notifier).toggleDone(0, bought);
      container.read(tripProvider.notifier).finish();
      final ids = container.read(shoppingListProvider).items.map((i) => i.id);
      expect(ids, isNot(contains(bought)));
      expect(ids.length, 1);
      expect(container.read(tripProvider), isNull);
    });

    test('laufender Einkauf übersteht ein Neuladen', () async {
      await startTrip();
      final trip = container.read(tripProvider)!;
      container.read(tripProvider.notifier).toggleDone(0, trip.stops[0].items.single.listItemId);
      await Future<void>.delayed(Duration.zero);
      PreferencesStorage.simulateReload();
      final fresh = ProviderContainer();
      addTearDown(fresh.dispose);
      fresh.read(tripProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final loaded = fresh.read(tripProvider);
      expect(loaded, isNotNull);
      expect(loaded!.doneCount, 1);
      expect(loaded.stops.length, 2);
    });
  });

  group('Treue-Apps per Scan', () {
    test('Bon mit Bonuszeilen: gescannt, Guthaben übernommen', () async {
      final rec = await LoyaltyService.recordFromReceipt(SupermarketChain.rewe, DateTime(2026, 11, 24), {
        'detected': true,
        'program': 'rewe',
        'earned_cents': 45,
        'balance_cents': 1279,
      });
      expect(rec!.scanned, isTrue);
      expect(LoyaltyService.balance('rewe')!.valueCents, 1279);
      expect(LoyaltyService.balance('rewe')!.source, 'Kassenbon');
    });

    test('Bon ohne Bonuszeile: als nicht gescannt vermerkt', () async {
      final rec = await LoyaltyService.recordFromReceipt(SupermarketChain.lidl, DateTime(2026, 11, 24), {'detected': false});
      expect(rec!.programId, 'lidl_plus');
      expect(rec.scanned, isFalse);
    });

    test('Kassen-Hinweis gibt es für REWE, nicht für ALDI', () {
      expect(LoyaltyService.forChain(SupermarketChain.rewe)?.appLink, 'https://www.rewe.de/bonus/einloesen');
      expect(LoyaltyService.forChain(SupermarketChain.aldi_sued), isNull);
    });
  });
}
