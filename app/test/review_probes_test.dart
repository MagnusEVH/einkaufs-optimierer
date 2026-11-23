// Review-Sonden A1–A12 aus dem Review vom 2026-11-22 als Tests gegen den
// echten App-Code (Katalog und Angebote aus app/assets, Filialen der Karte).

import 'package:einkaufs_optimierer/core/models/list_item.dart';
import 'package:einkaufs_optimierer/core/models/product.dart';
import 'package:einkaufs_optimierer/core/models/store.dart';
import 'package:einkaufs_optimierer/core/models/user_preferences.dart';
import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:einkaufs_optimierer/core/services/location_service.dart';
import 'package:einkaufs_optimierer/core/services/optimizer_service.dart';
import 'package:einkaufs_optimierer/core/services/wallet_service.dart';
import 'package:einkaufs_optimierer/features/stores_map/data/rlp_stores.dart';
import 'package:flutter_test/flutter_test.dart';

const _bingen = UserLocation(latitude: 49.9667, longitude: 7.9000);
const _oberwesel = UserLocation(latitude: 50.1090, longitude: 7.7270);
const _koeln = UserLocation(latitude: 50.9375, longitude: 6.9603);
final _now = DateTime.utc(2026, 11, 23, 12);

int _n = 0;
ShoppingListItem _free(String text, {double qty = 1, bool checked = false}) => ShoppingListItem(
      id: 'i${_n++}',
      listId: 'l',
      rawText: text,
      matchedProduct: CatalogService.matchRawText(text),
      quantity: qty,
      isChecked: checked,
    );

Future<dynamic> _run(
  List<ShoppingListItem> items, {
  UserLocation at = _bingen,
  UserPreferences prefs = const UserPreferences(),
  DateTime? now,
}) =>
    OptimizerService.optimizeShoppingList(
      userLocation: at,
      items: items,
      preferences: prefs,
      now: now ?? _now,
    );

