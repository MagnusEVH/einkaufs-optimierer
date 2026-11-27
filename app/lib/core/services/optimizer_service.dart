// app/lib/core/services/optimizer_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../features/stores_map/data/rlp_stores.dart';
import '../models/list_item.dart';
import '../models/optimization_result.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../models/user_preferences.dart';
import 'catalog_service.dart';
import 'location_service.dart';
import 'my_stores_service.dart';
import 'observed_price_service.dart';
import 'supabase_service.dart';
import 'wallet_service.dart';

/// Lokale Einkaufs-Optimierung.
///
/// Grundsätze (siehe Review 2026-11-22):
/// * Eine Kette ohne Preis für ein Produkt bietet es nicht an. Es gibt keine
///   Pauschalpreise; Artikel ohne Preis landen in [OptimizationResult.unpricedItems].
/// * Filialen kommen aus demselben Datensatz wie die Karte und werden nach
///   Umkreis um den echten Standort und nach bevorzugten Ketten gefiltert.
/// * Fahrtkosten gelten für jede Route ab dem Standort. Nur der Fußweg
///   zwischen zwei Nachbarmärkten (≤ [walkableMeters]) ist kostenfrei.
/// * Ersparnis = günstigster einzelner erreichbarer Markt minus Route,
///   jeweils inklusive Fahrtkosten.
class OptimizerService {
  /// Abstand, bis zu dem zwei Märkte zu Fuß verbunden werden (Auto bleibt stehen).
  static const double walkableMeters = 800;

  /// Mindest-Nettovorteil, ab dem ein zweiter Stopp empfohlen wird.
  static const int minMultiStopBenefitCents = 50;

  /// Bonus für die bevorzugte Kette einer Kategorie bei der Artikel-Zuteilung.
  /// Beeinflusst nur die Zuteilung, nie die ausgewiesenen Preise.
  static const int categoryPreferenceBonusCents = 50;

