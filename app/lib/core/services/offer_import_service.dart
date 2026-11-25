// app/lib/core/services/offer_import_service.dart
//
// Angebote, die der Übernehmen-Knopf (app/web/uebernehmen/extract.js) von einer
// Händlerseite liest, kommen als #import=<base64url(JSON)> in die App.
// Sie werden geprüft, dem Katalog zugeordnet und nur lokal gespeichert.
// Derselbe Weg dient dem Bon-Scan (app/web/bon.html, kind = "receipt"):
// Bonpreise werden zu beobachteten Preisen (ObservedPriceService).
// Bestätigte Zuordnungen Text → Produkt merkt sich die App für das nächste Mal.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/loyalty_wallet.dart';
import '../models/product.dart';
import '../models/store.dart';
import 'catalog_service.dart';
import 'loyalty_service.dart';
import 'observed_price_service.dart';
import 'preferences_storage.dart';

/// Ein erkanntes Angebot mit Vorschlag für das Katalogprodukt.
class ImportCandidate {
  final String title;
  final int priceCents;
  final int? originalPriceCents;
  final int? discountPercent;
  final String? unitInfo;
  /// Artikelnummer des Händlers, falls die Seite sie liefert (stabile ID).
  final String? sourceId;
  Product? product;
  bool selected;

  ImportCandidate({
    required this.title,
    required this.priceCents,
    this.originalPriceCents,
    this.discountPercent,
    this.unitInfo,
    this.sourceId,
    this.product,
    required this.selected,
  });

  /// Hinweis, wenn das Angebot unplausibel wirkt (null = unauffällig).
  String? warning(SupermarketChain chain) {
    final orig = originalPriceCents;
    if (orig != null && orig <= priceCents) return 'Streichpreis nicht höher als Angebotspreis';
    if (discountPercent != null && discountPercent! >= 70) return 'Rabatt über 70 %, bitte prüfen';
    final regular = product?.prices[chain.name];
    if (regular != null && priceCents > regular) {
      return 'teurer als der bekannte Normalpreis (${(regular / 100).toStringAsFixed(2).replaceAll('.', ',')} €)';
    }
    return null;
  }
}

class ImportBatch {
  final SupermarketChain chain;
  final String sourceUrl;
  final DateTime capturedAt;
  final DateTime validFrom;
  final DateTime validTo;
  final bool validGuessed;
  final List<ImportCandidate> candidates;
  /// true = Kassenbon (Normalpreise einer Filiale), false = Angebotsseite.
  final bool isReceipt;
  /// Treue-Teil des Bons (bon.html: detected, program, earned_cents …), sonst null.
  final Map<String, dynamic>? loyalty;

  const ImportBatch({
    required this.chain,
    required this.sourceUrl,
    required this.capturedAt,
    required this.validFrom,
    required this.validTo,
    required this.validGuessed,
    required this.candidates,
    this.isReceipt = false,
    this.loyalty,
  });

  String get host => isReceipt ? 'Kassenbon' : Uri.tryParse(sourceUrl)?.host.replaceFirst('www.', '') ?? chain.displayName;
}

class OfferImportService {
  /// Noch nicht bestätigter Import aus der Start-URL.
  static ImportBatch? pending;

  static const _keyMappings = 'import_mappings_v1';
  static const _keyLog = 'import_log_v1';

  /// Gemerkte Zuordnungen: normalisierter Text → Katalog-ID.
  static Map<String, String> _mappings = {};

  static String normalize(String text) => CatalogService.tokenize(text).join(' ');

  /// Vor [fromUri] aufrufen, damit gemerkte Zuordnungen greifen.
  static Future<void> loadMappings() async {
    final raw = await PreferencesStorage.loadJson(_keyMappings);
    _mappings = raw is Map ? raw.map((k, v) => MapEntry(k.toString(), v.toString())) : {};
  }

