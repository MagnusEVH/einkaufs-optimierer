// app/lib/core/services/optimizer_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/list_item.dart';
import '../models/optimization_result.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../models/user_preferences.dart';
import 'catalog_service.dart';
import 'location_service.dart';
import 'supabase_service.dart';
import 'wallet_service.dart';

class OptimizerService {
  /// Optimizes shopping list either via Supabase Edge Function or local engine
  static Future<OptimizationResult> optimizeShoppingList({
    required UserLocation userLocation,
    required List<ShoppingListItem> items,
    required UserPreferences preferences,
    List<Store>? availableStores,
    Store? anchorStore,
  }) async {
    if (items.isEmpty) {
      throw Exception('Einkaufsliste ist leer.');
    }

    // Try Remote Edge Function if Supabase is active
    if (!SupabaseService.isDemoMode && SupabaseService.client != null) {
      try {
        final payload = {
          'user_location': {
            'latitude': userLocation.latitude,
            'longitude': userLocation.longitude,
          },
          'items': items.map((it) => {
            'raw_text': it.rawText,
            'matched_product_id': it.matchedProduct?.id,
            'quantity': it.quantity,
          }).toList(),
          'preferences': preferences.toJson(),
        };

        final response = await SupabaseService.client!.functions.invoke(
          'optimize-route',
          body: payload,
        );

        if (response.status == 200 && response.data != null) {
          final data = response.data is String ? json.decode(response.data as String) : response.data;
          return OptimizationResult.fromJson(data as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Remote optimizer failed: $e. Falling back to local optimization engine.');
      }
    }

    // Local Optimization Engine (Runs directly on device / offline)
    return _runLocalOptimization(
      userLocation: userLocation,
      items: items,
      preferences: preferences,
      stores: availableStores ?? _defaultSampleStores,
      anchorStore: anchorStore,
    );
  }

  // --- LOCAL OPTIMIZATION ENGINE ---

  static double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLon = (lon2 - lon1) * (pi / 180.0);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) * cos(lat2 * (pi / 180.0)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static int _getPriceWithOffers(Product? prod, Store store, String rawText) {
    int basePrice = prod?.getPriceForChain(store.chain.name) ?? 199;
    final nameLower = (prod?.name ?? rawText).toLowerCase();

    for (final offer in WalletService.weeklyOffers) {
      if (offer.chain == store.chain && offer.isActive) {
        if (nameLower.contains(offer.productName.toLowerCase()) ||
            offer.productName.toLowerCase().contains(nameLower)) {
          return offer.discountPriceCents;
        }
      }
    }
    return basePrice;
  }

  static OptimizationResult _runLocalOptimization({
    required UserLocation userLocation,
    required List<ShoppingListItem> items,
    required UserPreferences preferences,
    required List<Store> stores,
    Store? anchorStore,
  }) {
    // 1. Resolve catalog items
    final resolvedList = items.map((it) {
      final matched = it.matchedProduct ?? CatalogService.matchRawText(it.rawText);
      return {
        'raw_text': it.rawText,
        'matched': matched,
        'quantity': it.quantity,
      };
    }).toList();

    // 2. Evaluate Single Store solutions
    int bestSingleBasket = 999999999;
    Store bestSingleStore = anchorStore ?? stores.first;
    double bestSingleDist = 99999999.0;

    for (final store in (anchorStore != null ? [anchorStore] : stores)) {
      int sum = 0;
      for (final it in resolvedList) {
        final prod = it['matched'] as Product?;
        final qty = it['quantity'] as double;
        final price = prod?.getPriceForChain(store.chain.name) ?? 199;
        sum += (price * qty).round();
      }

      final dist = _haversineMeters(
        userLocation.latitude,
        userLocation.longitude,
        store.latitude,
        store.longitude,
      ) * 2;

      if (sum < bestSingleBasket) {
        bestSingleBasket = sum;
        bestSingleStore = store;
        bestSingleDist = dist;
      }
    }

    // 3. Multi-Store 2-Stop Combinations
    int bestMultiBasket = bestSingleBasket;
    List<Store> bestMultiStores = [bestSingleStore];
    Map<String, List<AllocatedItem>> bestAssignment = {};
    int bestNetSavings = 0;
    int bestGrossSavings = 0;
    int bestTravelPenalty = 0;
    double bestMultiDist = bestSingleDist;

    for (int i = 0; i < stores.length; i++) {
      for (int j = i + 1; j < stores.length; j++) {
        var s1 = stores[i];
        var s2 = stores[j];

        // If an anchorStore is selected, enforce that the route starts with this store
        if (anchorStore != null) {
          if (s1.id != anchorStore.id && s2.id != anchorStore.id) continue;
          if (s2.id == anchorStore.id) {
            // Swap so anchorStore is s1 (Start stop)
            final temp = s1;
            s1 = s2;
            s2 = temp;
          }
        }

        int comboSum = 0;
        final s1Items = <AllocatedItem>[];
        final s2Items = <AllocatedItem>[];

        for (final it in resolvedList) {
          final prod = it['matched'] as Product?;
          final rawText = it['raw_text'] as String;
          final qty = it['quantity'] as double;

          // Check if promotional offer overrides regular price
          final p1 = _getPriceWithOffers(prod, s1, rawText);
          final p2 = _getPriceWithOffers(prod, s2, rawText);

          // Detect Category for preference weighting (e.g. Obst -> Netto, Gemüse -> Lidl)
          String catKey = 'allgemein';
          final nameLower = (prod?.name ?? rawText).toLowerCase();
          if (nameLower.contains('apfel') ||
              nameLower.contains('banane') ||
              nameLower.contains('beere') ||
              nameLower.contains('zitrone') ||
              nameLower.contains('erdbeer') ||
              nameLower.contains('obst')) {
            catKey = 'obst';
          } else if (nameLower.contains('gurke') ||
              nameLower.contains('tomate') ||
              nameLower.contains('brokkoli') ||
              nameLower.contains('salat') ||
              nameLower.contains('möhre') ||
              nameLower.contains('karotte') ||
              nameLower.contains('zwiebel') ||
              nameLower.contains('kartoffel') ||
              nameLower.contains('gemüse') ||
              nameLower.contains('gemuese')) {
            catKey = 'gemuese';
          } else if (nameLower.contains('toilettenpapier') ||
              nameLower.contains('klopapier') ||
              nameLower.contains('duschgel') ||
              nameLower.contains('shampoo') ||
              nameLower.contains('zahnpasta') ||
              nameLower.contains('seife') ||
              nameLower.contains('windel') ||
              nameLower.contains('waschmittel') ||
              nameLower.contains('drogerie')) {
            catKey = 'drogerie';
          }

          int effectiveP1 = p1;
          int effectiveP2 = p2;

          final prefChain = preferences.categoryStorePreferences[catKey];
          if (prefChain != null) {
            if (s1.chain.name.contains(prefChain.toLowerCase())) effectiveP1 -= 50;
            if (s2.chain.name.contains(prefChain.toLowerCase())) effectiveP2 -= 50;
          }

          if (effectiveP1 <= effectiveP2) {
            final total = (p1 * qty).round();
            s1Items.add(AllocatedItem(
              itemName: prod?.name ?? rawText,
              rawText: rawText,
              brand: prod?.brand,
              quantity: qty,
              unitPriceCents: p1,
              totalPriceCents: total,
            ));
            comboSum += total;
          } else {
            final total = (p2 * qty).round();
            s2Items.add(AllocatedItem(
              itemName: prod?.name ?? rawText,
              rawText: rawText,
              brand: prod?.brand,
              quantity: qty,
              unitPriceCents: p2,
              totalPriceCents: total,
            ));
            comboSum += total;
          }
        }

        if (s1Items.isEmpty || s2Items.isEmpty) continue;

        // Route distance with cluster discount (< 500m)
        final intraDist = _haversineMeters(s1.latitude, s1.longitude, s2.latitude, s2.longitude);
        double routeDist = _haversineMeters(userLocation.latitude, userLocation.longitude, s1.latitude, s1.longitude);
        if (intraDist <= 500) {
          routeDist += intraDist * 0.2; // 80% discount for clustered stops
        } else {
          routeDist += intraDist;
        }
        routeDist += _haversineMeters(s2.latitude, s2.longitude, userLocation.latitude, userLocation.longitude);

        final extraDist = max(0.0, routeDist - bestSingleDist);
        final travelPenalty = ((extraDist / 1000.0) * preferences.costPerKmCents).round();
        final grossSavings = bestSingleBasket - comboSum;
        final netSavings = grossSavings - travelPenalty;

        if (netSavings > bestNetSavings) {
          bestNetSavings = netSavings;
          bestGrossSavings = grossSavings;
          bestTravelPenalty = travelPenalty;
          bestMultiBasket = comboSum;
          bestMultiStores = [s1, s2];
          bestMultiDist = routeDist;
          bestAssignment = {
            s1.id: s1Items,
            s2.id: s2Items,
          };
        }
      }
    }

    final isMulti = bestNetSavings > 50 && preferences.maxStops >= 2;

    final stops = <RouteStop>[];
    if (isMulti) {
      for (int i = 0; i < bestMultiStores.length; i++) {
        final store = bestMultiStores[i];
        final storeItems = bestAssignment[store.id] ?? [];
        final subtotal = storeItems.fold<int>(0, (acc, it) => acc + it.totalPriceCents);

        stops.add(RouteStop(
          stopIndex: i + 1,
          storeId: store.id,
          chain: store.chain,
          storeName: store.name,
          address: store.address,
          latitude: store.latitude,
          longitude: store.longitude,
          clusterId: store.clusterNum,
          itemsCount: storeItems.length,
          stopSubtotalCents: subtotal,
          items: storeItems,
        ));
      }
    } else {
      // Single store
      final singleItems = resolvedList.map((it) {
        final prod = it['matched'] as Product?;
        final rawText = it['raw_text'] as String;
        final qty = it['quantity'] as double;
        final price = prod?.getPriceForChain(bestSingleStore.chain.name) ?? 199;
        final total = (price * qty).round();
        return AllocatedItem(
          itemName: prod?.name ?? rawText,
          rawText: rawText,
          brand: prod?.brand,
          quantity: qty,
          unitPriceCents: price,
          totalPriceCents: total,
        );
      }).toList();

      stops.add(RouteStop(
        stopIndex: 1,
        storeId: bestSingleStore.id,
        chain: bestSingleStore.chain,
        storeName: bestSingleStore.name,
        address: bestSingleStore.address,
        latitude: bestSingleStore.latitude,
        longitude: bestSingleStore.longitude,
        clusterId: bestSingleStore.clusterNum,
        itemsCount: singleItems.length,
        stopSubtotalCents: bestSingleBasket,
        items: singleItems,
      ));
    }

    return OptimizationResult(
      recommendationMode: isMulti ? 'MULTI_STORE' : 'SINGLE_STORE',
      summary: OptimizationSummary(
        totalBasketPriceCents: isMulti ? bestMultiBasket : bestSingleBasket,
        grossSavingsCents: isMulti ? bestGrossSavings : 0,
        travelPenaltyCents: isMulti ? bestTravelPenalty : 0,
        netSavingsCents: isMulti ? bestNetSavings : 0,
        totalRouteDistanceMeters: (isMulti ? bestMultiDist : bestSingleDist).round(),
        totalStops: stops.length,
      ),
      stops: stops,
      baselineSingleStore: {
        'name': bestSingleStore.name,
        'chain': bestSingleStore.chain.name,
        'total_basket_price_cents': bestSingleBasket,
      },
    );
  }

  static final List<Store> _defaultSampleStores = [
    Store(
      id: '44444444-0000-0000-0000-000000000001',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Bingen-Büdesheim',
      address: 'Saarlandstraße 165, 55411 Bingen am Rhein',
      latitude: 49.9545,
      longitude: 7.9172,
      clusterNum: 10,
    ),
    Store(
      id: '44444444-0000-0000-0000-000000000002',
      chain: SupermarketChain.lidl,
      name: 'Lidl Filiale Bingen-Büdesheim',
      address: 'Saarlandstraße 171, 55411 Bingen am Rhein',
      latitude: 49.9542,
      longitude: 7.9160, // 88m from Aldi -> Cluster 10!
      clusterNum: 10,
    ),
    Store(
      id: '44444444-0000-0000-0000-000000000003',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Bingen',
      address: 'Mainzer Straße 44, 55411 Bingen am Rhein',
      latitude: 49.9658,
      longitude: 7.9045,
      clusterNum: 11,
    ),
    Store(
      id: '44444444-0000-0000-0000-000000000004',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Bingen',
      address: 'Vorstadt 10-12, 55411 Bingen am Rhein',
      latitude: 49.9662,
      longitude: 7.8965,
      clusterNum: 12,
    ),
    Store(
      id: '44444444-0000-0000-0000-000000000005',
      chain: SupermarketChain.rossmann,
      name: 'Rossmann Drogeriemarkt Bingen',
      address: 'Basilikastraße 3, 55411 Bingen am Rhein',
      latitude: 49.9670,
      longitude: 7.8940, // 200m from dm -> Cluster 12!
      clusterNum: 12,
    ),
    Store(
      id: '44444444-0000-0000-0000-000000000006',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Oberwesel',
      address: 'Chrishausener Str. 2, 55430 Oberwesel',
      latitude: 50.1082,
      longitude: 7.7285,
      clusterNum: 20,
    ),
    Store(
      id: '44444444-0000-0000-0000-000000000007',
      chain: SupermarketChain.rewe,
      name: 'REWE City Oberwesel',
      address: 'Koblenzer Str. 18, 55430 Oberwesel',
      latitude: 50.1105,
      longitude: 7.7260, // 300m from Netto -> Cluster 20!
      clusterNum: 20,
    ),
    Store(
      id: '33333333-0000-0000-0000-000000000001',
      chain: SupermarketChain.lidl,
      name: 'Lidl Filiale Köln Kalk',
      address: 'Rolshover Str. 11, 51105 Köln',
      latitude: 50.9335,
      longitude: 6.9942,
      clusterNum: 1,
    ),
    Store(
      id: '33333333-0000-0000-0000-000000000002',
      chain: SupermarketChain.rewe,
      name: 'REWE Center Kalk',
      address: 'Kalker Hauptstraße 55, 51103 Köln',
      latitude: 50.9348,
      longitude: 6.9965, // 217m away from Lidl Kalk -> Cluster 1!
      clusterNum: 1,
    ),
    Store(
      id: '33333333-0000-0000-0000-000000000005',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Köln Kalk',
      address: 'Kalker Post 12, 51103 Köln',
      latitude: 50.9352,
      longitude: 6.9930, // 230m from Lidl -> Cluster 1!
      clusterNum: 1,
    ),
    Store(
      id: '33333333-0000-0000-0000-000000000003',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Köln Deutz',
      address: 'Siegburger Str. 149, 50679 Köln',
      latitude: 50.9270,
      longitude: 6.9805,
      clusterNum: 2,
    ),
    Store(
      id: '33333333-0000-0000-0000-000000000004',
      chain: SupermarketChain.lidl,
      name: 'Lidl Filiale Köln Deutz',
      address: 'Deutzer Freiheit 70, 50679 Köln',
      latitude: 50.9290,
      longitude: 6.9775, // 306m away from Aldi Deutz -> Cluster 2!
      clusterNum: 2,
    ),
  ];
}
