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
    if (_cachedProducts.isEmpty) return null;
    final queryWords = tokenize(rawText);
    if (queryWords.isEmpty) return null;
    final query = queryWords.join(' ');

    var candidates = <Product>[];

    // 1. Exakter Alias oder Name
    for (final p in _cachedProducts) {
      if (tokenize(p.name).join(' ') == query ||
          p.aliases.any((a) => tokenize(a).join(' ') == query)) {
        candidates.add(p);
      }
    }

    // 2. Längster Alias als Wortfolge im Suchtext
    if (candidates.isEmpty) {
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

    // 3. Alle Suchwörter kommen als ganze Wörter im Produktnamen vor
    if (candidates.isEmpty) {
      for (final p in _cachedProducts) {
        final nameWords = tokenize(p.name).toSet();
        if (queryWords.every(nameWords.contains)) candidates.add(p);
      }
    }

    if (candidates.isEmpty) return null;

    // Bio-/Nicht-Bio-Varianten derselben Ware ergänzen ("Gurke" ↔ "Bio Gurke").
    if (bioPreference != 'neutral') {
      String core(Product p) => (tokenize(p.name)..remove('bio')).join(' ');
      final cores = candidates.map(core).toSet();
      for (final p in _cachedProducts) {
        if (!candidates.contains(p) && cores.contains(core(p))) candidates.add(p);
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