  static Product? _remembered(String title) {
    final id = _mappings[normalize(title)];
    if (id == null) return null;
    for (final p in CatalogService.products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Merkt sich die Zuordnungen der übernommenen Einträge.
  static Future<void> learnMappings(ImportBatch batch) async {
    for (final c in batch.candidates) {
      if (c.selected && c.product != null) _mappings[normalize(c.title)] = c.product!.id;
    }
    await PreferencesStorage.saveJson(_keyMappings, _mappings);
  }

  /// Wann zuletzt je Kette übernommen wurde: Kette → {at, count, valid_to}.
  static Future<Map<String, Map<String, dynamic>>> loadLog() async {
    final raw = await PreferencesStorage.loadJson(_keyLog);
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), (v as Map).cast<String, dynamic>()));
  }

  static Future<void> _writeLog(ImportBatch batch, int count) async {
    final log = await loadLog();
    log['${batch.isReceipt ? 'bon_' : ''}${batch.chain.name}'] = {
      'at': DateTime.now().toIso8601String(),
      'count': count,
      'valid_to': batch.validTo.toIso8601String(),
    };
    await PreferencesStorage.saveJson(_keyLog, log);
  }

  /// Bon übernehmen: ausgewählte, zugeordnete Zeilen werden zu echten Preisen.
  static Future<int> saveReceipt(ImportBatch batch) async {
    final d = batch.validFrom;
    final label = 'Kassenbon ${batch.chain.displayName} ${_pad(d.day)}.${_pad(d.month)}.';
    final prices = batch.candidates
        .where((c) => c.selected && c.product != null)
        .map((c) => ObservedPrice(
              productId: c.product!.id,
              chain: batch.chain,
              priceCents: c.priceCents,
              date: d,
              source: label,
              rawText: c.title,
            ))
        .toList();
    await ObservedPriceService.add(prices);
    await LoyaltyService.recordFromReceipt(batch.chain, d, batch.loyalty);
    await learnMappings(batch);
    await _writeLog(batch, prices.length);
    return prices.length;
  }

  /// Angebote übernehmen: ersetzt frühere Übernahmen derselben Kette und Woche.
  static Future<List<WeeklyOffer>> saveOffers(ImportBatch batch) async {
    final offers = toOffers(batch);
    final kept = await saveImported(offers, replaceBatch: batch);
    await learnMappings(batch);
    await _writeLog(batch, offers.length);
    return kept;
  }

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
      final isReceipt = data['kind'] == 'receipt';
      final chainName = data['chain']?.toString();
      if (chainName == null || !SupermarketChain.values.any((c) => c.name == chainName)) return null;

      final validFrom = DateTime.parse(data['valid_from'] as String);
      // Gültig bis Tagesende
      final validTo = DateTime.parse(data['valid_to'] as String).add(const Duration(hours: 23, minutes: 59));

      final rawOffers = (data['offers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final candidates = <ImportCandidate>[];
      for (final o in rawOffers.take(500)) {
        final title = o['title']?.toString().trim() ?? '';
        final price = (o['price_cents'] as num?)?.toInt() ?? 0;
        if (title.isEmpty || price <= 0 || price > 100000) continue;
        final remembered = _remembered(title);
        final product = remembered ?? CatalogService.matchRawText(title, brandPreference: 'neutral');
        candidates.add(ImportCandidate(
          title: title,
          priceCents: price,
          originalPriceCents: (o['original_price_cents'] as num?)?.toInt(),
          discountPercent: (o['discount_percent'] as num?)?.toInt(),
          unitInfo: o['unit_info']?.toString(),
          sourceId: o['source_id']?.toString(),
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
        isReceipt: isReceipt,
        loyalty: isReceipt && data['loyalty'] is Map ? (data['loyalty'] as Map).cast<String, dynamic>() : null,
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
      final key = c.sourceId != null
          ? '${batch.chain.name}|nan:${c.sourceId}|${batch.validTo.toIso8601String()}'
          : '${batch.chain.name}|${c.title}|${c.priceCents}|${batch.validTo.toIso8601String()}';
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

  static bool _overlaps(WeeklyOffer o, ImportBatch b) {
    if (o.chain != b.chain || !o.id.startsWith('imp-')) return false;
    final from = o.validFrom ?? b.validFrom;
    final to = o.validTo ?? b.validTo;
    return !from.isAfter(b.validTo) && !to.isBefore(b.validFrom);
  }

  static Future<List<WeeklyOffer>> loadImported() async {
    final raw = await PreferencesStorage.loadImportedOffers();
    return raw.map(WeeklyOffer.fromJson).toList();
  }

  /// Speichert neue Angebote zu den vorhandenen. Gleiche IDs werden ersetzt,
  /// seit mehr als 14 Tagen abgelaufene entfernt.
  ///
  /// Mit [replaceBatch] ersetzt der neue Import alle früher übernommenen
  /// Angebote derselben Kette, deren Gültigkeit sich mit ihm überschneidet.
  /// So verschwinden falsch erkannte Preise beim nächsten Übernehmen von selbst.
  static Future<List<WeeklyOffer>> saveImported(List<WeeklyOffer> offers, {ImportBatch? replaceBatch, DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 14));
    var existing = await loadImported();
    if (replaceBatch != null) {
      existing = existing.where((o) => !_overlaps(o, replaceBatch)).toList();
    }
    final byId = <String, WeeklyOffer>{
      for (final o in existing) o.id: o,
      for (final o in offers) o.id: o,
    };
    final kept = byId.values.where((o) => o.validTo == null || o.validTo!.isAfter(cutoff)).toList();
    await PreferencesStorage.saveImportedOffers(kept.map((o) => o.toJson()).toList());
    return kept;
  }
}
