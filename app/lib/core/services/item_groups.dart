// app/lib/core/services/item_groups.dart
//
// Grundartikel: Die Suche zeigt "Eier", nicht drei Eier-Produkte. Wer "Eier"
// antippt, wählt danach die Sorte (Bodenhaltung, Freiland, Bio) oder lässt es
// offen ("Egal": der Optimierer nimmt die günstigste).
//
// Die Zuordnung Produkt → Grundartikel steht in [_groups] (Reihenfolge zählt:
// Spezielles vor Allgemeinem, "Milchreis" vor "Milch"). Was in keine Gruppe
// fällt, ist sein eigener Grundartikel (Name ohne Größe, siehe genericName).

import '../models/item_amount.dart';
import '../models/product.dart';
import 'catalog_service.dart';

class ItemGroup {
  final String name;

  /// Suchwörter zusätzlich zum Namen ("spaghetti" → Nudeln).
  final List<String> keywords;
  final List<Product> products;
  ItemGroup(this.name, this.keywords, this.products);

  bool get hasVariants => products.length > 1;

  /// Günstigster bekannter Preis über alle Sorten und Ketten (Cent).
  int? get fromPrice {
    int? best;
    for (final p in products) {
      for (final c in p.prices.values) {
        if (best == null || c < best) best = c;
      }
    }
    return best;
  }

  /// Kurzer Name der Sorte: "Freilandeier" → "Freiland", "Bio Eier" → "Bio",
  /// "Red Bull Energy Drink" → "Red Bull". Gleiche Kurznamen in einer Gruppe
  /// (zweimal "Standard") werden durch den vollen Produktnamen ersetzt.
  String variantLabel(Product p) => (_labels ??= _buildLabels())[p.id] ?? p.name;

  Map<String, String>? _labels;

  Map<String, String> _buildLabels() {
    final short = {for (final p in products) p.id: _shortLabel(p)};
    final counts = <String, int>{};
    for (final l in short.values) {
      counts[l.toLowerCase()] = (counts[l.toLowerCase()] ?? 0) + 1;
    }
    return {
      for (final p in products) p.id: (counts[short[p.id]!.toLowerCase()]! > 1) ? p.name : short[p.id]!,
    };
  }

