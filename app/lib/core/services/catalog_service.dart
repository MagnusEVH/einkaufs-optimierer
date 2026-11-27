// app/lib/core/services/catalog_service.dart

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import 'preferences_storage.dart';

class CatalogService {
  static List<Product> _cachedProducts = [];
  static bool _isLoaded = false;

  static List<Product> get products => _cachedProducts;

  // Wie oft und wann ein Produkt zuletzt auf die Liste kam (nur lokal).
  // Entscheidet bei gleich guten Treffern, wie bei Instacart oder Google:
  // zuerst die Treffergüte, die eigene Gewohnheit nur als Gleichstandsregel.
  static const _keyUsage = 'product_usage_v1';
  static final Map<String, ({int count, DateTime last})> _usage = {};

  static Future<void> loadUsage() async {
    final raw = await PreferencesStorage.loadJson(_keyUsage);
    _usage.clear();
    if (raw is! Map) return;
    raw.forEach((id, v) {
      if (v is Map && v['n'] is int && v['t'] is int) {
        _usage[id as String] = (count: v['n'] as int, last: DateTime.fromMillisecondsSinceEpoch(v['t'] as int));
      }
    });
  }

  /// Merkt sich, dass [productId] auf die Liste kam.
  static Future<void> recordUsage(String productId, {DateTime? now}) async {
    final old = _usage[productId];
    _usage[productId] = (count: (old?.count ?? 0) + 1, last: now ?? DateTime.now());
    await PreferencesStorage.saveJson(_keyUsage, {
      for (final e in _usage.entries) e.key: {'n': e.value.count, 't': e.value.last.millisecondsSinceEpoch},
    });
  }

  @visibleForTesting
  static void clearUsage() => _usage.clear();

