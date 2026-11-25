// app/lib/core/services/item_icons.dart
//
// Icon und Warengruppe für jeden Listenartikel (Vorbild: Bring!).
// Reihenfolge der Regeln zählt: zusammengesetzte Wörter zuerst
// ("Kartoffelchips" ist Snack, nicht Gemüse; "Butterkeks" ist Keks).
// Icons sind Emoji. Flutter Web zeichnet sie mit der Schrift Noto Color Emoji
// (Google, SIL Open Font License), geladen von fonts.gstatic.com und per sw.js gecacht.

import '../models/product.dart';

class ItemCategory {
  final String id;
  final String name;
  final String icon;
  const ItemCategory(this.id, this.name, this.icon);
}

class ItemIcons {
  ItemIcons._();

  static const fallbackIcon = '🛒';
  static const other = ItemCategory('sonstiges', 'Sonstiges', '🛒');

  /// Warengruppen, IDs wie im Katalog (products_seed_250.json).
  static const categories = <ItemCategory>[
    ItemCategory('11111111-0000-0000-0000-000000000001', 'Obst & Gemüse', '🥦'),
    ItemCategory('11111111-0000-0000-0000-000000000003', 'Brot & Backwaren', '🍞'),
    ItemCategory('11111111-0000-0000-0000-000000000002', 'Molkerei & Eier', '🥛'),
    ItemCategory('11111111-0000-0000-0000-000000000004', 'Fleisch, Fisch & Veggie', '🍗'),
    ItemCategory('11111111-0000-0000-0000-000000000005', 'Vorrat & Teigwaren', '🥫'),
    ItemCategory('11111111-0000-0000-0000-000000000006', 'Süßes & Snacks', '🍪'),
    ItemCategory('11111111-0000-0000-0000-000000000007', 'Getränke & Kaffee', '🥤'),
    ItemCategory('11111111-0000-0000-0000-000000000008', 'Drogerie & Haushalt', '🧴'),
  ];

  static const _obst = '11111111-0000-0000-0000-000000000001';
  static const _molkerei = '11111111-0000-0000-0000-000000000002';
  static const _brot = '11111111-0000-0000-0000-000000000003';
  static const _fleisch = '11111111-0000-0000-0000-000000000004';
  static const _vorrat = '11111111-0000-0000-0000-000000000005';
  static const _suess = '11111111-0000-0000-0000-000000000006';
  static const _getraenke = '11111111-0000-0000-0000-000000000007';
  static const _drogerie = '11111111-0000-0000-0000-000000000008';

