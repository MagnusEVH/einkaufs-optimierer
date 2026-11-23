// app/lib/core/services/offer_import_service.dart
//
// Angebote, die der Übernehmen-Knopf (app/web/uebernehmen/extract.js) von einer
// Händlerseite liest, kommen als #import=<base64url(JSON)> in die App.
// Sie werden geprüft, dem Katalog zugeordnet und nur lokal gespeichert.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/loyalty_wallet.dart';
import '../models/product.dart';
import '../models/store.dart';
import 'catalog_service.dart';
import 'preferences_storage.dart';

/// Ein erkanntes Angebot mit Vorschlag für das Katalogprodukt.
class ImportCandidate {
  final String title;
  final int priceCents;
  final int? originalPriceCents;
  final int? discountPercent;
  final String? unitInfo;
  Product? product;
  bool selected;

  ImportCandidate({
    required this.title,
    required this.priceCents,
    this.originalPriceCents,
    this.discountPercent,
    this.unitInfo,
    this.product,
    required this.selected,
  });
}

class ImportBatch {
  final SupermarketChain chain;
  final String sourceUrl;
  final DateTime capturedAt;
  final DateTime validFrom;
  final DateTime validTo;
  final bool validGuessed;
  final List<ImportCandidate> candidates;

  const ImportBatch({
    required this.chain,
    required this.sourceUrl,
    required this.capturedAt,
    required this.validFrom,
    required this.validTo,
    required this.validGuessed,
    required this.candidates,
  });

  String get host => Uri.tryParse(sourceUrl)?.host.replaceFirst('www.', '') ?? chain.displayName;
}

class OfferImportService {
  /// Noch nicht bestätigter Import aus der Start-URL.
  static ImportBatch? pending;

  /// Liest `#import=…` aus der Adresse. Ungültige Daten werden ignoriert.
  static ImportBatch? fromUri(Uri uri) {
    final fragment = uri.fragment;
    if (!fragment.startsWith('import=')) return null;
    return parsePayload(fragment.substring('import='.length));
  }

  static ImportBatch? parsePayload(String encoded) {
    try {
      final text = utf8.decode(base64Url.decode(base64Url.normalize(encoded)));
      final data = json.decode(text) as Map<String, dynamic>;
      if (data['v'] != 1) return null;
      final chainName = data['chain']?.toString();
      if (chainName == null || !SupermarketChain.values.any((c) => c.name == chainName)) return null;

      final validFrom = DateTime.parse(data['valid_from'] as String);
      // Gültig bis Tagesende
      final validTo = DateTime.parse(data['valid_to'] as String).add(const Duration(hours: 23, minutes: 59));

      final rawOffers = (data['offers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final candidates = <ImportCandidate>[];
      for (final o in rawOffers.take(200)) {
        final title = o['title']?.toString().trim() ?? '';
        final price = (o['price_cents'] as num?)?.toInt() ?? 0;
        if (title.isEmpty || price <= 0 || price > 100000) continue;
        final product = CatalogService.matchRawText(title, brandPreference: 'neutral');
        candidates.add(ImportCandidate(
          title: title,
          priceCents: price,
          originalPriceCents: (o['original_price_cents'] as num?)?.toInt(),
          discountPercent: (o['discount_percent'] as num?)?.toInt(),
          unitInfo: o['unit_info']?.toString(),
          product: product,
          // Ohne Katalogtreffer standardmäßig abgewählt (könnte Seitenrauschen sein)
          selected: product != null,
        ));
      }

      return ImportBatch(
        chain: SupermarketChain.values.firstWhere((c) => c.name == chainName),
        sourceUrl: data['source_url']?.toString() ?? '',
        capturedAt: DateTime.tryParse(data['captured_at']?.toString() ?? '') ?? DateTime.now(),
        validFrom: validFrom,
        validTo: validTo,
        validGuessed: data['valid_guessed'] == true,
        candidates: candidates,
      );
    } catch (e) {
      debugPrint('[OfferImport] Ungültige Importdaten: $e');
      return null;
    }
  }

  /// Stabiler Hash (FNV-1a, 32 Bit) für IDs, unabhängig von Plattform und Sitzung.
  static String _fnv1a(String s) {
    var h = 0x811c9dc5;
    for (final b in utf8.encode(s)) {
      h ^= b;
      // h * 16777619 mod 2^32, zerlegt in 2^24 + 403: exakt auch im Web (JS-Zahlen)
      h = (h * 403 + ((h << 24) & 0xffffffff)) & 0xffffffff;
    }
    return h.toRadixString(16).padLeft(8, '0');
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// Ausgewählte Kandidaten als Angebote (stabile IDs, damit erneutes Übernehmen nichts doppelt).
  static List<WeeklyOffer> toOffers(ImportBatch batch) {
    final captured = '${_pad(batch.capturedAt.day)}.${_pad(batch.capturedAt.month)}.';
    final period = 'Gültig: ${_pad(batch.validFrom.day)}.${_pad(batch.validFrom.month)}. – '
        '${_pad(batch.validTo.day)}.${_pad(batch.validTo.month)}.${batch.validGuessed ? ' (geschätzt)' : ''}';
    return batch.candidates.where((c) => c.selected).map((c) {
      final key = '${batch.chain.name}|${c.title}|${c.priceCents}|${batch.validTo.toIso8601String()}';
      return WeeklyOffer(
        id: 'imp-${_fnv1a(key)}',
        chain: batch.chain,
        productName: c.product?.name ?? c.title,
        title: c.title,
        discountPriceCents: c.priceCents,
        regularPriceCents: c.originalPriceCents ?? c.priceCents,
        discountPercent: c.discountPercent ?? 0,
        validFrom: batch.validFrom,
        validTo: batch.validTo,
        periodLabel: period,
        unitInfo: c.unitInfo,
        productId: c.product?.id,
        source: 'übernommen von ${batch.host} am $captured',
      );
    }).toList();
  }

  static Future<List<WeeklyOffer>> loadImported() async {
    final raw = await PreferencesStorage.loadImportedOffers();
    return raw.map(WeeklyOffer.fromJson).toList();
  }

  /// Speichert neue Angebote zu den vorhandenen. Gleiche IDs werden ersetzt,
  /// seit mehr als 14 Tagen abgelaufene entfernt.
  static Future<List<WeeklyOffer>> saveImported(List<WeeklyOffer> offers, {DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 14));
    final byId = <String, WeeklyOffer>{
      for (final o in await loadImported()) o.id: o,
      for (final o in offers) o.id: o,
    };
    final kept = byId.values.where((o) => o.validTo == null || o.validTo!.isAfter(cutoff)).toList();
    await PreferencesStorage.saveImportedOffers(kept.map((o) => o.toJson()).toList());
    return kept;
  }
}
