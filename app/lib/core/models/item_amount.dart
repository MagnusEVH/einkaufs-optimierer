// app/lib/core/models/item_amount.dart
//
// Menge auf der Liste: freiwillig, mit Einheit. "Erdbeeren" ohne Angabe heißt
// "einmal, wie üblich". Gibt man etwas an ("500 g Erdbeeren", "Milch 2 l",
// "3 Äpfel"), steht es klein neben dem Namen. Der Optimierer rechnet daraus
// die Zahl der Packungen ("750 g" bei 500-g-Schalen = 2 Schalen).

import 'dart:math' as math;

import 'product.dart';

/// Einheiten wie auf dem Server (Spalte `shopping_items.unit`).
enum AmountUnit {
  stk('stk', 'Stück', 1, [1, 2, 3, 4, 6, 10]),
  g('g', 'g', 50, [100, 250, 500, 750]),
  kg('kg', 'kg', 0.5, [1, 1.5, 2, 3]),
  ml('ml', 'ml', 100, [200, 250, 500, 750]),
  l('l', 'l', 0.5, [1, 1.5, 2, 3]),
  pck('pck', 'Packung', 1, [1, 2, 3, 4]),
  bund('bund', 'Bund', 1, [1, 2, 3]);

  final String code;
  final String label;

  /// Schritt für Plus/Minus.
  final double step;

  /// Schnellwahl im Mengen-Dialog.
  final List<double> quick;
  const AmountUnit(this.code, this.label, this.step, this.quick);

  static AmountUnit? fromCode(String? c) {
    for (final u in values) {
      if (u.code == c) return u;
    }
    return null;
  }

  bool get isWeight => this == g || this == kg;
  bool get isVolume => this == ml || this == l;
  bool get isCount => !isWeight && !isVolume;

  /// Kleinste Menge: Stück & Co. ganze Zahlen, sonst ein Schritt.
  double get min => isCount ? 1 : step;

  /// Server erlaubt höchstens 999.
  double get max => 999;
}

/// Wörter für Einheiten in der Eingabe (klein geschrieben).
const _unitWords = <String, AmountUnit>{
  'g': AmountUnit.g,
  'gr': AmountUnit.g,
  'gramm': AmountUnit.g,
  'kg': AmountUnit.kg,
  'kilo': AmountUnit.kg,
  'ml': AmountUnit.ml,
  'l': AmountUnit.l,
  'liter': AmountUnit.l,
  'ltr': AmountUnit.l,
  'stk': AmountUnit.stk,
  'st': AmountUnit.stk,
  'stück': AmountUnit.stk,
  'stueck': AmountUnit.stk,
  'x': AmountUnit.stk,
  'pck': AmountUnit.pck,
  'pkg': AmountUnit.pck,
  'pack': AmountUnit.pck,
  'packung': AmountUnit.pck,
  'packungen': AmountUnit.pck,
  'bund': AmountUnit.bund,
};

class ItemAmount {
  final double quantity;
  final AmountUnit? unit;
  const ItemAmount(this.quantity, [this.unit]);

  static const none = ItemAmount(1);

  /// Keine Angabe: ohne Einheit. Steht dann nicht in der Liste. "1 Stück"
  /// ausdrücklich gewählt zählt als Angabe ("1×").
  bool get isDefault => quantity == 1 && unit == null;

  AmountUnit get effectiveUnit => unit ?? AmountUnit.stk;

  /// Große Gramm/Milliliter-Werte in kg/l (Server erlaubt höchstens 999).
  ItemAmount normalized() {
    final q = _round(quantity);
    if (unit == AmountUnit.g && q >= 1000) return ItemAmount(_round(q / 1000), AmountUnit.kg);
    if (unit == AmountUnit.ml && q >= 1000) return ItemAmount(_round(q / 1000), AmountUnit.l);
    if (unit == AmountUnit.kg && q < 1) return ItemAmount(_round(q * 1000), AmountUnit.g);
    if (unit == AmountUnit.l && q < 1) return ItemAmount(_round(q * 1000), AmountUnit.ml);
    final u = effectiveUnit;
    return ItemAmount(q.clamp(u.min, u.max).toDouble(), unit);
  }