  /// (Wortanfänge oder Wortteile, Icon, Warengruppe). Erste passende Regel gewinnt.
  static const List<(List<String>, String, String)> _rules = [
    // Drogerie & Haushalt zuerst (enthält Wörter wie "salz", "milch", "mandel")
    (['spülmaschine', 'spuelmaschine', 'klarspüler', 'spülmittel', 'pril', 'somat', 'geschirr', 'schwamm'], '🧽', _drogerie),
    (['waschmittel', 'weichspüler', 'ariel', 'persil'], '🧺', _drogerie),
    (['toilettenpapier', 'klopapier', 'küchenrolle', 'kuechenrolle', 'taschentüch', 'tempo'], '🧻', _drogerie),
    (['zahnpasta', 'zahnbürste', 'zahncreme', 'colgate', 'elmex', 'zahnseide'], '🪥', _drogerie),
    (['duschgel', 'pflegedusche', 'shampoo', 'seife', 'deo', 'creme soft', 'nivea', 'bodylotion', 'spülung'], '🧴', _drogerie),
    (['reiniger', 'wc-', 'meister proper', 'putz', 'essigreiniger'], '🧴', _drogerie),
    (['müllbeutel', 'muellbeutel', 'müllsack'], '🗑️', _drogerie),
    (['alufolie', 'backpapier', 'frischhaltefolie', 'gefrierbeutel'], '📦', _drogerie),
    (['windel', 'feuchttücher'], '👶', _drogerie),
    (['batterie'], '🔋', _drogerie),
    // Zusammengesetzte Lebensmittel vor ihren Bestandteilen
    (['chips', 'pringles', 'chipsfrisch'], '🥔', _suess),
    (['pizzaboden'], '🍕', _brot),
    (['pizza', 'ristorante'], '🍕', _vorrat),
    (['müsli', 'muesli', 'cornflakes', 'granola'], '🥣', _vorrat),
    (['haferflocken', 'flocken'], '🥣', _brot),
    (['milchreis', 'pudding', 'grand dessert', 'dessert'], '🍮', _molkerei),
    (['gehackte tomaten', 'tomatenmark', 'passierte', 'polpa'], '🥫', _vorrat),
    (['ketchup', 'mayonnaise', 'miracel', 'senf', 'remoulade'], '🫙', _vorrat),
    (['konfitüre', 'marmelade', 'gelee'], '🍓', _vorrat),
    (['nutella', 'nuss-nougat', 'nougat'], '🍫', _vorrat),
    (['erdnussbutter'], '🥜', _vorrat),
    (['erdnussflips', 'erdnüsse', 'erdnuss', 'flips'], '🥜', _suess),
    (['schokolade', 'schoko', 'milka', 'ritter sport', 'kinder', 'duplo', 'hanuta', 'knoppers'], '🍫', _suess),
    (['keks', 'prinzen', 'leibniz', 'cookie', 'waffel'], '🍪', _suess),
    (['gummi', 'haribo', 'goldbären', 'fruchtgummi', 'bonbon', 'm&m', 'lakritz'], '🍬', _suess),
    (['salzstangen', 'brezel', 'laugen'], '🥨', _suess),
    (['mandel', 'cashew', 'studentenfutter', 'walnuss', 'haselnuss', 'nüsse'], '🌰', _suess),
    ([' eis ', 'speiseeis', 'magnum'], '🍨', _suess),
    (['wassermelone'], '🍉', _obst),
    (['fischstäbchen', 'thunfisch', 'lachsfilet', 'räucherlachs', 'fisch', 'hering', 'garnele'], '🐟', _fleisch),
    (['vegan', 'tofu', 'räuchertofu', 'seitan'], '🌱', _fleisch),
    (['falafel'], '🧆', _fleisch),
    (['hummus'], '🫘', _fleisch),
    (['schinken', 'bacon', 'speck'], '🥓', _fleisch),
    (['wurst', 'würstchen', 'wiener', 'salami', 'mortadella', 'aufschnitt', 'bratwurst'], '🌭', _fleisch),
    (['hähnchen', 'haehnchen', 'hühnchen', 'pute', 'geflügel', 'chicken'], '🍗', _fleisch),
    (['hackfleisch', 'hack ', 'rinderhack', 'rind',  'schwein', 'steak', 'schnitzel', 'gulasch', 'fleisch'], '🥩', _fleisch),
    (['eistee', 'ice tea'], '🧋', _getraenke),
    (['saft', 'schorle', 'nektar', 'hohes c', 'smoothie'], '🧃', _getraenke),
    ([' cola', '-cola', 'fanta', 'sprite', 'limo', 'energy', 'red bull', 'mezzo'], '🥤', _getraenke),
    (['wasser', 'gerolsteiner', 'volvic', 'sprudel'], '💧', _getraenke),
    (['bier', 'pils', 'krombacher', 'bitburger', 'radler', 'weizen 0,5'], '🍺', _getraenke),
    ([' wein', 'rotwein', 'weißwein', 'sekt', 'prosecco'], '🍷', _getraenke),
    (['kaffee', 'espresso', 'caffè', 'jacobs', 'tchibo', 'lavazza', 'kaffeepads', 'cappuccino'], '☕', _getraenke),
    (['tee', 'teekanne', 'kamille', 'pfefferminz'], '🍵', _getraenke),
    (['haferdrink', 'sojadrink', 'hafermilch', 'mandeldrink', 'oatly'], '🥛', _molkerei),
    (['knäckebrot', 'knaeckebrot', 'wasa'], '🍘', _brot),
    (['baguette'], '🥖', _brot),
    (['brötchen', 'broetchen', 'semmel', 'croissant'], '🥐', _brot),
    (['wrap', 'tortilla'], '🌯', _brot),
    (['toast', 'brot'], '🍞', _brot),
    (['kuchen', 'torte'], '🍰', _brot),
    (['käse', 'kaese', 'gouda', 'emmentaler', 'camembert', 'parmigiano', 'parmesan', 'feta', 'mozzarella', 'philadelphia', 'frischkäse'], '🧀', _molkerei),
    (['butter'], '🧈', _molkerei),
    (['eier ', ' ei '], '🥚', _molkerei),
    (['joghurt', 'skyr', 'quark', 'sahne', 'schmand', 'crème fraîche', 'creme fraiche', 'activia', 'kefir', 'buttermilch'], '🥛', _molkerei),
    (['milch'], '🥛', _molkerei),
    (['spaghetti', 'penne', 'fusilli', 'nudel', 'pasta', 'lasagne', 'tortellini'], '🍝', _vorrat),
    (['reis'], '🍚', _vorrat),
    (['dose', 'konserve'], '🥫', _vorrat),
    (['pesto'], '🌿', _vorrat),
    (['bohnen', 'kichererbsen', 'linsen'], '🫘', _vorrat),
    (['mais'], '🌽', _vorrat),
    (['erbsen'], '🫛', _vorrat),
    (['olivenöl', 'rapsöl', 'sonnenblumenöl', ' öl '], '🫒', _vorrat),
    (['essig', 'balsamico'], '🫙', _vorrat),
    (['salz', 'pfeffer', 'paprikapulver', 'gewürz', 'zimt'], '🧂', _vorrat),
    (['brühe', 'bruehe', 'suppe', 'fond'], '🍲', _vorrat),
    (['honig'], '🍯', _vorrat),
    (['mehl', 'zucker', 'backpulver', 'hefe', 'vanillezucker', 'stärke'], '🌾', _brot),
    // Obst & Gemüse zuletzt
    (['banane'], '🍌', _obst),
    (['apfel', 'äpfel', 'aepfel'], '🍎', _obst),
    (['birne'], '🍐', _obst),
    (['orange', 'mandarine', 'clementine'], '🍊', _obst),
    (['zitrone', 'limette'], '🍋', _obst),
    (['erdbeer'], '🍓', _obst),
    (['heidelbeer', 'blaubeer', 'himbeer', 'beeren'], '🫐', _obst),
    (['traube', 'weintraube'], '🍇', _obst),
    (['kiwi'], '🥝', _obst),
    (['melone'], '🍉', _obst),
    (['ananas'], '🍍', _obst),
    (['mango'], '🥭', _obst),
    (['avocado'], '🥑', _obst),
    (['gurke'], '🥒', _obst),
    (['zucchini'], '🥒', _obst),
    (['tomate'], '🍅', _obst),
    (['kartoffel'], '🥔', _obst),
    (['zwiebel'], '🧅', _obst),
    (['knoblauch'], '🧄', _obst),
    (['ingwer'], '🫚', _obst),
    (['möhre', 'moehre', 'karotte'], '🥕', _obst),
    (['paprika'], '🫑', _obst),
    (['brokkoli', 'blumenkohl', 'kohl'], '🥦', _obst),
    (['aubergine'], '🍆', _obst),
    (['champignon', 'pilz'], '🍄', _obst),
    (['salat', 'rucola', 'spinat', 'lauch', 'porree'], '🥬', _obst),
    (['obst'], '🍎', _obst),
    (['gemüse', 'gemuese'], '🥦', _obst),
  ];

