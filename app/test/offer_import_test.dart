// Übernehmen-Knopf: Import-Daten aus #import=… prüfen, zuordnen, speichern
// und im Optimierer verwenden.

import 'dart:convert';

import 'package:einkaufs_optimierer/core/models/store.dart';
import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:einkaufs_optimierer/core/services/observed_price_service.dart';
import 'package:einkaufs_optimierer/core/services/offer_import_service.dart';
import 'package:einkaufs_optimierer/core/services/optimizer_service.dart';
import 'package:einkaufs_optimierer/core/services/preferences_storage.dart';
import 'package:einkaufs_optimierer/core/services/wallet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _encode(Map<String, dynamic> payload) =>
    base64Url.encode(utf8.encode(json.encode(payload))).replaceAll('=', '');

Map<String, dynamic> _payload({Object v = 1, String chain = 'rewe', List<Map<String, dynamic>>? offers}) => {
      'v': v,
      'chain': chain,
      'source_url': 'https://www.rewe.de/angebote/bingen/240123/',
      'captured_at': '2026-11-25T10:00:00.000Z',
      'valid_from': '2026-11-24',
      'valid_to': '2026-11-29',
      'valid_guessed': false,
      'offers': offers ??
          [
            {'title': 'Kerrygold Irische Butter 250g', 'price_cents': 199, 'original_price_cents': 265, 'discount_percent': 25},
            {'title': 'Versand ab', 'price_cents': 390},
            {'title': '', 'price_cents': 100},
            {'title': 'Ohne Preis', 'price_cents': 0},
          ],
    };

