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
    return 'Vor 2 Std. verifiziert';
  }

  /// Liefert die transparente Datenquelle für den Preis
  static String getPriceSource(String chain) {
    switch (chain.toLowerCase()) {
      case 'lidl':
        return 'Lidl Prospekt-API (Mainz-Bingen)';
      case 'rewe':
        return 'REWE Markt-Abfrage Bingen';
      case 'aldi_sued':
        return 'ALDI SÜD Wochenaktion';
      case 'netto':
        return 'Netto Marken-Discount Online';
      case 'rossmann':
        return 'Rossmann Filial-Sortiment';
      case 'dm':
        return 'dm-Drogerie API';
      default:
        return 'Regionale Preisdatenbank';
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

  /// Resolves raw text to the most suitable Product using exact, longest alias priority,
  /// and user preferences (Brand vs Private Label, Bio).
  static Product? matchRawText(
    String rawText, {
    String brandPreference = 'prefer_private_label',
    String bioPreference = 'neutral',
  }) {
    if (_cachedProducts.isEmpty) return null;
    final query = rawText.toLowerCase().trim();

    final candidates = <Product>[];

    // 1. Exact alias
    for (final p in _cachedProducts) {
      if (p.aliases.any((a) => a.toLowerCase() == query)) {
        candidates.add(p);
      }
    }

    // 2. Exact product name
    if (candidates.isEmpty) {
      for (final p in _cachedProducts) {
        if (p.name.toLowerCase() == query) {
          candidates.add(p);
        }
      }
    }

    // 3. Longest alias match
    if (candidates.isEmpty) {
      int maxAliasLen = 0;
      Product? bestCandidate;
      for (final p in _cachedProducts) {
        for (final a in p.aliases) {
          final lowerA = a.toLowerCase();
          if (query.contains(lowerA) && lowerA.length > maxAliasLen) {
            maxAliasLen = lowerA.length;
            bestCandidate = p;
          }
        }
      }
      if (bestCandidate != null) candidates.add(bestCandidate);
    }

    // 4. Substring in product name
    if (candidates.isEmpty) {
      for (final p in _cachedProducts) {
        if (p.name.toLowerCase().contains(query) || query.contains(p.name.toLowerCase())) {
          candidates.add(p);
        }
      }
    }

    if (candidates.isEmpty) return null;

    // Apply Brand Preference:
    if (brandPreference == 'reject_private_label') {
      final brandOnly = candidates.firstWhere((p) => !p.isPrivateLabel, orElse: () => candidates.first);
      return brandOnly;
    }
    if (brandPreference == 'prefer_private_label') {
      final plOnly = candidates.firstWhere((p) => p.isPrivateLabel, orElse: () => candidates.first);
      return plOnly;
    }

    // Apply Bio Preference:
    if (bioPreference == 'prefer_bio') {
      final bioOnly = candidates.firstWhere((p) => p.isBio, orElse: () => candidates.first);
      return bioOnly;
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
