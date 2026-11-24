// app/lib/core/services/observed_price_service.dart
//
// Echte Preise, die Magnus selbst gesehen hat (Kassenbon). Sie ersetzen im
// Optimierer den Beispielpreis aus dem Katalog für diese Kette, solange sie
// nicht älter als [maxAge] sind. Alles bleibt lokal auf dem Gerät.

import '../models/store.dart';
import 'preferences_storage.dart';

class ObservedPrice {
  final String productId;
  final SupermarketChain chain;
  final int priceCents;
  final DateTime date;
  final String source; // z. B. "Kassenbon REWE 24.11."
  final String rawText; // Text auf dem Bon

  const ObservedPrice({
    required this.productId,
    required this.chain,
    required this.priceCents,
    required this.date,
    required this.source,
    required this.rawText,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'chain': chain.name,
        'price_cents': priceCents,
        'date': date.toIso8601String(),
        'source': source,
        'raw_text': rawText,
      };

  static ObservedPrice? fromJson(Map<String, dynamic> j) {
    try {
      return ObservedPrice(
        productId: j['product_id'] as String,
        chain: SupermarketChain.values.firstWhere((c) => c.name == j['chain']),
        priceCents: (j['price_cents'] as num).toInt(),
        date: DateTime.parse(j['date'] as String),
        source: j['source']?.toString() ?? 'Kassenbon',
        rawText: j['raw_text']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

class ObservedPriceService {
  static const _key = 'observed_prices_v1';
  static const maxAge = Duration(days: 60);
  static List<ObservedPrice> _prices = [];

  static List<ObservedPrice> get all => List.unmodifiable(_prices);

  static Future<void> load() async {
    final raw = await PreferencesStorage.loadJson(_key);
    _prices = raw is List
        ? raw.whereType<Map>().map((m) => ObservedPrice.fromJson(m.cast<String, dynamic>())).whereType<ObservedPrice>().toList()
        : [];
  }

  /// Neuester Preis für Produkt und Kette, sofern nicht älter als [maxAge].
  static ObservedPrice? latest(String productId, SupermarketChain chain, DateTime now) {
    ObservedPrice? best;
    for (final p in _prices) {
      if (p.productId != productId || p.chain != chain) continue;
      if (now.difference(p.date) > maxAge || p.date.isAfter(now.add(const Duration(days: 1)))) continue;
      if (best == null || p.date.isAfter(best.date)) best = p;
    }
    return best;
  }

  /// Fügt Preise hinzu. Gleicher Bon (Produkt, Kette, Tag) wird ersetzt,
  /// Einträge älter als ein Jahr werden entfernt.
  static Future<void> add(List<ObservedPrice> prices, {DateTime? now}) async {
    String day(DateTime d) => '${d.year}-${d.month}-${d.day}';
    final keys = prices.map((p) => '${p.productId}|${p.chain.name}|${day(p.date)}').toSet();
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 365));
    _prices = [
      ..._prices.where((p) => !keys.contains('${p.productId}|${p.chain.name}|${day(p.date)}') && p.date.isAfter(cutoff)),
      ...prices,
    ];
    await PreferencesStorage.saveJson(_key, _prices.map((p) => p.toJson()).toList());
  }
}