Uri _uri(Map<String, dynamic> p) => Uri.parse('https://example.org/app/#import=${_encode(p)}');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await CatalogService.loadCatalog();
    await WalletService.loadScrapedOffers(forceRefresh: true);
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PreferencesStorage.simulateReload();
  });

  test('gültige Daten werden gelesen und dem Katalog zugeordnet', () {
    final batch = OfferImportService.fromUri(_uri(_payload()))!;
    expect(batch.chain, SupermarketChain.rewe);
    expect(batch.host, 'rewe.de');
    expect(batch.validTo.day, 29);
    expect(batch.validTo.hour, 23, reason: 'gültig bis Tagesende');

    // Leerer Titel und Preis 0 werden verworfen
    expect(batch.candidates.map((c) => c.title), ['Kerrygold Irische Butter 250g', 'Versand ab']);
    final butter = batch.candidates.first;
    expect(butter.product?.name, 'Kerrygold Irische Butter 250g');
    expect(butter.selected, isTrue);
    // Ohne Katalogtreffer standardmäßig abgewählt
    expect(batch.candidates.last.product, isNull);
    expect(batch.candidates.last.selected, isFalse);
  });

  test('ungültige Daten werden ignoriert', () {
    expect(OfferImportService.fromUri(Uri.parse('https://example.org/#/')), isNull);
    expect(OfferImportService.fromUri(Uri.parse('https://example.org/#import=%%%')), isNull);
    expect(OfferImportService.fromUri(_uri(_payload(v: 2))), isNull);
    expect(OfferImportService.fromUri(_uri(_payload(chain: 'edeka'))), isNull);
  });

  test('stabile IDs: erneutes Übernehmen erzeugt keine Dubletten', () async {
    final a = OfferImportService.toOffers(OfferImportService.fromUri(_uri(_payload()))!);
    final b = OfferImportService.toOffers(OfferImportService.fromUri(_uri(_payload()))!);
    expect(a.map((o) => o.id), b.map((o) => o.id));
    expect(a.single.id, matches(RegExp(r'^imp-[0-9a-f]{8}$')));

    await OfferImportService.saveImported(a, now: DateTime.utc(2026, 11, 25));
    final saved = await OfferImportService.saveImported(b, now: DateTime.utc(2026, 11, 25));
    expect(saved, hasLength(1));
    expect(saved.single.source, 'übernommen von rewe.de am 25.11.');
  });

  test('lange abgelaufene Angebote werden beim Speichern entfernt', () async {
    final offers = OfferImportService.toOffers(OfferImportService.fromUri(_uri(_payload()))!);
    await OfferImportService.saveImported(offers, now: DateTime.utc(2026, 11, 25));
    final later = await OfferImportService.saveImported(const [], now: DateTime.utc(2026, 12, 20));
    expect(later, isEmpty);
  });

  test('übernommenes Angebot wirkt im Optimierer', () {
    final offers = OfferImportService.toOffers(OfferImportService.fromUri(_uri(_payload()))!);
    WalletService.addImportedOffers(offers);
    final butter = CatalogService.products.firstWhere((p) => p.name == 'Kerrygold Irische Butter 250g');
    expect(OptimizerService.unitPrice(butter, SupermarketChain.rewe, DateTime.utc(2026, 11, 26, 12)), 199);
    // Nach Ablauf wieder Normalpreis
    expect(OptimizerService.unitPrice(butter, SupermarketChain.rewe, DateTime.utc(2026, 12, 2)),
        butter.getPriceForChain('rewe'));
  });

  test('neuer Import ersetzt falsche Preise derselben Kette und Woche', () async {
    final wrong = OfferImportService.fromUri(_uri(_payload(offers: [
      {'title': 'Kerrygold Irische Butter 250g', 'price_cents': 265}, // Streichpreis erwischt
    ])))!;
    await OfferImportService.saveOffers(wrong);
    final right = OfferImportService.fromUri(_uri(_payload()))!;
    final kept = await OfferImportService.saveOffers(right);
    expect(kept.map((o) => o.discountPriceCents), [199], reason: 'alter Fehlpreis ist weg');

    // Andere Kette bleibt unberührt
    final lidl = OfferImportService.fromUri(_uri(_payload(chain: 'lidl')))!;
    final all = await OfferImportService.saveOffers(lidl);
    expect(all.map((o) => o.chain).toSet(), {SupermarketChain.rewe, SupermarketChain.lidl});

    final log = await OfferImportService.loadLog();
    expect(log['rewe']?['count'], 1);
    expect(log.containsKey('lidl'), isTrue);
  });

  test('Warnung bei unplausiblem Angebot', () {
    final batch = OfferImportService.fromUri(_uri(_payload(offers: [
      {'title': 'Kerrygold Irische Butter 250g', 'price_cents': 299, 'original_price_cents': 265},
      {'title': 'Kerrygold Irische Butter 250g', 'price_cents': 199, 'original_price_cents': 265},
    ])))!;
    expect(batch.candidates.first.warning(SupermarketChain.rewe), isNotNull);
    expect(batch.candidates.last.warning(SupermarketChain.rewe), isNull);
  });

  test('gemerkte Zuordnung greift beim nächsten Import', () async {
    final skyr = CatalogService.products.firstWhere((p) => p.name.startsWith('Skyr Natur'));
    final first = OfferImportService.fromUri(_uri(_payload(offers: [
      {'title': 'MILBONA SKYR NAT. 450G', 'price_cents': 149},
    ])))!;
    first.candidates.single
      ..product = skyr
      ..selected = true;
    await OfferImportService.saveOffers(first);

    PreferencesStorage.simulateReload();
    await OfferImportService.loadMappings();
    final second = OfferImportService.fromUri(_uri(_payload(offers: [
      {'title': 'Milbona Skyr nat. 450g', 'price_cents': 139},
    ])))!;
    expect(second.candidates.single.product?.id, skyr.id);
    expect(second.candidates.single.selected, isTrue);
  });

  test('Bonpreis ersetzt den Beispielpreis im Optimierer', () async {
    final butter = CatalogService.products.firstWhere((p) => p.name == 'Kerrygold Irische Butter 250g');
    final receipt = {
      ..._payload(offers: [
        {'title': 'KERRYGOLD BUTTER', 'price_cents': 289},
      ]),
      'kind': 'receipt',
      'source_url': 'kassenbon',
      'valid_from': '2026-11-24',
      'valid_to': '2026-11-24',
    };
    final batch = OfferImportService.fromUri(_uri(receipt))!;
    expect(batch.isReceipt, isTrue);
    expect(batch.host, 'Kassenbon');
    batch.candidates.single
      ..product = butter
      ..selected = true;
    expect(await OfferImportService.saveReceipt(batch), 1);

    final day = DateTime(2026, 11, 26);
    // Bonpreis statt Katalogpreis (Angebote dieser Woche sind hier keine gespeichert)
    WalletService.setImportedOffers(const []);
    expect(ObservedPriceService.latest(butter.id, SupermarketChain.rewe, day)?.priceCents, 289);
    expect(OptimizerService.unitPrice(butter, SupermarketChain.rewe, day), 289);
    // Andere Kette: weiter Katalogpreis
    expect(OptimizerService.unitPrice(butter, SupermarketChain.lidl, day), butter.getPriceForChain('lidl'));
    // Nach 60 Tagen zählt der Bon nicht mehr
    expect(OptimizerService.unitPrice(butter, SupermarketChain.rewe, DateTime(2027, 2, 1)), butter.getPriceForChain('rewe'));

    // Übersteht ein Neuladen
    PreferencesStorage.simulateReload();
    await ObservedPriceService.load();
    expect(ObservedPriceService.latest(butter.id, SupermarketChain.rewe, day)?.priceCents, 289);
  });
}
