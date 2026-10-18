// supabase/functions/optimize-route/index.ts
// Grocery Shopping Optimizer Engine:
// Multi-Store Basket Allocation & Route Optimization with < 500m Clustering

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ListItemInput {
  id?: string;
  raw_text: string;
  matched_product_id?: string;
  quantity?: number;
}

interface OptimizationPayload {
  user_location: { latitude: number; longitude: number };
  items: ListItemInput[];
  preferences?: {
    transport_mode?: "car" | "bike" | "walk";
    cost_per_km_cents?: number;
    minute_value_cents?: number;
    max_stops?: number;
    search_radius_meters?: number;
  };
}

function haversineDistanceMeters(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000;
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Group stores with < 500m distance into spatial clusters
function clusterStores(stores: any[], thresholdMeters = 500) {
  const n = stores.length;
  const parent = Array.from({ length: n }, (_, i) => i);

  function find(i: number): number {
    if (parent[i] === i) return i;
    parent[i] = find(parent[i]);
    return parent[i];
  }

  function union(i: number, j: number) {
    const rootI = find(i);
    const rootJ = find(j);
    if (rootI !== rootJ) parent[rootI] = rootJ;
  }

  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const dist = haversineDistanceMeters(
        stores[i].latitude,
        stores[i].longitude,
        stores[j].latitude,
        stores[j].longitude
      );
      if (dist <= thresholdMeters) {
        union(i, j);
      }
    }
  }

  const clusterMap = new Map<number, number>();
  let clusterCounter = 1;

  return stores.map((s, idx) => {
    const root = find(idx);
    if (!clusterMap.has(root)) {
      clusterMap.set(root, clusterCounter++);
    }
    return {
      ...s,
      cluster_id: clusterMap.get(root)!,
    };
  });
}

// Generate combinations of size k from an array
function combinations<T>(arr: T[], k: number): T[][] {
  if (k === 0) return [[]];
  if (arr.length === 0) return [];
  const head = arr[0];
  const tail = arr.slice(1);
  const withHead = combinations(tail, k - 1).map((c) => [head, ...c]);
  const withoutHead = combinations(tail, k);
  return [...withHead, ...withoutHead];
}

// Permutations for TSP route sequencing
function permutations<T>(arr: T[]): T[][] {
  if (arr.length <= 1) return [arr];
  const result: T[][] = [];
  for (let i = 0; i < arr.length; i++) {
    const current = arr[i];
    const remaining = [...arr.slice(0, i), ...arr.slice(i + 1)];
    for (const p of permutations(remaining)) {
      result.push([current, ...p]);
    }
  }
  return result;
}

