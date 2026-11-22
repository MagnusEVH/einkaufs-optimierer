import 'package:einkaufs_optimierer/core/models/list_item.dart';
import 'package:einkaufs_optimierer/core/models/product.dart';
import 'package:einkaufs_optimierer/core/models/store.dart';
import 'package:einkaufs_optimierer/core/models/user_preferences.dart';
import 'package:einkaufs_optimierer/core/services/location_service.dart';
import 'package:einkaufs_optimierer/core/services/optimizer_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Bewusst ungewöhnliche Namen, damit keine Wochenangebote greifen.
const _prodA = Product(
  id: 'a',
  gtinBarcode: '0001',
  name: 'Zzprobe Alpha',
  prices: {'lidl': 100, 'rewe': 300},
);
const _prodB = Product(
  id: 'b',
  gtinBarcode: '0002',
  name: 'Zzprobe Beta',
  prices: {'lidl': 300, 'rewe': 100},
);

const _lidl = Store(
  id: 's-lidl',
  chain: SupermarketChain.lidl,
  name: 'Lidl Test',
  address: 'Teststr. 1',
  latitude: 49.9667,
  longitude: 7.9000,
  clusterNum: 1,
);
const _rewe = Store(
  id: 's-rewe',
  chain: SupermarketChain.rewe,
  name: 'REWE Test',
  address: 'Teststr. 2',
  latitude: 49.9668,
  longitude: 7.9001,
  clusterNum: 1,
);
const _user = UserLocation(latitude: 49.9667, longitude: 7.9000);

ShoppingListItem _item(String id, Product p, {double qty = 1}) =>
    ShoppingListItem(id: id, listId: 'l', rawText: p.name, matchedProduct: p, quantity: qty);

void main() {
  test('leere Liste wirft eine Exception', () {
    expect(
      OptimizerService.optimizeShoppingList(
        userLocation: _user,
        items: const [],
        preferences: const UserPreferences(),
        availableStores: const [_lidl, _rewe],
      ),
      throwsException,
    );
  });

  test('ein Artikel: SINGLE_STORE im günstigsten Markt', () async {
    final r = await OptimizerService.optimizeShoppingList(
      userLocation: _user,
      items: [_item('1', _prodA)],
      preferences: const UserPreferences(),
      availableStores: const [_lidl, _rewe],
    );
    expect(r.isMultiStore, isFalse);
    expect(r.stops, hasLength(1));
    expect(r.stops.first.chain, SupermarketChain.lidl);
    expect(r.summary.totalBasketPriceCents, 100);
  });

  test('Menge multipliziert den Preis', () async {
    final r = await OptimizerService.optimizeShoppingList(
      userLocation: _user,
      items: [_item('1', _prodA, qty: 3)],
      preferences: const UserPreferences(),
      availableStores: const [_lidl, _rewe],
    );
    expect(r.summary.totalBasketPriceCents, 300);
  });

  test('zwei Artikel in benachbarten Märkten: MULTI_STORE spart Geld', () async {
    final r = await OptimizerService.optimizeShoppingList(
      userLocation: _user,
      items: [_item('1', _prodA), _item('2', _prodB)],
      preferences: const UserPreferences(),
      availableStores: const [_lidl, _rewe],
    );
    expect(r.isMultiStore, isTrue);
    expect(r.stops, hasLength(2));
    expect(r.summary.totalBasketPriceCents, 200);
    expect(r.summary.netSavingsCents, greaterThan(0));
    expect(r.summary.travelPenaltyCents, 0); // gleicher Cluster
  });

  test('maxStops = 1 erzwingt SINGLE_STORE', () async {
    final r = await OptimizerService.optimizeShoppingList(
      userLocation: _user,
      items: [_item('1', _prodA), _item('2', _prodB)],
      preferences: const UserPreferences(maxStops: 1),
      availableStores: const [_lidl, _rewe],
    );
    expect(r.isMultiStore, isFalse);
    expect(r.stops, hasLength(1));
    expect(r.summary.totalBasketPriceCents, 400);
  });

  test('anchorStore wird als einziger Einzelmarkt verwendet', () async {
    final r = await OptimizerService.optimizeShoppingList(
      userLocation: _user,
      items: [_item('1', _prodA)],
      preferences: const UserPreferences(maxStops: 1),
      availableStores: const [_lidl, _rewe],
      anchorStore: _rewe,
    );
    expect(r.stops.first.storeId, 's-rewe');
    expect(r.summary.totalBasketPriceCents, 300);
  });
}
