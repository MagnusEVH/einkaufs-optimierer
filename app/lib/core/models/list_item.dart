// app/lib/core/models/list_item.dart

import 'item_amount.dart';
import 'product.dart';

class ShoppingListItem {
  final String id;
  final String listId;

  /// Was auf der Liste steht: das Ding an sich ("Eier").
  final String rawText;
  final Product? matchedProduct;

  /// true: Sorte ausdrücklich gewählt ("Freiland"). Der Optimierer nimmt dann
  /// genau dieses Produkt. false: Die App sucht selbst (günstigste, Vorlieben).
  final bool pinned;
  final double quantity;
  final String? unit;
  final bool isChecked;
  final String? notes;

  const ShoppingListItem({
    required this.id,
    required this.listId,
    required this.rawText,
    this.matchedProduct,
    this.pinned = false,
    this.quantity = 1.0,
    this.unit,
    this.isChecked = false,
    this.notes,
  });

  /// Menge mit Einheit (Standard: keine Angabe).
  ItemAmount get amount => ItemAmount(quantity, AmountUnit.fromCode(unit));

  /// Setzt Menge und Einheit, auch zurück auf "keine Angabe".
  ShoppingListItem withAmount(ItemAmount a) => ShoppingListItem(
        id: id,
        listId: listId,
        rawText: rawText,
        matchedProduct: matchedProduct,
        pinned: pinned,
        quantity: a.quantity,
        unit: a.isDefault ? null : a.unit?.code,
        isChecked: isChecked,
        notes: notes,
      );

  /// Sorte setzen ([product]) oder offen lassen (null, [fallback] = Treffer
  /// der App für den Namen).
  ShoppingListItem withVariant(Product? product, {Product? fallback}) => ShoppingListItem(
        id: id,
        listId: listId,
        rawText: rawText,
        matchedProduct: product ?? fallback,
        pinned: product != null,
        quantity: quantity,
        unit: unit,
        isChecked: isChecked,
        notes: notes,
      );

  ShoppingListItem copyWith({
    String? id,
    String? listId,
    String? rawText,
    Product? matchedProduct,
    bool? pinned,
    double? quantity,
    String? unit,
    bool? isChecked,
    String? notes,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      rawText: rawText ?? this.rawText,
      matchedProduct: matchedProduct ?? this.matchedProduct,
      pinned: pinned ?? this.pinned,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'raw_text': rawText,
      'matched_product_id': matchedProduct?.id,
      'pinned': pinned,
      'quantity': quantity,
      'unit': unit,
      'is_checked': isChecked,
      'notes': notes,
    };
  }

  factory ShoppingListItem.fromJson(Map<String, dynamic> json, {Product? matched}) {
    return ShoppingListItem(
      id: json['id'] ?? '',
      listId: json['list_id'] ?? '',
      rawText: json['raw_text'] ?? '',
      matchedProduct: matched,
      // Ältere Einträge ohne Merkmal: gewählt, wenn der Name dem Produkt entspricht
      pinned: json['pinned'] as bool? ?? (matched != null && matched.name == json['raw_text']),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'],
      isChecked: json['is_checked'] ?? false,
      notes: json['notes'],
    );
  }
}