// Estimate route travel distance in meters (user -> store1 -> store2 -> ... -> user)
function computeRouteMetrics(
  userLoc: { latitude: number; longitude: number },
  stores: any[],
  intraClusterThresholdMeters = 500
): { distanceMeters: number; orderedStores: any[] } {
  if (stores.length === 0) return { distanceMeters: 0, orderedStores: [] };

  const allPerms = permutations(stores);
  let minDistance = Infinity;
  let bestOrder: any[] = stores;

  for (const perm of allPerms) {
    let dist = 0;
    // From user to first store
    dist += haversineDistanceMeters(
      userLoc.latitude,
      userLoc.longitude,
      perm[0].latitude,
      perm[0].longitude
    );

    // Between consecutive stores
    for (let i = 0; i < perm.length - 1; i++) {
      const stepDist = haversineDistanceMeters(
        perm[i].latitude,
        perm[i].longitude,
        perm[i + 1].latitude,
        perm[i + 1].longitude
      );
      // Intra-cluster discount: stores < 500m away incur virtually 0 extra car driving effort
      if (stepDist <= intraClusterThresholdMeters) {
        dist += stepDist * 0.2; // 80% discount for clustered stops
      } else {
        dist += stepDist;
      }
    }

    // From last store back to user
    dist += haversineDistanceMeters(
      perm[perm.length - 1].latitude,
      perm[perm.length - 1].longitude,
      userLoc.latitude,
      userLoc.longitude
    );

    if (dist < minDistance) {
      minDistance = dist;
      bestOrder = perm;
    }
  }

  return { distanceMeters: Math.round(minDistance), orderedStores: bestOrder };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const payload: OptimizationPayload = await req.json();
    const { user_location, items = [], preferences = {} } = payload;

    if (!user_location?.latitude || !user_location?.longitude) {
      return new Response(
        JSON.stringify({ error: "Missing user_location coordinates" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (items.length === 0) {
      return new Response(
        JSON.stringify({ error: "Shopping list is empty" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const costPerKmCents = preferences.cost_per_km_cents ?? 30; // 0.30 EUR / km
    const minuteValueCents = preferences.minute_value_cents ?? 15;
    const maxStops = Math.min(preferences.max_stops ?? 2, 4);
    const searchRadius = preferences.search_radius_meters ?? 5000;

    // 1. Fetch nearby stores
    let candidateStores: any[] = [];
    const { data: dbStores } = await supabaseClient.rpc(
      "get_nearby_store_clusters",
      {
        p_lat: user_location.latitude,
        p_lng: user_location.longitude,
        p_radius_meters: searchRadius,
      }
    );

    if (dbStores && dbStores.length > 0) {
      candidateStores = dbStores;
    } else {
      // Fallback query directly from stores table
      const { data: directStores } = await supabaseClient
        .from("stores")
        .select("id, chain, name, address, location");
      if (directStores) {
        candidateStores = directStores.map((s: any) => {
          // Parse coordinates
          return {
            id: s.id,
            chain: s.chain,
            name: s.name,
            address: s.address,
            latitude: 50.9335, // default fallback
            longitude: 6.9942,
          };
        });
      }
    }

    if (candidateStores.length === 0) {
      return new Response(
        JSON.stringify({
          error: "Keine Supermärkte von Lidl, Aldi oder Rewe im gewählten Umkreis gefunden.",
        }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Cluster stores (< 500m)
    const clusteredStores = clusterStores(candidateStores, 500);

    // 2. Fetch products and prices
    const { data: allProducts } = await supabaseClient
      .from("products")
      .select("id, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label");

    const { data: allAliases } = await supabaseClient
      .from("product_aliases")
      .select("product_id, alias, priority");

    const { data: allPrices } = await supabaseClient
      .from("prices")
      .select("product_id, chain, store_id, price_cents");

    // Match list items to catalog products using exact and longest-alias priority
    const resolvedItems = items.map((item) => {
      let matchedProd = null;
      if (item.matched_product_id && allProducts) {
        matchedProd = allProducts.find((p: any) => p.id === item.matched_product_id);
      }

      if (!matchedProd && allProducts) {
        const query = item.raw_text.toLowerCase().trim();

        // 1. Exact alias match
        if (allAliases) {
          const exactAlias = allAliases.find((a: any) => a.alias.toLowerCase() === query);
          if (exactAlias) {
            matchedProd = allProducts.find((p: any) => p.id === exactAlias.product_id);
          }
        }

        // 2. Exact product name match
        if (!matchedProd) {
          matchedProd = allProducts.find((p: any) => p.name.toLowerCase() === query);
        }

        // 3. Longest alias match (prevents partial substring conflicts)
        if (!matchedProd && allAliases) {
          let maxAliasLen = 0;
          for (const a of allAliases) {
            const aliasStr = a.alias.toLowerCase();
            if (query.includes(aliasStr) && aliasStr.length > maxAliasLen) {
              maxAliasLen = aliasStr.length;
              matchedProd = allProducts.find((p: any) => p.id === a.product_id);
            }
          }
        }

        // 4. Substring in product name
        if (!matchedProd) {
          matchedProd = allProducts.find((p: any) =>
            p.name.toLowerCase().includes(query) || query.includes(p.name.toLowerCase())
          );
        }
      }

      const quantity = item.quantity && item.quantity > 0 ? item.quantity : 1;
      return {
        raw_text: item.raw_text,
        matched_product: matchedProd,
        quantity,
      };
    });

    // Helper: get price of a product for a specific store/chain
    function getProductPriceCents(productId: string, store: any): number | null {
      if (!allPrices) return null;
      // 1. Store specific price
      const storePrice = allPrices.find(
        (p: any) => p.product_id === productId && p.store_id === store.id
      );
      if (storePrice) return storePrice.price_cents;

      // 2. Chain default price
      const chainPrice = allPrices.find(
        (p: any) => p.product_id === productId && p.chain === store.chain
      );
      if (chainPrice) return chainPrice.price_cents;

      return null;
    }

    // 3. Compute Baseline: Single Store Solutions
    interface SingleStoreEvaluation {
      store: any;
      totalBasketCents: number;
      missingItemsCount: number;
      routeDistanceMeters: number;
      travelCostCents: number;
      totalExpenseCents: number;
    }

    const singleStoreEvaluations: SingleStoreEvaluation[] = [];

    for (const store of clusteredStores) {
      let basketSum = 0;
      let missingCount = 0;

      for (const item of resolvedItems) {
        if (!item.matched_product) {
          // Default estimated price for unknown items: 1.99 EUR
          basketSum += 199 * item.quantity;
          continue;
        }

        const price = getProductPriceCents(item.matched_product.id, store);
        if (price !== null) {
          basketSum += price * item.quantity;
        } else {
          missingCount++;
          basketSum += 250 * item.quantity; // Penalty estimate
        }
      }

      const route = computeRouteMetrics(user_location, [store]);
      const travelDistKm = route.distanceMeters / 1000;
      const travelCostCents = Math.round(travelDistKm * costPerKmCents);

      singleStoreEvaluations.push({
        store,
        totalBasketCents: basketSum,
        missingItemsCount: missingCount,
        routeDistanceMeters: route.distanceMeters,
        travelCostCents,
        totalExpenseCents: basketSum + travelCostCents,
      });
    }

    // Sort single stores by total expense
    singleStoreEvaluations.sort((a, b) => a.totalExpenseCents - b.totalExpenseCents);
    const bestSingleStore = singleStoreEvaluations[0];

    // 4. Multi-Store Combinatorial Optimization
    interface MultiStoreCandidate {
      stores: any[];
      orderedStores: any[];
      routeDistanceMeters: number;
      totalBasketCents: number;
      grossSavingsCents: number;
      travelCostPenaltyCents: number;
      netSavingsCents: number;
      assignedItemsByStore: Record<string, any[]>;
    }

    let bestMultiRoute: MultiStoreCandidate | null = null;

    // Explore combinations of sizes from 2 up to maxStops
    for (let k = 2; k <= Math.min(maxStops, clusteredStores.length); k++) {
      const storeCombos = combinations(clusteredStores, k);

      for (const combo of storeCombos) {
        // Must contain at least 2 distinct chains or benefit from cluster
        let basketSum = 0;
        const assignment: Record<string, any[]> = {};
        combo.forEach((s) => (assignment[s.id] = []));

        let isValid = true;

        for (const item of resolvedItems) {
          if (!item.matched_product) {
            // Put in first store by default
            assignment[combo[0].id].push({
              item_name: item.raw_text,
              quantity: item.quantity,
              unit_price_cents: 199,
              total_price_cents: 199 * item.quantity,
            });
            basketSum += 199 * item.quantity;
            continue;
          }

          // Find cheapest price among stores in this combination
          let cheapestPrice = Infinity;
          let cheapestStore = combo[0];

          for (const s of combo) {
            const pr = getProductPriceCents(item.matched_product.id, s);
            if (pr !== null && pr < cheapestPrice) {
              cheapestPrice = pr;
              cheapestStore = s;
            }
          }

          if (cheapestPrice === Infinity) {
            cheapestPrice = 250;
            cheapestStore = combo[0];
          }

          assignment[cheapestStore.id].push({
            item_name: item.matched_product.name,
            raw_text: item.raw_text,
            brand: item.matched_product.brand,
            quantity: item.quantity,
            unit_price_cents: cheapestPrice,
            total_price_cents: cheapestPrice * item.quantity,
          });

          basketSum += cheapestPrice * item.quantity;
        }

        // Drop combo if any store received 0 items
        const activeStores = combo.filter((s) => assignment[s.id].length > 0);
        if (activeStores.length < 2) continue;

        // Calculate route metrics
        const routeMetrics = computeRouteMetrics(user_location, activeStores);
        const detourDistanceMeters = Math.max(
          0,
          routeMetrics.distanceMeters - bestSingleStore.routeDistanceMeters
        );
        const travelCostPenalty = Math.round((detourDistanceMeters / 1000) * costPerKmCents);

        const grossSavings = bestSingleStore.totalBasketCents - basketSum;
        const netSavings = grossSavings - travelCostPenalty;

        if (
          !bestMultiRoute ||
          netSavings > bestMultiRoute.netSavingsCents
        ) {
          bestMultiRoute = {
            stores: activeStores,
            orderedStores: routeMetrics.orderedStores,
            routeDistanceMeters: routeMetrics.distanceMeters,
            totalBasketCents: basketSum,
            grossSavingsCents: grossSavings,
            travelCostPenaltyCents: travelCostPenalty,
            netSavingsCents: netSavings,
            assignedItemsByStore: assignment,
          };
        }
      }
    }

    // Recommendation logic
    const isMultiStoreRecommended =
      bestMultiRoute !== null && bestMultiRoute.netSavingsCents > 50; // At least 0.50 EUR net savings

    const formattedStops = (isMultiStoreRecommended && bestMultiRoute
      ? bestMultiRoute.orderedStores
      : [bestSingleStore.store]
    ).map((store, index) => {
      const itemsForStore =
        isMultiStoreRecommended && bestMultiRoute
          ? bestMultiRoute.assignedItemsByStore[store.id] || []
          : resolvedItems.map((it) => {
              const price = it.matched_product
                ? getProductPriceCents(it.matched_product.id, store) ?? 199
                : 199;
              return {
                item_name: it.matched_product?.name || it.raw_text,
                raw_text: it.raw_text,
                brand: it.matched_product?.brand,
                quantity: it.quantity,
                unit_price_cents: price,
                total_price_cents: price * it.quantity,
              };
            });

      const stopSubtotalCents = itemsForStore.reduce(
        (acc: number, cur: any) => acc + cur.total_price_cents,
        0
      );

      return {
        stop_index: index + 1,
        store_id: store.id,
        chain: store.chain,
        name: store.name,
        address: store.address,
        latitude: store.latitude,
        longitude: store.longitude,
        cluster_id: store.cluster_id,
        items_count: itemsForStore.length,
        items: itemsForStore,
        stop_subtotal_cents: stopSubtotalCents,
      };
    });

    const response = {
      success: true,
      user_location,
      recommendation_mode: isMultiStoreRecommended ? "MULTI_STORE" : "SINGLE_STORE",
      summary: {
        total_basket_price_cents: isMultiStoreRecommended && bestMultiRoute
          ? bestMultiRoute.totalBasketCents
          : bestSingleStore.totalBasketCents,
        gross_savings_cents: isMultiStoreRecommended && bestMultiRoute
          ? bestMultiRoute.grossSavingsCents
          : 0,
        travel_penalty_cents: isMultiStoreRecommended && bestMultiRoute
          ? bestMultiRoute.travelCostPenaltyCents
          : 0,
        net_savings_cents: isMultiStoreRecommended && bestMultiRoute
          ? bestMultiRoute.netSavingsCents
          : 0,
        total_route_distance_meters: isMultiStoreRecommended && bestMultiRoute
          ? bestMultiRoute.routeDistanceMeters
          : bestSingleStore.routeDistanceMeters,
        total_stops: formattedStops.length,
      },
      baseline_single_store: {
        name: bestSingleStore.store.name,
        chain: bestSingleStore.store.chain,
        total_basket_price_cents: bestSingleStore.totalBasketCents,
        travel_distance_meters: bestSingleStore.routeDistanceMeters,
      },
      route_stops: formattedStops,
    };

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