  /// Ein Schritt mehr oder weniger, nie unter das Minimum.
  ItemAmount stepBy(int direction) {
    final u = effectiveUnit;
    final next = quantity + direction * u.step;
    if (next < u.min) return ItemAmount(u.min, unit);
    return ItemAmount(next, unit).normalized();
  }

  /// Text neben dem Namen. Leer, wenn nichts angegeben ist.
  String get label {
    if (isDefault) return '';
    final n = formatNumber(quantity);
    return switch (effectiveUnit) {
      AmountUnit.stk => '$n×',
      AmountUnit.pck => quantity == 1 ? '1 Packung' : '$n Packungen',
      AmountUnit.bund => '$n Bund',
      final u => '$n ${u.label}',
    };
  }

  /// Für Vorlesen und Hinweise.
  String get spoken => isDefault ? '' : (effectiveUnit == AmountUnit.stk ? '${formatNumber(quantity)} Stück' : label);

  static String formatNumber(double v) {
    final r = _round(v);
    if (r == r.roundToDouble()) return r.toInt().toString();
    return r.toString().replaceAll('.', ',');
  }

  static double _round(double v) => (v * 1000).round() / 1000;

  @override
  bool operator ==(Object other) => other is ItemAmount && other.quantity == quantity && other.unit == unit;
  @override
  int get hashCode => Object.hash(quantity, unit);
  @override
  String toString() => 'ItemAmount($quantity ${unit?.code})';
}

/// Eingabe in Name und Menge zerlegt.
class ParsedInput {
  final String name;
  final ItemAmount amount;
  const ParsedInput(this.name, this.amount);
}

const _num = r'(\d+(?:[.,]\d+)?)';
const _unit = r'(kg|kilo|gramm|gr|g|ml|liter|ltr|l|stück|stueck|stk|st|packungen|packung|pack|pck|pkg|bund|x)';
final _lead = RegExp('^$_num\\s*$_unit?\\.?\\s+(.+)\$', caseSensitive: false);
// "2x Milch", "2 x Milch", "2xMilch" – aber nicht "2 Xylit"
final _leadX = RegExp(r'^(\d+)(?:\s*[x×]\s+|[x×]\s*)(.+)$', caseSensitive: false);
final _trail = RegExp('^(.+?)\\s+$_num\\s*$_unit\\.?\$', caseSensitive: false);
final _trailX = RegExp(r'^(.+?)\s+[x×]\s*(\d+)$', caseSensitive: false);

double _parseNum(String s) => double.parse(s.replaceAll(',', '.'));

/// "500 g Erdbeeren", "500g Erdbeeren", "Erdbeeren 500g", "2x Milch",
/// "Milch x2", "3 Äpfel", "Mehl 1,5 kg". Ohne Menge: Name, keine Angabe.
/// Eine nackte Zahl hinten ("Cola 0") bleibt Teil des Namens.
ParsedInput parseItemInput(String input) {
  final text = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  RegExpMatch? m;
  if ((m = _leadX.firstMatch(text)) != null) {
    return _result(m!.group(2)!, _parseNum(m.group(1)!), AmountUnit.stk);
  }
  if ((m = _trailX.firstMatch(text)) != null) {
    return _result(m!.group(1)!, _parseNum(m.group(2)!), AmountUnit.stk);
  }
  if ((m = _lead.firstMatch(text)) != null) {
    final unit = m!.group(2) == null ? AmountUnit.stk : _unitWords[m.group(2)!.toLowerCase()]!;
    return _result(m.group(3)!, _parseNum(m.group(1)!), unit);
  }
  if ((m = _trail.firstMatch(text)) != null) {
    return _result(m!.group(1)!, _parseNum(m.group(2)!), _unitWords[m.group(3)!.toLowerCase()]!);
  }
  return ParsedInput(text, ItemAmount.none);
}