  /// Häufigkeit mit Halbwertszeit 30 Tage: oft und kürzlich zählt am meisten.
  static double _usageScore(String productId, DateTime now) {
    final u = _usage[productId];
    if (u == null) return 0;
    final days = now.difference(u.last).inHours / 24;
    return u.count * math.pow(0.5, days / 30).toDouble();
  }

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
  ///
  /// Reihenfolge nach Treffergüte: genauer Name oder Alias, ganzes Wort,
  /// Ende eines zusammengesetzten Worts ("Freilandeier" sind Eier), Wortanfang,
  /// kleine Tippfehler ("joghrt" → Joghurt), zuletzt mitten im Wort
  /// ("Dreierpack" ist keine Eier). Bei gleicher Güte gewinnt, was man oft
  /// und kürzlich auf die Liste gesetzt hat, dann der kürzere Name.
  /// "ae/oe/ue/ss" und "ä/ö/ü/ß" gelten als gleich. Mehrere Wörter müssen alle passen.
  static List<Product> getSuggestions(String query, {int limit = 5, DateTime? now}) {
    final today = now ?? DateTime.now();
    final terms = _searchWords(query);
    if (terms.isEmpty) return [];

    final scored = <(Product, int)>[];
    final strong = <Product>{};
    for (final p in _cachedProducts) {
      final fields = [
        p.name,
        ...p.aliases,
        if (p.brand != null && !_genericBrands.contains(p.brand!.toLowerCase())) p.brand!,
      ];
      var total = 0;
      var allStrong = true;
      for (final t in terms) {
        var best = 0;
        for (final f in fields) {
          final words = _searchWords(f);
          final s = _termScore(t, words.join(' '), words);
          if (s > best) best = s;
        }
        if (best == 0) {
          total = 0;
          break;
        }
        if (best < _strongScore) allStrong = false;
        total += best;
      }
      if (total > 0) {
        scored.add((p, total));
        if (allStrong) strong.add(p);
      }
    }
    // Tippfehler und Treffer mitten im Wort nur, wenn nichts Besseres passt
    // (wie Typesense: Tippfehler erst bei zu wenigen Treffern). Sonst füllt
    // "eier" die freien Plätze mit "Energy Drink" oder "Dreierpack".
    if (strong.isNotEmpty) scored.removeWhere((e) => !strong.contains(e.$1));
    scored.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      if (byScore != 0) return byScore;
      final byUsage = _usageScore(b.$1.id, today).compareTo(_usageScore(a.$1.id, today));
      if (byUsage != 0) return byUsage;
      final byLength = a.$1.name.length.compareTo(b.$1.name.length);
      return byLength != 0 ? byLength : a.$1.name.compareTo(b.$1.name);
    });
    return scored.take(limit).map((e) => e.$1).toList();
  }

  /// Ab dieser Güte gilt ein Treffer als gut (Wortanfang oder besser).
  static const _strongScore = 70;

  /// Marken, die nichts unterscheiden ("Eigenmarke" steht bei 177 Produkten).
  static const _genericBrands = {'eigenmarke'};

  /// Umlaute auf den Grundbuchstaben: "käse", "kaese" und "kase" sind gleich,
  /// "apfel" findet auch "Äpfel". Beide Seiten werden gleich behandelt.
  static String _fold(String s) => s
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ae', 'a')
      .replaceAll('oe', 'o')
      .replaceAll('ue', 'u')
      .replaceAll('ß', 'ss');

  static List<String> _searchWords(String text) => _fold(text.toLowerCase())
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.isNotEmpty && w != 'eigenmarke')
      .toList();

  static int _termScore(String term, String field, List<String> words) {
    if (field == term || words.length == 1 && words.first == term) return 100;
    if (words.any((w) => w == term)) return 90;
    // Deutsches Kompositum: Das letzte Glied bestimmt, was es ist
    // ("Freilandeier"). Davor mindestens 3 Buchstaben, sonst wäre "Rucola" Cola.
    if (term.length >= 3 && words.any((w) => w.length - term.length >= 3 && w.endsWith(term))) return 85;
    // Wortanfang (70–79): je näher das Wort an der Eingabe, desto besser
    // ("ei" → "Eier" vor "Eisbergsalat"), erstes Wort leicht vorn.
    var prefix = 0;
    for (var i = 0; i < words.length; i++) {
      final w = words[i];
      if (!w.startsWith(term)) continue;
      final rest = w.length - term.length;
      final s = 70 + (rest < 8 ? 8 - rest : 0) + (i == 0 ? 1 : 0);
      if (s > prefix) prefix = s;
    }
    if (prefix > 0) return prefix;
    final typo = _typoScore(term, words);
    if (typo > 0) return typo;
    // Mitten im Wort zählt kaum ("eier" in "Dreierpack").
    if (term.length >= 4 && field.contains(term)) return 5;
    return 0;
  }

  /// Tippfehler wie bei Typesense: ab 4 Zeichen einer, ab 8 zwei. Auch gegen
  /// den Wortanfang, damit halb getippte Wörter passen ("joghr" → "joghurt").
  /// Ein falscher erster Buchstabe zählt doppelt (wie bei Algolia).
  static int _typoScore(String term, List<String> words) {
    if (term.length < 4) return 0;
    final allowed = term.length >= 8 ? 2 : 1;
    var best = allowed + 1;
    for (final w in words) {
      final whole = _editDistance(term, w);
      final prefix = w.length > term.length ? _editDistance(term, w.substring(0, term.length)) : whole;
      var d = whole < prefix ? whole : prefix;
      if (w.isNotEmpty && w[0] != term[0]) d += 1;
      if (d < best) best = d;
    }
    return best <= allowed ? 30 - best * 10 : 0;
  }

  /// Editierdistanz mit Vertauschung benachbarter Zeichen ("jgohurt").
  static int _editDistance(String a, String b) {
    final d = List.generate(a.length + 1, (i) => List<int>.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      d[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      d[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        var v = d[i - 1][j] + 1;
        if (d[i][j - 1] + 1 < v) v = d[i][j - 1] + 1;
        if (d[i - 1][j - 1] + cost < v) v = d[i - 1][j - 1] + cost;
        if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1] && d[i - 2][j - 2] + 1 < v) {
          v = d[i - 2][j - 2] + 1;
        }
        d[i][j] = v;
      }
    }
    return d[a.length][b.length];
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
      // Gleich lange Aliase ("KERRYGOLD BUTTER": "kerrygold" und "butter"):
      // es gewinnt, wessen Name und Marke mehr Suchwörter enthalten.
      if (candidates.length > 1) {
        int cover(Product p) {
          final words = tokenize('${p.name} ${p.brand ?? ''}').toSet();
          return queryWords.where(words.contains).length;
        }
        final top = candidates.map(cover).reduce((a, b) => a > b ? a : b);
        candidates = candidates.where((p) => cover(p) == top).toList();
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
