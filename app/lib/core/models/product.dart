// app/lib/core/models/product.dart

class Product {
  final String id;
  final String? categoryId;
  final String gtinBarcode;
  final String name;
  final String? brand;
  final double quantityAmount;
  final String quantityUnit;
  final bool isBio;
  final bool isPrivateLabel;
  final List<String> aliases;
  final Map<String, int> prices; // chain -> price in cents

  const Product({
    required this.id,
    this.categoryId,
    required this.gtinBarcode,
    required this.name,
    this.brand,
    this.quantityAmount = 1.0,
    this.quantityUnit = 'piece',
    this.isBio = false,
    this.isPrivateLabel = false,
    this.aliases = const [],
    this.prices = const {},
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['prices'] as Map<String, dynamic>? ?? {};
    final parsedPrices = <String, int>{};
    rawPrices.forEach((k, v) {
      if (v is int) parsedPrices[k] = v;
      if (v is num) parsedPrices[k] = v.toInt();
    });

    return Product(
      id: json['id'] ?? '',
      categoryId: json['category_id'],
      gtinBarcode: json['gtin_barcode'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'],
      quantityAmount: (json['quantity_amount'] as num?)?.toDouble() ?? 1.0,
      quantityUnit: json['quantity_unit'] ?? 'piece',
      isBio: json['is_bio'] ?? false,
      isPrivateLabel: json['is_private_label'] ?? false,
      aliases: (json['aliases'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      prices: parsedPrices,
    );
  }

  int? getPriceForChain(String chain) {
    return prices[chain.toLowerCase()];
  }

  String get formattedQuantity => '$quantityAmount $quantityUnit';
}