  String _shortLabel(Product p) {
    var s = genericName(p);
    final esc = RegExp.escape(name);
    // ganzes Wort entfernen ("Bio Eier" → "Bio")
    s = s.replaceAll(RegExp('(^|\\s)$esc(?=\\s|\$)', caseSensitive: false), ' ');
    // Kompositum-Ende ("Freilandeier" → "Freiland"), aber nicht "Coca-Cola"
    s = s.replaceAllMapped(RegExp('(\\S{3,})$esc(?=\\s|\$)', caseSensitive: false),
        (m) => m.group(1)!.endsWith('-') ? m.group(0)! : m.group(1)!);
    s = s.replaceAll(RegExp(r'(^|\s)(Frische?|Frischer)(?=\s|$)'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    s = s.replaceAll(RegExp(r'^[-/&\s]+|[-/&\s]+$'), '').trim();
    final brand = p.brand?.trim() ?? '';
    final realBrand = brand.isNotEmpty && brand != 'Eigenmarke' && brand != 'Fairtrade';
    if (s.isEmpty) return p.isBio ? 'Bio' : (realBrand ? brand : 'Standard');
    s = s[0].toUpperCase() + s.substring(1);
    // Marke voranstellen, wenn sie im Kurznamen fehlt ("Oatly Hafermilch Barista")
    if (realBrand && !s.toLowerCase().contains(brand.toLowerCase()) && !p.name.toLowerCase().startsWith(s.toLowerCase())) {
      final inName = p.name.toLowerCase().contains(brand.toLowerCase());
      if (inName) s = '$brand $s';
    }
    return s;
  }
}

class _Rule {
  final String name;
  final RegExp include;
  final List<String> keywords;
  _Rule(this.name, String pattern, [this.keywords = const []]) : include = RegExp(pattern, caseSensitive: false);
}

// Reihenfolge zählt: die erste passende Regel gewinnt.
final _rules = <_Rule>[
  // Zuerst, was andere Wörter enthält
  _Rule('Kartoffelchips', r'chips|pringles', ['chips']),
  _Rule('Schokolade', r'schokolade|ritter sport', ['schoko']),
  _Rule('Milchreis & Dessert', r'milchreis|dessert', ['milchreis', 'pudding', 'dessert']),
  _Rule('Duschgel', r'duschgel|dusche', ['dusche']),
  _Rule('Pflanzendrink', r'hafermilch|haferdrink|sojadrink', ['hafermilch', 'haferdrink', 'sojamilch', 'oatly']),
  _Rule('Toastbrot', r'toast', ['toast']),
  _Rule('Knäckebrot', r'knäckebrot'),
  _Rule('Baguette', r'baguette'),
  _Rule('Erdnussbutter', r'erdnussbutter'),
  _Rule('Kekse', r'keks|prinzen rolle', ['keks', 'kekse']),
  _Rule('Thunfisch', r'thunfisch'),
  _Rule('Aufschnitt', r'kochschinken|lachsschinken|mortadella|^salami|\ssalami', ['schinken', 'salami', 'wurst']),
  _Rule('Speck', r'bacon|speck|schinkenwürfel', ['bacon', 'schinkenwürfel']),
  _Rule('Spülmaschinensalz', r'spezialsalz'),
  _Rule('Klarspüler', r'klarspüler'),
  _Rule('Spülmaschinentabs', r'spülmaschinentabs', ['tabs']),
  _Rule('Salzstangen', r'salzstangen'),
  _Rule('Eistee', r'eistee'),
  _Rule('Vegane Alternativen', r'vegan', ['vegan']),
  _Rule('Pizzaboden', r'pizzaboden'),
  _Rule('Gemüsebrühe', r'brühe'),
  _Rule('Paprikapulver', r'paprikapulver'),
  _Rule('Dosentomaten', r'passierte|gehackte tomaten|stückige tomaten', ['passierte tomaten', 'tomaten dose']),
  _Rule('Erdbeerkonfitüre', r'konfitüre|marmelade', ['marmelade', 'konfitüre']),
  // Obst und Gemüse
  _Rule('Bananen', r'banane', ['banane']),
  _Rule('Äpfel', r'^(bio )?äpfel', ['apfel']),
  _Rule('Gurke', r'gurke'),
  _Rule('Tomaten', r'rispentomaten|cherrytomaten'),
  _Rule('Kartoffeln', r'kartoffeln', ['kartoffel']),
  _Rule('Zwiebeln', r'zwiebeln', ['zwiebel']),
  _Rule('Möhren', r'^(bio )?(möhren|karotten)', ['karotten', 'möhre']),
  _Rule('Paprika', r'paprika', ['spitzpaprika']),
  _Rule('Salat', r'eisbergsalat|kopfsalat', ['eisbergsalat', 'kopfsalat']),
  _Rule('Champignons', r'champignons', ['pilze']),
  _Rule('Avocado', r'avocado'),
  _Rule('Erdbeeren', r'^erdbeeren', ['erdbeere']),
  _Rule('Zitronen', r'zitronen', ['zitrone']),
  // Kühlregal
  _Rule('Skyr', r'skyr'),
  _Rule('Milch', r'milch', ['vollmilch', 'h-milch']),
  _Rule('Frischkäse', r'frischkäse|philadelphia'),
  _Rule('Mozzarella', r'mozzarella'),
  _Rule('Feta', r'feta|hirtenkäse', ['schafskäse', 'hirtenkäse']),
  _Rule('Käse', r'gouda|butterkäse|emmentaler|camembert|parmigiano', ['gouda', 'emmentaler', 'parmesan']),
  _Rule('Butter', r'butter', ['markenbutter']),
  _Rule('Quark', r'quark', ['magerquark']),
  _Rule('Joghurt', r'joghurt|activia', ['jogurt']),
  _Rule('Sahne', r'sahne', ['schlagsahne']),
  _Rule('Eier', r'eier(\s|$)', ['ei']),
  // Brot und Backen
  _Rule('Brot', r'brot(\s|$)', ['vollkornbrot', 'mischbrot']),
  _Rule('Brötchen', r'brötchen'),
  _Rule('Wraps', r'wraps|tortilla'),
  _Rule('Haferflocken', r'flocken'),
  _Rule('Mehl', r'mehl'),
  _Rule('Zucker', r'zucker'),
  // Fleisch und Fisch
  _Rule('Hackfleisch', r'hack', ['hack']),
  _Rule('Hähnchen', r'hähnchen', ['huhn', 'hühnchen']),
  _Rule('Bratwurst', r'bratwurst'),
  _Rule('Würstchen', r'würstchen', ['wiener']),
  _Rule('Lachs', r'lachs'),
  _Rule('Fischstäbchen', r'fischstäbchen'),
  _Rule('Tofu', r'tofu'),
  // Vorrat
  _Rule('Nudeln', r'spaghetti|penne|fusilli', ['pasta', 'spaghetti', 'penne', 'fusilli']),
  _Rule('Reis', r'reis(\s|$)|reis$', ['basmati']),
  _Rule('Pesto', r'pesto'),
  _Rule('Öl', r'öl(\s|$)', ['olivenöl', 'rapsöl', 'sonnenblumenöl']),
  _Rule('Essig', r'essig'),
  _Rule('Senf', r'senf'),
  _Rule('Ketchup', r'ketchup'),
  _Rule('Mayonnaise', r'mayonnaise|miracel', ['mayo']),
  _Rule('Nuss-Nougat-Creme', r'nougat|nutella', ['nutella']),
  _Rule('Müsli', r'müsli'),
  _Rule('Gummibärchen', r'goldbären|fruchtgummi', ['gummibärchen', 'haribo']),
  _Rule('Nüsse', r'erdnüsse|studentenfutter|mandeln|cashew', ['nüsse', 'mandeln']),
  _Rule('Schokoriegel', r'knoppers|hanuta|duplo|kinder riegel|m&ms', ['riegel']),
  // Getränke
  _Rule('Mineralwasser', r'wasser|gerolsteiner|volvic', ['wasser', 'sprudel']),
  _Rule('Saft', r'saft|hohes c', ['orangensaft', 'apfelsaft']),
  _Rule('Cola', r'(^|[\s-])cola', ['coca-cola']),
  _Rule('Limonade', r'fanta|sprite', ['limo', 'fanta', 'sprite']),
  _Rule('Energy Drink', r'energy', ['red bull']),
  _Rule('Kaffee', r'kaffee|espresso|caffè|krönung|feine milde', ['espresso', 'bohnen']),
  _Rule('Tee', r'tee(\s|$)|kamille'),
  _Rule('Bier', r'bier|pils', ['pils']),
  // Haushalt und Drogerie
  _Rule('Toilettenpapier', r'toilettenpapier', ['klopapier']),
  _Rule('Taschentücher', r'taschentücher'),
  _Rule('Spülmittel', r'spülmittel'),
  _Rule('Reiniger', r'reiniger|wc-', ['putzmittel']),
  _Rule('Waschmittel', r'waschmittel'),
  _Rule('Zahnpasta', r'zahnpasta|colgate', ['zahncreme']),
  _Rule('Müllbeutel', r'müllbeutel'),
];

class ItemGroups {
  static List<ItemGroup>? _cache;
  static List<Product>? _cacheFor;

  /// Alle Grundartikel des Katalogs.
  static List<ItemGroup> get all {
    final products = CatalogService.products;
    if (_cache != null && identical(_cacheFor, products)) return _cache!;
    _cacheFor = products;
    return _cache = build(products);
  }

  static List<ItemGroup> build(List<Product> products) {
    final byName = <String, List<Product>>{};
    final keywords = <String, List<String>>{};
    for (final p in products) {
      final rule = _ruleFor(p);
      final name = rule?.name ?? genericName(p);
      byName.putIfAbsent(name, () => []).add(p);
      keywords[name] = rule?.keywords ?? const [];
    }
    return [for (final e in byName.entries) ItemGroup(e.key, keywords[e.key]!, e.value)];
  }

  static _Rule? _ruleFor(Product p) {
    final text = p.name.toLowerCase();
    for (final r in _rules) {
      if (r.include.hasMatch(text)) return r;
    }
    return null;
  }

  /// Grundartikel eines Produkts.
  static ItemGroup? groupOf(Product p) {
    for (final g in all) {
      if (g.products.any((x) => x.id == p.id)) return g;
    }
    return null;
  }

  static ItemGroup? byName(String name) {
    final n = name.trim().toLowerCase();
    for (final g in all) {
      if (g.name.toLowerCase() == n) return g;
    }
    return null;
  }

  /// Suche: Produkte wie bisher finden (Treffergüte, Gewohnheit), dann zu
  /// Grundartikeln zusammenfassen. Reihenfolge = bester Treffer je Gruppe.
  /// Ein exakt getippter Grundartikel ("eier") steht immer vorn.
  static List<ItemGroup> search(String query, {int limit = 5}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <ItemGroup>[];
    void add(ItemGroup? g) {
      if (g != null && !out.contains(g)) out.add(g);
    }

    for (final g in all) {
      if (g.name.toLowerCase() == q || g.keywords.contains(q)) add(g);
    }
    for (final p in CatalogService.getSuggestions(query, limit: 40)) {
      add(groupOf(p));
      if (out.length >= limit) break;
    }
    return out.take(limit).toList();
  }
}
