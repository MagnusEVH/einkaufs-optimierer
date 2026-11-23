// app/lib/core/services/catalog_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

class CatalogService {
  static List<Product> _cachedProducts = [];
  static bool _isLoaded = false;

  static List<Product> get products => _cachedProducts;

  /// Liefert den Zeitpunkt der letzten Verifizierung für ein Produkt
  static String getFreshnessLabel(Product product) {
    return 'Beispieldaten, nicht geprüft';
  }

  /// Liefert die transparente Datenquelle für den Preis
  static String getPriceSource(String chain) {
    switch (chain.toLowerCase()) {
      case 'lidl':
        return 'Beispieldaten (Demo)';
      case 'rewe':
        return 'Beispieldaten (Demo)';
      case 'aldi_sued':
        return 'Beispieldaten (Demo)';
      case 'netto':
        return 'Beispieldaten (Demo)';
      case 'rossmann':
        return 'Beispieldaten (Demo)';
      case 'dm':
        return 'Beispieldaten (Demo)';
      default:
        return 'Beispieldaten (Demo)';
    }
  }

  /// Loads catalog from local seed JSON or remote Supabase
  static Future<List<Product>> loadCatalog() async {
    if (_isLoaded && _cachedProducts.isNotEmpty) return _cachedProducts;

    try {
      final jsonString = await rootBundle.loadString('assets/products_seed_250.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final rawList = data['products'] as List<dynamic>? ?? [];

      _cachedProducts = rawList
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
      _isLoaded = true;
    } catch (e) {
      // Fallback: minimal in-memory list if asset bundle is not yet loaded in test environment
      _cachedProducts = _buildFallbackStaples();
      _isLoaded = true;
    }

    return _cachedProducts;
  }

  /// Autocomplete suggestions for user input (e.g. typing "sk" suggests "Skyr Natur", "Skyr Vanille")
  static List<Product> getSuggestions(String query, {int limit = 5}) {
    if (query.trim().isEmpty) return [];
    final clean = query.toLowerCase().trim();

    final matches = _cachedProducts.where((p) {
      if (p.name.toLowerCase().contains(clean)) return true;
      if (p.brand != null && p.brand!.toLowerCase().contains(clean)) return true;
      if (p.aliases.any((a) => a.toLowerCase().contains(clean))) return true;
      return false;
    }).take(limit).toList();

    return matches;
  }

  /// Zerlegt Text in kleingeschriebene ganze Wörter (Umlaute bleiben erhalten).
  static List<String> tokenize(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9äöüß]+'))
      .where((t) => t.isNotEmpty)
      .toList();

  /// true, wenn [phrase] als zusammenhängende Wortfolge in [words] vorkommt.
  static bool _containsPhrase(List<String> words, List<String> phrase) {
    if (phrase.isEmpty || phrase.length > words.length) return false;
    for (int i = 0; i + phrase.length <= words.length; i++) {
      var ok = true;
      for (int k = 0; k < phrase.length; k++) {
        if (words[i + k] != phrase[k]) {
          ok = false;
          break;
        }
      }
      if (ok) return true;
    }
    return false;
  }

  /// Ordnet Freitext einem Katalogprodukt zu, nur über ganze Wörter
  /// ("wein" trifft nicht "Schwein"). Reihenfolge: exakter Alias/Name,
  /// längster Alias als Wortfolge, alle Suchwörter im Produktnamen.
  /// Danach wirken Bio- und Marken-Präferenz (auch auf Bio-Varianten).
  /// Gibt null zurück, wenn nichts sicher passt.
  static Product? matchRawText(
    String rawText, {
    String brandPreference = 'prefer_private_label',
    String bioPreference = 'neutral',
  }) {
    final match = matchCandidates(rawText);
    if (match.level == MatchLevel.none || match.level == MatchLevel.compound) return null;
    final candidates = match.candidates;
    return _applyPreferences(candidates, brandPreference, bioPreference);
  }

  /// Kandidaten für einen Freitext samt Sicherheit der Zuordnung.
  static CatalogMatch matchCandidates(String rawText) {
    final queryWords = tokenize(rawText);
    if (_cachedProducts.isEmpty || queryWords.isEmpty) {
      return const CatalogMatch(MatchLevel.none, []);
    }
    final query = queryWords.join(' ');

    var candidates = <Product>[];

    // 1. Exakter Alias oder Name
    var level = MatchLevel.exact;
    for (final p in _cachedProducts) {
      if (tokenize(p.name).join(' ') == query ||
          p.aliases.any((a) => tokenize(a).join(' ') == query)) {
        candidates.add(p);
      }
    }

    // 2. Längster Alias als Wortfolge im Suchtext
    if (candidates.isEmpty) {
      level = MatchLevel.alias;
      int best = 0;
      for (final p in _cachedProducts) {
        for (final a in p.aliases) {
          final aw = tokenize(a);
          if (aw.length < best || !_containsPhrase(queryWords, aw)) continue;
          if (aw.length > best) {
            best = aw.length;
            candidates = [];
          }
          if (!candidates.contains(p)) candidates.add(p);
        }
      }
    }

    // 3. Alle Suchwörter kommen als ganze Wörter in Name oder Marke vor
    if (candidates.isEmpty) {
      level = MatchLevel.words;
      for (final p in _cachedProducts) {
        final words = tokenize('${p.name} ${p.brand ?? ''}').toSet();
        if (queryWords.every(words.contains)) candidates.add(p);
      }
    }

    // 4. Nur Vorschläge: Wortende eines zusammengesetzten Worts
    //    ("saft" → "Orangensaft"). Wird nie automatisch zugeordnet,
    //    weil das auch "wein" → "Schwein" träfe.
    if (candidates.isEmpty) {
      level = MatchLevel.compound;
      for (final p in _cachedProducts) {
        final words = tokenize(p.name);
        final hit = queryWords.every((q) => q.length >= 3 && words.any((w) => w.length > q.length && w.endsWith(q)));
        if (hit) candidates.add(p);
      }
    }

    if (candidates.isEmpty) return const CatalogMatch(MatchLevel.none, []);
    return CatalogMatch(level, candidates);
  }

  static String _bioCore(Product p) => (tokenize(p.name)..remove('bio')).join(' ');

  /// Unsicher: kein Treffer, oder mehrere verschiedene Waren nur über Einzelwörter.
  static bool isUncertain(String rawText) {
    final m = matchCandidates(rawText);
    if (m.level == MatchLevel.none || m.level == MatchLevel.compound) return true;
    return m.level == MatchLevel.words && m.candidates.map(_bioCore).toSet().length > 1;
  }

  static Product _applyPreferences(List<Product> found, String brandPreference, String bioPreference) {
    var candidates = [...found];

    // Bio-/Nicht-Bio-Varianten derselben Ware ergänzen ("Gurke" ↔ "Bio Gurke").
    if (bioPreference != 'neutral') {
      final cores = candidates.map(_bioCore).toSet();
      for (final p in _cachedProducts) {
        if (!candidates.contains(p) && cores.contains(_bioCore(p))) candidates.add(p);
      }
      final wantBio = bioPreference == 'prefer_bio';
      final filtered = candidates.where((p) => p.isBio == wantBio).toList();
      if (filtered.isNotEmpty) candidates = filtered;
    }

    if (brandPreference == 'reject_private_label') {
      return candidates.firstWhere((p) => !p.isPrivateLabel, orElse: () => candidates.first);
    }
    if (brandPreference == 'prefer_private_label') {
      return candidates.firstWhere((p) => p.isPrivateLabel, orElse: () => candidates.first);
    }
    return candidates.first;
  }

  static List<Product> _buildFallbackStaples() {
    return [
      Product(id: '1', gtinBarcode: '400001', name: 'Skyr Natur 500g', aliases: ['skyr', 'skyr natur'], prices: {'lidl': 119, 'aldi_sued': 129, 'rewe': 139}),
      Product(id: '2', gtinBarcode: '400002', name: 'Frische Vollmilch 3,5% 1L', aliases: ['vollmilch', 'milch'], prices: {'lidl': 95, 'aldi_sued': 95, 'rewe': 99}),
      Product(id: '3', gtinBarcode: '400003', name: 'Deutsche Markenbutter 250g', aliases: ['butter'], prices: {'lidl': 169, 'aldi_sued': 159, 'rewe': 179}),
      Product(id: '4', gtinBarcode: '400004', name: 'Barilla Spaghetti No. 5 500g', brand: 'Barilla', aliases: ['barilla spaghetti', 'spaghetti'], prices: {'lidl': 189, 'aldi_sued': 189, 'rewe': 149}),
      Product(id: '5', gtinBarcode: '400005', name: 'Toilettenpapier 3-lagig 8er', aliases: ['klopapier', 'toilettenpapier'], prices: {'lidl': 345, 'aldi_sued': 345, 'rewe': 365}),
    ];
  }
}

/// Sicherheit einer Zuordnung. [compound] liefert nur Vorschläge.
enum MatchLevel { exact, alias, words, compound, none }

class CatalogMatch {
  final MatchLevel level;
  final List<Product> candidates;
  const CatalogMatch(this.level, this.candidates);
}