  static (String, String)? _match(String text) {
    final n = ' ${text.toLowerCase()} ';
    for (final (words, icon, cat) in _rules) {
      for (final w in words) {
        if (n.contains(w)) return (icon, cat);
      }
    }
    return null;
  }

  /// Icon für einen Artikel: eigenes Icon, sonst das der Warengruppe, sonst 🛒.
  /// Bei Freitext (Text ≠ Produktname) zählt, was der Nutzer geschrieben hat:
  /// "saft" bleibt Saft, auch wenn der Katalog "Thunfisch in eigenem Saft" vorschlägt.
  static String iconFor(String text, {Product? product}) {
    final explicit = product == null || product.name == text;
    final m = explicit ? _match(product?.name ?? text) : (_match(text) ?? _match(product.name));
    if (m != null) return m.$1;
    final cat = _byId(product?.categoryId);
    return cat?.icon ?? fallbackIcon;
  }

  /// Warengruppe: bei Freitext aus dem Text, sonst aus dem Katalog.
  static ItemCategory categoryFor(String text, {Product? product}) {
    if (product != null && product.name != text) {
      final fromText = _byId(_match(text)?.$2);
      if (fromText != null) return fromText;
    }
    final fromCatalog = _byId(product?.categoryId);
    if (fromCatalog != null) return fromCatalog;
    return _byId(_match(text)?.$2) ?? other;
  }

  /// true, wenn der Text klar zu einer anderen Warengruppe gehört als das
  /// zugeordnete Produkt (Hinweis auf eine falsche Zuordnung).
  static bool contradicts(String text, Product product) {
    final fromText = _match(text)?.$2;
    return fromText != null && product.categoryId != null && fromText != product.categoryId;
  }

  static ItemCategory? _byId(String? id) {
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  static ItemCategory byId(String id) => _byId(id) ?? other;

  /// Standard-Reihenfolge der Warengruppen (ungefährer Weg durch den Markt).
  static List<String> get defaultOrder => [for (final c in categories) c.id, other.id];
}
