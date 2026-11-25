// app/lib/features/trip/trip_controller.dart
//
// Laufender Einkauf: Route mit Märkten, je Markt die Artikel, Status je Artikel.
// Wird lokal gespeichert, damit ein Neuladen im Laden nichts verliert.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/optimization_result.dart';
import '../../core/models/store.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/item_icons.dart';
import '../../core/services/my_stores_service.dart';
import '../../core/services/optimizer_service.dart';
import '../../core/services/preferences_storage.dart';
import '../shopping_list/shopping_list_controller.dart';

enum TripItemStatus { open, done, missing }

class TripItem {
  final String listItemId;
  final String name;
  final String rawText;
  final String? productId;
  final double quantity;
  final int priceCents;
  final TripItemStatus status;

  const TripItem({
    required this.listItemId,
    required this.name,
    required this.rawText,
    this.productId,
    required this.quantity,
    required this.priceCents,
    this.status = TripItemStatus.open,
  });

  TripItem copyWith({TripItemStatus? status, int? priceCents}) => TripItem(
        listItemId: listItemId,
        name: name,
        rawText: rawText,
        productId: productId,
        quantity: quantity,
        priceCents: priceCents ?? this.priceCents,
        status: status ?? this.status,
      );

  /// Warengruppe für die Sortierung im Markt.
  String get categoryId {
    final p = productId == null ? null : CatalogService.products.where((x) => x.id == productId).firstOrNull;
    return ItemIcons.categoryFor(p?.name ?? name, product: p).id;
  }

  String get icon {
    final p = productId == null ? null : CatalogService.products.where((x) => x.id == productId).firstOrNull;
    return ItemIcons.iconFor(p?.name ?? name, product: p);
  }

  Map<String, dynamic> toJson() => {
        'list_item_id': listItemId,
        'name': name,
        'raw_text': rawText,
        'product_id': productId,
        'quantity': quantity,
        'price_cents': priceCents,
        'status': status.name,
      };

  factory TripItem.fromJson(Map<String, dynamic> j) => TripItem(
        listItemId: j['list_item_id'].toString(),
        name: j['name']?.toString() ?? '',
        rawText: j['raw_text']?.toString() ?? '',
        productId: j['product_id']?.toString(),
        quantity: (j['quantity'] as num?)?.toDouble() ?? 1,
        priceCents: (j['price_cents'] as num?)?.toInt() ?? 0,
        status: TripItemStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => TripItemStatus.open),
      );
}

class TripStop {
  final String storeId;
  final SupermarketChain chain;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<TripItem> items;

  const TripStop({
    required this.storeId,
    required this.chain,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.items,
  });

  TripStop withItems(List<TripItem> items) => TripStop(
        storeId: storeId,
        chain: chain,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        items: items,
      );

  /// Artikel in der Reihenfolge der Warengruppen dieses Markts, Erledigtes unten.
  List<TripItem> get sortedItems {
    final order = MyStoresService.categoryOrder(chain.name);
    int rank(TripItem it) {
      final i = order.indexOf(it.categoryId);
      return i < 0 ? order.length : i;
    }

    final list = List.of(items);
    list.sort((a, b) {
      final da = a.status == TripItemStatus.open ? 0 : 1;
      final db = b.status == TripItemStatus.open ? 0 : 1;
      if (da != db) return da - db;
      return rank(a) - rank(b);
    });
    return list;
  }

  int get openCount => items.where((i) => i.status == TripItemStatus.open).length;