ParsedInput _result(String name, double q, AmountUnit unit) {
  final n = name.trim();
  if (n.isEmpty || q <= 0) return ParsedInput(n.isEmpty ? '' : n, ItemAmount.none);
  final a = ItemAmount(q, unit == AmountUnit.stk && q == 1 ? null : unit).normalized();
  return ParsedInput(n[0].toUpperCase() + n.substring(1), a);
}

/// Was auf der Liste steht, wenn man ein Katalogprodukt wählt: das Ding an
/// sich, ohne Größe und Verpackung. "Erdbeeren 500g" → "Erdbeeren",
/// "Freilandeier Gr. M/L 10er" → "Freilandeier", "Zitronen Netz 500g" →
/// "Zitronen". Die Marke bleibt: Wer "Coca-Cola" wählt, meint sie auch
/// (ohne Marke bliebe nur "Original").
String genericName(Product p) {
  var s = ' ${p.name} ';
  const units = r'g|kg|ml|cl|l|m|stk|stück|er|blatt|rollen|tabs|wl|beutel|bögen';
  final cuts = [
    RegExp('\\s\\d+\\s*[x×]\\s*\\d+(?:[.,]\\d+)?\\s*(?:$units)?(?=\\s)', caseSensitive: false), // 8x200 Blatt, 30x10er
    RegExp('\\s\\d+(?:[.,]\\d+)?\\s*(?:$units)\\.?(?=\\s)', caseSensitive: false), // 500g, 1,5L, 50 Beutel
    RegExp(r'\s\d+(?:[.,]\d+)?\s*%(?=\s)'), // 20%
    RegExp(r'\s\d+-lagig(?=\s)', caseSensitive: false),
    RegExp(r'\sGr\.\s*[A-Z/]+(?=\s)'), // Gr. M/L
    RegExp(r'\s(?:Blatt|Rollen)(?=\s)'),
  ];
  for (final c in cuts) {
    s = s.replaceAll(c, ' ');
  }
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Verpackung am Ende: "Gehackte Tomaten Dose" → "Gehackte Tomaten"
  final pack = RegExp(r'\s(?:Dose|Flasche|Glas|Netz|Box|Pack|Packung|Schale|Beutel)$');
  final trimmed = s.replaceFirst(pack, '');
  if (trimmed.isNotEmpty) s = trimmed;
  return s.isEmpty ? p.name : s;
}

/// Wie viele Packungen des Produkts für die Menge nötig sind (mindestens 1).
/// Gewicht/Volumen wird mit der Packungsgröße verrechnet, Stück und Packung
/// zählen als Packungen (wie bisher).
int packsNeeded(ItemAmount a, Product? p) {
  final u = a.effectiveUnit;
  if (!u.isCount) {
    final want = _base(a.quantity, u);
    final pack = p == null ? null : _productBase(p);
    if (want != null && pack != null && pack.$2 == want.$2 && pack.$1 > 0) {
      return math.max(1, (want.$1 / pack.$1 - 1e-9).ceil());
    }
    return 1; // kein Produkt oder Einheit passt nicht: eine Packung
  }
  return math.max(1, a.quantity.ceil());
}

/// (Menge in g oder ml, 'g'/'ml')
(double, String)? _base(double q, AmountUnit u) => switch (u) {
      AmountUnit.g => (q, 'g'),
      AmountUnit.kg => (q * 1000, 'g'),
      AmountUnit.ml => (q, 'ml'),
      AmountUnit.l => (q * 1000, 'ml'),
      _ => null,
    };

(double, String)? _productBase(Product p) => switch (p.quantityUnit.toLowerCase()) {
      'g' => (p.quantityAmount, 'g'),
      'kg' => (p.quantityAmount * 1000, 'g'),
      'ml' => (p.quantityAmount, 'ml'),
      'l' => (p.quantityAmount * 1000, 'ml'),
      _ => null,
    };

/// Sinnvolle Einheit für den Mengen-Dialog, wenn noch nichts angegeben ist.
AmountUnit suggestedUnit(Product? p) => switch (p?.quantityUnit.toLowerCase()) {
      'g' => AmountUnit.g,
      'kg' => AmountUnit.kg,
      'ml' => AmountUnit.ml,
      'l' => AmountUnit.l,
      _ => AmountUnit.stk,
    };
