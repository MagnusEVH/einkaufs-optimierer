// Start mit #import=… öffnet die Vorschau "Angebote übernehmen".

import 'dart:convert';

import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:einkaufs_optimierer/core/services/offer_import_service.dart';
import 'package:einkaufs_optimierer/features/wallet/import_offers_screen.dart';
import 'package:einkaufs_optimierer/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Import-Daten beim Start öffnen die Vorschau', (tester) async {
    await tester.runAsync(CatalogService.loadCatalog);
    final payload = {
      'v': 1,
      'chain': 'rewe',
      'source_url': 'https://www.rewe.de/angebote/',
      'captured_at': '2026-11-25T10:00:00.000Z',
      'valid_from': '2026-11-24',
      'valid_to': '2026-11-29',
      'valid_guessed': false,
      'offers': [
        {'title': 'Kerrygold Irische Butter 250g', 'price_cents': 199},
      ],
    };
    final encoded = base64Url.encode(utf8.encode(json.encode(payload)));
    OfferImportService.pending = OfferImportService.fromUri(Uri.parse('https://x/#import=$encoded'));
    expect(OfferImportService.pending, isNotNull);

    await tester.pumpWidget(const ProviderScope(child: EinkaufsOptimiererApp()));
    await tester.pumpAndSettle();

    expect(find.byType(ImportOffersScreen), findsOneWidget);
    expect(find.text('1 Angebote übernehmen'), findsOneWidget);
    expect(OfferImportService.pending, isNull, reason: 'nur einmal anzeigen');
  });
}