Product _byName(String name) => CatalogService.products.firstWhere((p) => p.name == name);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await CatalogService.loadCatalog();
    await WalletService.loadScrapedOffers(forceRefresh: true);
  });

  test('A1: dm/Rossmann ohne Preise gewinnen nicht per Pauschalpreis', () async {
    final r = await _run([_free('somat tabs'), _free('kerrygold'), _free('pizza salami')]);
    for (final stop in r.stops) {
      expect(stop.chain, isNot(anyOf(SupermarketChain.dm, SupermarketChain.rossmann)));
      for (final it in stop.items) {
        expect(it.unitPriceCents, isNot(199), reason: 'kein Pauschalpreis');
      }
    }
    expect(r.unpricedItems, isEmpty);
  });

  test('A2: weit entfernter Standort bekommt keine Route nach Bingen', () async {
    expect(_run([_free('bananen')], at: _koeln), throwsException);
  });

  test('A3: Nutzer in Oberwesel bleibt in Oberwesel', () async {
    final r = await _run([_free('bananen'), _free('vollmilch')], at: _oberwesel);
    for (final stop in r.stops) {
      final d = OptimizerService.haversineMeters(
          _oberwesel.latitude, _oberwesel.longitude, stop.latitude, stop.longitude);
      expect(d, lessThan(5000));
    }
  });

  test('A4: Einstellungen wirken (Ketten und Kilometerkosten)', () async {
    final items = [_free('bananen'), _free('vollmilch'), _free('kerrygold')];
    final onlyLidl = await _run(items, prefs: const UserPreferences(preferredChains: ['lidl']));
    expect(onlyLidl.stops.every((s) => s.chain == SupermarketChain.lidl), isTrue);

    final cheap = await _run(items, prefs: const UserPreferences(costPerKmCents: 30));
    final expensive = await _run(items, prefs: const UserPreferences(costPerKmCents: 999));
    expect(expensive.baselineSingleStore!['travel_cost_cents'],
        greaterThan(cheap.baselineSingleStore!['travel_cost_cents'] as int));
  });

  test('A5: Bio-Präferenz wählt die Bio-Variante', () async {
    expect(CatalogService.matchRawText('gurke', bioPreference: 'prefer_bio')!.isBio, isTrue);
    expect(CatalogService.matchRawText('bananen', bioPreference: 'prefer_bio')!.isBio, isTrue);
    expect(CatalogService.matchRawText('bio gurke', bioPreference: 'reject_bio')!.isBio, isFalse);

    final r = await _run([_free('gurke')], prefs: const UserPreferences(bioPreference: 'prefer_bio'));
    expect(r.stops.first.items.first.itemName, 'Bio Gurke');
  });

  test('A6: abgehakte Artikel werden nicht mitgerechnet', () async {
    final r = await _run([_free('bananen'), _free('gurke', checked: true)]);
    final names = [for (final s in r.stops) ...s.items.map((i) => i.itemName)];
    expect(names, isNot(contains('Gurke')));
    expect(_run([_free('gurke', checked: true)]), throwsException);
  });

  test('A7: abgelaufene Angebote greifen nicht, gültige schon', () {
    // Nur Angebote, die wirklich unter dem Katalogpreis liegen (Datenlage: V18/V29).
    final offer = WalletService.weeklyOffers.firstWhere((o) {
      if (o.productId == null || o.validTo == null || o.validFrom == null) return false;
      final p = CatalogService.products.where((p) => p.id == o.productId);
      final b = p.isEmpty ? null : p.first.getPriceForChain(o.chain.name);
      return b != null && o.discountPriceCents < b;
    });
    final prod = CatalogService.products.firstWhere((p) => p.id == offer.productId);
    final base = prod.getPriceForChain(offer.chain.name);

    final after = offer.validTo!.add(const Duration(days: 1));
    expect(OptimizerService.unitPrice(prod, offer.chain, after), base);

    final during = offer.validFrom!.add(const Duration(hours: 12));
    // Bei mehreren gültigen Angeboten zählt das günstigste.
    expect(OptimizerService.unitPrice(prod, offer.chain, during), lessThanOrEqualTo(offer.discountPriceCents));
    expect(OptimizerService.unitPrice(prod, offer.chain, during), lessThan(base!));
  });

  test('A8: Angebote gelten nur für die exakte Produkt-ID', () {
    final offer = WalletService.weeklyOffers.firstWhere((o) => o.productId != null && o.validFrom != null);
    final during = offer.validFrom!.add(const Duration(hours: 12));
    final bioBananen = _byName('Bio Bananen');
    expect(OptimizerService.unitPrice(bioBananen, offer.chain, during),
        bioBananen.getPriceForChain(offer.chain.name));
    for (final p in CatalogService.products.where((p) => p.id != offer.productId)) {
      final price = OptimizerService.unitPrice(p, offer.chain, during);
      final ownOffers = WalletService.weeklyOffers.where((o) => o.productId == p.id && o.chain == offer.chain);
      if (ownOffers.isEmpty) expect(price, p.getPriceForChain(offer.chain.name));
    }
  });

  test('A9: Freitext nur über ganze Wörter', () {
    String? name(String q) => CatalogService.matchRawText(q)?.name;
    expect(name('eis'), isNot(contains('Speisekartoffeln')));
    expect(name('wein'), isNot(contains('Schwein')));
    expect(name('Kokosmilch'), isNot(contains('Vollmilch')));
    expect(name('Buttermilch') ?? '', isNot(startsWith('Butter ')));
    expect(name('Salatdressing'), isNot('Eisbergsalat'));
    // Treffer, die weiter funktionieren müssen
    expect(name('bananen'), 'Bananen');
    expect(name('2 kg kartoffeln'), contains('Speisekartoffeln'));
  });

  test('V14: unsichere Zuordnung wird nicht automatisch vergeben, sondern erfragt', () {
    // Wortende-Treffer ("wein" → "Schwein") nur als Vorschlag
    expect(CatalogService.matchRawText('wein'), isNull);
    expect(CatalogService.isUncertain('wein'), isTrue);
    expect(CatalogService.matchCandidates('käse').candidates, isNotEmpty);
    expect(CatalogService.matchRawText('käse'), isNull);
    // Unbekanntes erfragen, Eindeutiges nicht
    expect(CatalogService.isUncertain('Champagner Dom Pérignon'), isTrue);
    expect(CatalogService.isUncertain('bananen'), isFalse);
    // Marke zählt mit
    expect(CatalogService.matchRawText('Somat Gold')?.name, startsWith('Somat Gold'));
  });

  test('V14: ausdrücklich gewähltes Produkt bleibt trotz Bio-Präferenz', () async {
    final gurke = _byName('Gurke');
    final item = ShoppingListItem(id: 'x', listId: 'l', rawText: gurke.name, matchedProduct: gurke);
    final r = await _run([item], prefs: const UserPreferences(bioPreference: 'prefer_bio'));
    expect(r.stops.first.items.first.itemName, 'Gurke');
  });

  test('A10: unbekannte Artikel werden nicht geschätzt', () async {
    final r = await _run([_free('bananen'), _free('Champagner Dom Pérignon')]);
    expect(r.unpricedItems, contains('Champagner Dom Pérignon'));
    final names = [for (final s in r.stops) ...s.items.map((i) => i.itemName)];
    expect(names, isNot(contains('Champagner Dom Pérignon')));
  });

  test('A11: Optimierer nutzt die Filialen der Karte', () async {
    final ids = rlpStores.map((s) => s.id).toSet();
    final r = await _run([_free('bananen'), _free('vollmilch'), _free('kerrygold')]);
    for (final s in r.stops) {
      expect(ids, contains(s.storeId));
    }
  });

  test('A12: Ersparnis gegen den günstigsten Einzelmarkt inkl. Fahrt', () async {
    final r = await _run([_free('bananen'), _free('vollmilch'), _free('kerrygold'), _free('somat tabs')]);
    final base = r.baselineSingleStore!;
    final baseTotal = (base['total_basket_price_cents'] as int) + (base['travel_cost_cents'] as int);
    if (r.isMultiStore) {
      final routeTotal = r.summary.totalBasketPriceCents +
          (base['travel_cost_cents'] as int) +
          r.summary.travelPenaltyCents;
      expect(r.summary.netSavingsCents, baseTotal - routeTotal);
      expect(r.summary.netSavingsCents, greaterThan(0));
    } else {
      expect(r.summary.netSavingsCents, 0);
    }
  });
}
