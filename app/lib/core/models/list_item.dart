// app/lib/core/models/list_item.dart

import 'product.dart';

class ShoppingListItem {
  final String id;
  final String listId;
  final String rawText;
  final Product? matchedProduct;
  final double quantity;
  final String? unit;
  final bool isChecked;
  final String? notes;

  const ShoppingListItem({
    required this.id,
    required this.listId,
    required this.rawText,
    this.matchedProduct,
    this.quantity = 1.0,
    this.unit,
    this.isChecked = false,
    this.notes,
  });

  ShoppingListItem copyWith({
    String? id,
    String? listId,
    String? rawText,
    Product? matchedProduct,
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
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'],
      isChecked: json['is_checked'] ?? false,
      notes: json['notes'],
    );
  }
}