  Map<String, dynamic> toJson() => {
        'store_id': storeId,
        'chain': chain.name,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory TripStop.fromJson(Map<String, dynamic> j) => TripStop(
        storeId: j['store_id'].toString(),
        chain: SupermarketChain.fromString(j['chain']?.toString() ?? 'rewe'),
        name: j['name']?.toString() ?? '',
        address: j['address']?.toString() ?? '',
        latitude: (j['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 0,
        items: ((j['items'] as List?) ?? const []).map((e) => TripItem.fromJson((e as Map).cast<String, dynamic>())).toList(),
      );
}

class ShoppingTrip {
  final DateTime startedAt;
  final List<TripStop> stops;
  final int currentStop;
  final int plannedTotalCents;
  final int plannedSavingsCents;
  final List<String> unpricedItems;

  const ShoppingTrip({
    required this.startedAt,
    required this.stops,
    this.currentStop = 0,
    required this.plannedTotalCents,
    this.plannedSavingsCents = 0,
    this.unpricedItems = const [],
  });

  ShoppingTrip copyWith({List<TripStop>? stops, int? currentStop}) => ShoppingTrip(
        startedAt: startedAt,
        stops: stops ?? this.stops,
        currentStop: currentStop ?? this.currentStop,
        plannedTotalCents: plannedTotalCents,
        plannedSavingsCents: plannedSavingsCents,
        unpricedItems: unpricedItems,
      );

  Iterable<TripItem> get allItems => stops.expand((s) => s.items);
  int get doneCount => allItems.where((i) => i.status == TripItemStatus.done).length;
  int get totalCount => allItems.length;
  int get doneCents => allItems
      .where((i) => i.status == TripItemStatus.done)
      .fold(0, (a, i) => a + (i.priceCents * i.quantity).round());

  factory ShoppingTrip.fromResult(OptimizationResult r, {DateTime? now}) => ShoppingTrip(
        startedAt: now ?? DateTime.now(),
        plannedTotalCents: r.summary.totalBasketPriceCents,
        plannedSavingsCents: r.summary.netSavingsCents > 0 ? r.summary.netSavingsCents : 0,
        unpricedItems: r.unpricedItems,
        stops: r.stops
            .map((s) => TripStop(
                  storeId: s.storeId,
                  chain: s.chain,
                  name: s.storeName,
                  address: s.address,
                  latitude: s.latitude,
                  longitude: s.longitude,
                  items: s.items
                      .map((a) => TripItem(
                            listItemId: a.listItemId ?? a.rawText,
                            name: a.itemName,
                            rawText: a.rawText,
                            productId: a.productId,
                            quantity: a.quantity,
                            priceCents: a.unitPriceCents,
                          ))
                      .toList(),
                ))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'started_at': startedAt.toIso8601String(),
        'stops': stops.map((s) => s.toJson()).toList(),
        'current_stop': currentStop,
        'planned_total_cents': plannedTotalCents,
        'planned_savings_cents': plannedSavingsCents,
        'unpriced_items': unpricedItems,
      };

  factory ShoppingTrip.fromJson(Map<String, dynamic> j) => ShoppingTrip(
        startedAt: DateTime.tryParse(j['started_at']?.toString() ?? '') ?? DateTime.now(),
        stops: ((j['stops'] as List?) ?? const []).map((e) => TripStop.fromJson((e as Map).cast<String, dynamic>())).toList(),
        currentStop: (j['current_stop'] as num?)?.toInt() ?? 0,
        plannedTotalCents: (j['planned_total_cents'] as num?)?.toInt() ?? 0,
        plannedSavingsCents: (j['planned_savings_cents'] as num?)?.toInt() ?? 0,
        unpricedItems: ((j['unpriced_items'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}

class TripController extends StateNotifier<ShoppingTrip?> {
  TripController(this._ref) : super(null) {
    _load();
  }

  final Ref _ref;
  static const _key = 'shopping_trip_v1';

  Future<void> _load() async {
    final raw = await PreferencesStorage.loadJson(_key);
    if (raw is Map && state == null) {
      try {
        state = ShoppingTrip.fromJson(raw.cast<String, dynamic>());
      } catch (_) {
        state = null;
      }
    }
  }

  void _set(ShoppingTrip? trip) {
    state = trip;
    if (trip == null) {
      PreferencesStorage.saveJson(_key, false);
    } else {
      PreferencesStorage.saveJson(_key, trip.toJson());
    }
  }

  void start(OptimizationResult result) => _set(ShoppingTrip.fromResult(result));

  void setCurrentStop(int index) {
    final t = state;
    if (t == null) return;
    _set(t.copyWith(currentStop: index.clamp(0, t.stops.length - 1)));
  }

  void _updateItem(int stopIndex, String listItemId, TripItem Function(TripItem) f) {
    final t = state;
    if (t == null) return;
    final stops = List.of(t.stops);
    final stop = stops[stopIndex];
    stops[stopIndex] = stop.withItems(stop.items.map((i) => i.listItemId == listItemId ? f(i) : i).toList());
    _set(t.copyWith(stops: stops));
  }

  /// Abhaken bzw. wieder öffnen (sofort, ohne Wartezeit).
  void toggleDone(int stopIndex, String listItemId) => _updateItem(
        stopIndex,
        listItemId,
        (i) => i.copyWith(status: i.status == TripItemStatus.done ? TripItemStatus.open : TripItemStatus.done),
      );

  /// "Nicht da": Artikel wandert zum nächsten Markt der Route, sonst bleibt er offen für die Liste.
  void markMissing(int stopIndex, String listItemId) {
    final t = state;
    if (t == null) return;
    final stops = List.of(t.stops);
    final stop = stops[stopIndex];
    final item = stop.items.firstWhere((i) => i.listItemId == listItemId);
    if (stopIndex + 1 < stops.length) {
      stops[stopIndex] = stop.withItems(stop.items.where((i) => i.listItemId != listItemId).toList());
      final next = stops[stopIndex + 1];
      // Preis der nächsten Kette, falls bekannt (sonst bleibt der geplante)
      final listItem = _ref.read(shoppingListProvider).items.where((i) => i.id == item.listItemId).firstOrNull;
      final product = listItem?.matchedProduct ??
          (item.productId == null ? null : CatalogService.products.where((p) => p.id == item.productId).firstOrNull);
      final price = OptimizerService.unitPrice(product, next.chain, DateTime.now());
      stops[stopIndex + 1] = next.withItems([...next.items, item.copyWith(status: TripItemStatus.open, priceCents: price)]);
    } else {
      stops[stopIndex] = stop.withItems(
        stop.items.map((i) => i.listItemId == listItemId ? i.copyWith(status: TripItemStatus.missing) : i).toList(),
      );
    }
    _set(t.copyWith(stops: stops));
  }

  /// Abschluss: Gekauftes verlässt die Liste, Offenes und "Nicht da" bleiben.
  void finish() {
    final t = state;
    if (t == null) return;
    final done = t.allItems.where((i) => i.status == TripItemStatus.done).map((i) => i.listItemId).toSet();
    _ref.read(shoppingListProvider.notifier).removeItems(done);
    _set(null);
  }

  void cancel() => _set(null);
}

final tripProvider = StateNotifierProvider<TripController, ShoppingTrip?>((ref) => TripController(ref));