  static Future<OptimizationResult> optimizeShoppingList({
    required UserLocation userLocation,
    required List<ShoppingListItem> items,
    required UserPreferences preferences,
    List<Store>? availableStores,
    Store? anchorStore,
    List<Store>? fixedRoute,
    Set<String>? excludedStoreIds,
    DateTime? now,
  }) async {
    if (items.isEmpty) {
      throw Exception('Einkaufsliste ist leer.');
    }
    final openItems = items.where((it) => !it.isChecked).toList();
    if (openItems.isEmpty) {
      throw Exception('Alle Artikel sind bereits abgehakt.');
    }

    // Try Remote Edge Function if Supabase is active (nur ohne eigene Marktwahl)
    if (fixedRoute == null && SupabaseService.legacyBackend && SupabaseService.client != null) {
      try {
        final payload = {
          'user_location': {
            'latitude': userLocation.latitude,
            'longitude': userLocation.longitude,
          },
          'items': openItems.map((it) => {
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

    return runLocal(
      userLocation: userLocation,
      items: openItems,
      preferences: preferences,
      stores: availableStores ?? rlpStores,
      anchorStore: anchorStore,
      fixedRoute: fixedRoute,
      excludedStoreIds: excludedStoreIds ?? MyStoresService.disabledStoreIds,
      now: now ?? DateTime.now(),
    );
  }

  // --- LOCAL OPTIMIZATION ENGINE ---

  static double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLon = (lon2 - lon1) * (pi / 180.0);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) * cos(lat2 * (pi / 180.0)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  /// Stückpreis eines Produkts in einer Kette inkl. gültiger Angebote, oder
  /// null, wenn die Kette keinen Preis dafür hat. Ein echter Bonpreis ersetzt
  /// den Katalogpreis. Angebote greifen nur bei exakter Produkt-ID und im
  /// Gültigkeitszeitraum.
  static int? unitPrice(Product? prod, SupermarketChain chain, DateTime now) {
    if (prod == null) return null;
    int? price = ObservedPriceService.latest(prod.id, chain, now)?.priceCents ?? prod.getPriceForChain(chain.name);
    for (final offer in WalletService.weeklyOffers) {
      if (offer.chain != chain || offer.productId != prod.id) continue;
      if (!offer.isValidAt(now) || offer.discountPriceCents <= 0) continue;
      if (price == null || offer.discountPriceCents < price) {
        price = offer.discountPriceCents;
      }
    }
    return price;
  }

  /// Filialen, die für die Optimierung in Frage kommen.
  static List<Store> candidateStores({
    required UserLocation userLocation,
    required UserPreferences preferences,
    required List<Store> stores,
    Store? anchorStore,
    Set<String> excludedStoreIds = const {},
  }) {
    final allowed = preferences.preferredChains.map((c) => c.toLowerCase()).toSet();
    final result = stores.where((s) {
      if (excludedStoreIds.contains(s.id)) return false;
      if (allowed.isNotEmpty && !allowed.contains(s.chain.name)) return false;
      final d = haversineMeters(userLocation.latitude, userLocation.longitude, s.latitude, s.longitude);
      return d <= preferences.searchRadiusMeters;
    }).toList();
    if (anchorStore != null && !result.any((s) => s.id == anchorStore.id)) {
      result.insert(0, anchorStore);
    }
    return result;
  }

  static String _categoryKey(Product? prod, String rawText) {
    final n = (prod?.name ?? rawText).toLowerCase();
    bool any(List<String> words) => words.any(n.contains);
    if (any(['apfel', 'äpfel', 'banane', 'beere', 'zitrone', 'erdbeer', 'obst'])) return 'obst';
    if (any(['gurke', 'tomate', 'brokkoli', 'salat', 'möhre', 'karotte', 'zwiebel', 'kartoffel', 'gemüse', 'gemuese'])) {
      return 'gemuese';
    }
    if (any(['toilettenpapier', 'klopapier', 'duschgel', 'shampoo', 'zahnpasta', 'seife', 'windel', 'waschmittel', 'drogerie'])) {
      return 'drogerie';
    }
    return 'allgemein';
  }

  static OptimizationResult runLocal({
    required UserLocation userLocation,
    required List<ShoppingListItem> items,
    required UserPreferences preferences,
    required List<Store> stores,
    Store? anchorStore,
    List<Store>? fixedRoute,
    Set<String> excludedStoreIds = const {},
    required DateTime now,
  }) {
    final open = items.where((it) => !it.isChecked).toList();
    if (open.isEmpty) {
      throw Exception('Alle Artikel sind bereits abgehakt.');
    }

    final candidates = candidateStores(
      userLocation: userLocation,
      preferences: preferences,
      stores: stores,
      anchorStore: anchorStore,
      excludedStoreIds: excludedStoreIds,
    );
    // Selbst gewählte Märkte gehören immer dazu, auch außerhalb des Umkreises.
    final fixed = fixedRoute ?? const <Store>[];
    for (final s in fixed) {
      if (!candidates.any((c) => c.id == s.id)) candidates.add(s);
    }
    if (candidates.isEmpty) {
      throw Exception(
        'Keine passende Filiale im Umkreis von ${(preferences.searchRadiusMeters / 1000).toStringAsFixed(1)} km. '
        'Umkreis oder Ketten in den Einstellungen anpassen.',
      );
    }

    // 1. Artikel auflösen. Freitext wird mit den Präferenzen neu zugeordnet,
    //    damit Bio- und Marken-Einstellungen wirken. Ausdrücklich gewählte
    //    Produkte (Name = Artikeltext) bleiben unverändert.
    final resolved = open.map((it) {
      final chosen = it.matchedProduct;
      final isExplicit = chosen != null && chosen.name == it.rawText;
      final prod = isExplicit
          ? chosen
          : CatalogService.matchRawText(
                it.rawText,
                brandPreference: preferences.brandPreference,
                bioPreference: preferences.bioPreference,
              ) ??
              chosen;
      final prices = <String, int>{};
      for (final s in candidates) {
        final p = unitPrice(prod, s.chain, now);
        if (p != null) prices[s.id] = p;
      }
      return _ResolvedItem(
        listItemId: it.id,
        rawText: it.rawText,
        product: prod,
        quantity: it.quantity,
        category: _categoryKey(prod, it.rawText),
        pricesByStore: prices,
      );
    }).toList();

    // 2. Alle Einzel- und Zwei-Stopp-Pläne bewerten.
    final plans = <_Plan>[];
    final anchorId = anchorStore?.id;
    for (final s in candidates) {
      if (anchorId != null && s.id != anchorId) continue;
      plans.add(_evaluate([s], resolved, userLocation, preferences));
    }
    if (plans.isEmpty) {
      throw Exception('Ausgangsfiliale ist nicht verfügbar.');
    }
    final bestSingle = plans.reduce(_better);

    _Plan? bestMulti;
    if (preferences.maxStops >= 2) {
      for (int i = 0; i < candidates.length; i++) {
        for (int j = 0; j < candidates.length; j++) {
          if (i == j) continue;
          final s1 = candidates[i];
          final s2 = candidates[j];
          // Reihenfolge zählt nur für den Startpunkt; ohne Anker reicht i < j.
          if (anchorId != null) {
            if (s1.id != anchorId) continue;
          } else if (j < i) {
            continue;
          }
          final plan = _evaluate([s1, s2], resolved, userLocation, preferences);
          if (plan.allocations.values.any((l) => l.isEmpty)) continue;
          if (bestMulti == null || _better(plan, bestMulti) == plan) bestMulti = plan;
        }
      }
    }

    // 3. Zweiter Stopp nur, wenn er mehr Artikel abdeckt oder spürbar günstiger ist.
    final bool useMulti;
    final _Plan chosen;
    if (fixed.isNotEmpty) {
      // Eigene Wahl: Artikel auf genau diese Märkte verteilen, leere Stopps entfallen.
      final full = _evaluate(fixed, resolved, userLocation, preferences);
      final used = fixed.where((s) => full.allocations[s.id]!.isNotEmpty).toList();
      chosen = used.isEmpty || used.length == fixed.length
          ? full
          : _evaluate(used, resolved, userLocation, preferences);
      useMulti = chosen.stores.length > 1;
    } else {
      useMulti = bestMulti != null &&
          (bestMulti.coveredCount > bestSingle.coveredCount ||
              (bestMulti.coveredCount == bestSingle.coveredCount &&
                  bestSingle.totalCostCents - bestMulti.totalCostCents > minMultiStopBenefitCents));
      chosen = useMulti ? bestMulti : bestSingle;
    }
    final comparable = chosen.coveredCount == bestSingle.coveredCount;

    final stops = <RouteStop>[];
    for (int i = 0; i < chosen.stores.length; i++) {
      final store = chosen.stores[i];
      final storeItems = chosen.allocations[store.id] ?? const <AllocatedItem>[];
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
        stopSubtotalCents: storeItems.fold<int>(0, (acc, it) => acc + it.totalPriceCents),
        items: storeItems,
      ));
    }

    final differs = !identical(chosen, bestSingle);
    final grossSavings = differs && comparable ? bestSingle.basketCents - chosen.basketCents : 0;
    final extraTravel = differs && comparable ? chosen.travelCents - bestSingle.travelCents : 0;

    return OptimizationResult(
      recommendationMode: useMulti ? 'MULTI_STORE' : 'SINGLE_STORE',
      summary: OptimizationSummary(
        totalBasketPriceCents: chosen.basketCents,
        grossSavingsCents: grossSavings,
        travelPenaltyCents: extraTravel,
        netSavingsCents: grossSavings - extraTravel,
        totalRouteDistanceMeters: chosen.distanceMeters.round(),
        totalStops: stops.length,
        totalTravelCents: chosen.travelCents,
      ),
      stops: stops,
      baselineSingleStore: {
        'store_id': bestSingle.stores.first.id,
        'name': bestSingle.stores.first.name,
        'chain': bestSingle.stores.first.chain.name,
        'total_basket_price_cents': bestSingle.basketCents,
        'travel_cost_cents': bestSingle.travelCents,
        'missing_items_count': resolved.length - bestSingle.coveredCount,
      },
      unpricedItems: chosen.missing,
    );
  }

  /// Mehr abgedeckte Artikel gewinnen, danach die geringeren Gesamtkosten.
  static _Plan _better(_Plan a, _Plan b) {
    if (a.coveredCount != b.coveredCount) return a.coveredCount > b.coveredCount ? a : b;
    return a.totalCostCents <= b.totalCostCents ? a : b;
  }

  static _Plan _evaluate(
    List<Store> route,
    List<_ResolvedItem> items,
    UserLocation user,
    UserPreferences prefs,
  ) {
    final allocations = {for (final s in route) s.id: <AllocatedItem>[]};
    final missing = <String>[];
    int basket = 0;
    int covered = 0;

    for (final it in items) {
      Store? bestStore;
      int? bestScore;
      int? bestPrice;
      for (final s in route) {
        final p = it.pricesByStore[s.id];
        if (p == null) continue;
        var score = p;
        final pref = prefs.categoryStorePreferences[it.category];
        if (route.length > 1 && pref != null && s.chain.name.contains(pref.toLowerCase())) {
          score -= categoryPreferenceBonusCents;
        }
        if (bestScore == null || score < bestScore) {
          bestScore = score;
          bestStore = s;
          bestPrice = p;
        }
      }
      if (bestStore == null || bestPrice == null) {
        missing.add(it.product?.name ?? it.rawText);
        continue;
      }
      final total = (bestPrice * it.quantity).round();
      allocations[bestStore.id]!.add(AllocatedItem(
        listItemId: it.listItemId,
        productId: it.product?.id,
        itemName: it.product?.name ?? it.rawText,
        rawText: it.rawText,
        brand: it.product?.brand,
        quantity: it.quantity,
        unitPriceCents: bestPrice,
        totalPriceCents: total,
      ));
      basket += total;
      covered++;
    }

    // Route: Standort → Stopp 1 (→ Stopp 2) → Standort.
    double distance = haversineMeters(user.latitude, user.longitude, route.first.latitude, route.first.longitude) +
        haversineMeters(route.last.latitude, route.last.longitude, user.latitude, user.longitude);
    double paidDistance = distance;
    for (int k = 1; k < route.length; k++) {
      final leg = haversineMeters(route[k - 1].latitude, route[k - 1].longitude, route[k].latitude, route[k].longitude);
      distance += leg;
      if (leg > walkableMeters) paidDistance += leg;
    }
    final travel = (paidDistance / 1000.0 * prefs.costPerKmCents).round();

    return _Plan(
      stores: route,
      allocations: allocations,
      missing: missing,
      basketCents: basket,
      travelCents: travel,
      distanceMeters: distance,
      coveredCount: covered,
    );
  }
}

class _ResolvedItem {
  final String listItemId;
  final String rawText;
  final Product? product;
  final double quantity;
  final String category;
  final Map<String, int> pricesByStore;

  const _ResolvedItem({
    required this.listItemId,
    required this.rawText,
    required this.product,
    required this.quantity,
    required this.category,
    required this.pricesByStore,
  });
}

class _Plan {
  final List<Store> stores;
  final Map<String, List<AllocatedItem>> allocations;
  final List<String> missing;
  final int basketCents;
  final int travelCents;
  final double distanceMeters;
  final int coveredCount;

  const _Plan({
    required this.stores,
    required this.allocations,
    required this.missing,
    required this.basketCents,
    required this.travelCents,
    required this.distanceMeters,
    required this.coveredCount,
  });

  int get totalCostCents => basketCents + travelCents;
}
