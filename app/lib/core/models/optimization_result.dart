// app/lib/core/models/optimization_result.dart

import 'store.dart';

class AllocatedItem {
  /// ID des Listeneintrags (für Abhaken im Einkaufsmodus), lokal immer gesetzt.
  final String? listItemId;
  final String? productId;
  final String itemName;
  final String rawText;
  final String? brand;
  final double quantity;
  final int unitPriceCents;
  final int totalPriceCents;

  const AllocatedItem({
    this.listItemId,
    this.productId,
    required this.itemName,
    required this.rawText,
    this.brand,
    required this.quantity,
    required this.unitPriceCents,
    required this.totalPriceCents,
  });

  factory AllocatedItem.fromJson(Map<String, dynamic> json) {
    return AllocatedItem(
      listItemId: json['list_item_id'],
      productId: json['product_id'],
      itemName: json['item_name'] ?? '',
      rawText: json['raw_text'] ?? '',
      brand: json['brand'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPriceCents: json['unit_price_cents'] ?? 0,
      totalPriceCents: json['total_price_cents'] ?? 0,
    );
  }

  double get totalPriceEuros => totalPriceCents / 100.0;
}

class RouteStop {
  final int stopIndex;
  final String storeId;
  final SupermarketChain chain;
  final String storeName;
  final String address;
  final double latitude;
  final double longitude;
  final int? clusterId;
  final int itemsCount;
  final int stopSubtotalCents;
  final List<AllocatedItem> items;

  const RouteStop({
    required this.stopIndex,
    required this.storeId,
    required this.chain,
    required this.storeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.clusterId,
    required this.itemsCount,
    required this.stopSubtotalCents,
    required this.items,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return RouteStop(
      stopIndex: json['stop_index'] ?? 1,
      storeId: json['store_id'] ?? '',
      chain: SupermarketChain.fromString(json['chain'] ?? 'rewe'),
      storeName: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      clusterId: json['cluster_id'],
      itemsCount: json['items_count'] ?? rawItems.length,
      stopSubtotalCents: json['stop_subtotal_cents'] ?? 0,
      items: rawItems.map((e) => AllocatedItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  double get stopSubtotalEuros => stopSubtotalCents / 100.0;
}

class OptimizationSummary {
  final int totalBasketPriceCents;
  final int grossSavingsCents;
  final int travelPenaltyCents;
  final int netSavingsCents;
  final int totalRouteDistanceMeters;
  final int totalStops;
  /// Fahrtkosten der gewählten Route (für faire Vergleiche zwischen Vorschlägen).
  final int totalTravelCents;

  const OptimizationSummary({
    this.totalTravelCents = 0,
    required this.totalBasketPriceCents,
    required this.grossSavingsCents,
    required this.travelPenaltyCents,
    required this.netSavingsCents,
    required this.totalRouteDistanceMeters,
    required this.totalStops,
  });

  factory OptimizationSummary.fromJson(Map<String, dynamic> json) {
    return OptimizationSummary(
      totalBasketPriceCents: json['total_basket_price_cents'] ?? 0,
      grossSavingsCents: json['gross_savings_cents'] ?? 0,
      travelPenaltyCents: json['travel_penalty_cents'] ?? 0,
      netSavingsCents: json['net_savings_cents'] ?? 0,
      totalRouteDistanceMeters: json['total_route_distance_meters'] ?? 0,
      totalStops: json['total_stops'] ?? 1,
      totalTravelCents: json['total_travel_cents'] ?? 0,
    );
  }

  double get totalBasketPriceEuros => totalBasketPriceCents / 100.0;
  double get grossSavingsEuros => grossSavingsCents / 100.0;
  double get travelPenaltyEuros => travelPenaltyCents / 100.0;
  double get netSavingsEuros => netSavingsCents / 100.0;
  double get routeDistanceKm => totalRouteDistanceMeters / 1000.0;
}

class OptimizationResult {
  final String recommendationMode; // 'SINGLE_STORE' or 'MULTI_STORE'
  final OptimizationSummary summary;
  final List<RouteStop> stops;
  final Map<String, dynamic>? baselineSingleStore;
  /// Artikel, für die auf der empfohlenen Route kein Preis bekannt ist.
  /// Sie sind in keiner Summe enthalten.
  final List<String> unpricedItems;

  const OptimizationResult({
    required this.recommendationMode,
    required this.summary,
    required this.stops,
    this.baselineSingleStore,
    this.unpricedItems = const [],
  });

  bool get isMultiStore => recommendationMode == 'MULTI_STORE';

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    final rawStops = json['route_stops'] as List<dynamic>? ?? [];
    return OptimizationResult(
      recommendationMode: json['recommendation_mode'] ?? 'SINGLE_STORE',
      summary: OptimizationSummary.fromJson(json['summary'] ?? {}),
      stops: rawStops.map((e) => RouteStop.fromJson(e as Map<String, dynamic>)).toList(),
      baselineSingleStore: json['baseline_single_store'] as Map<String, dynamic>?,
      unpricedItems: (json['unpriced_items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
