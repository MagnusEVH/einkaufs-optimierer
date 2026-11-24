// Übernehmen-Knopf: Import-Daten aus #import=… prüfen, zuordnen, speichern
// und im Optimierer verwenden.

import 'dart:convert';

import 'package:einkaufs_optimierer/core/models/store.dart';
import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
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
}
