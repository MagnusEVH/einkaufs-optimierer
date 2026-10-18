// backend_tests/test_optimization_engine.js
// Unit tests for grocery basket optimization, route tradeoff, and item allocation

const assert = require('assert');
const catalog = require('../test_data/products_seed_250.json');
const sampleStores = require('../test_data/sample_stores_germany.json');

function haversineDistanceMeters(lat1, lon1, lat2, lon2) {
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
  return Math.round(R * c);
}

// In-engine matcher with exact match and longest-alias priority
function matchItem(rawText, products) {
  const query = rawText.toLowerCase().trim();
  // 1. Exact alias match
  for (const p of products) {
    if (p.aliases && p.aliases.some(a => a.toLowerCase() === query)) {
      return p;
    }
  }
  // 2. Exact product name match
  for (const p of products) {
    if (p.name.toLowerCase() === query) {
      return p;
    }
  }
  // 3. Longest alias match (prevents "milch" from hijacking "milchreis")
  let bestProd = null;
  let maxAliasLen = 0;
  for (const p of products) {
    if (p.aliases) {
      for (const a of p.aliases) {
        if (query.includes(a.toLowerCase()) && a.length > maxAliasLen) {
          maxAliasLen = a.length;
          bestProd = p;
        }
      }
    }
  }
  if (bestProd) return bestProd;

  // 4. Substring in product name
  for (const p of products) {
    if (p.name.toLowerCase().includes(query) || query.includes(p.name.toLowerCase())) {
      return p;
    }
  }
  return null;
}

// In-engine optimizer simulation
function runOptimizer({ userLocation, items, stores, costPerKmCents = 30, maxStops = 2 }) {
  // 1. Resolve items
  const resolved = items.map(it => {
    const prod = matchItem(it.raw_text, catalog.products);
    return {
      raw_text: it.raw_text,
      matched: prod,
      quantity: it.quantity || 1,
    };
  });

  // 2. Single store evaluations
  const singleEvaluations = stores.map(store => {
    let basketCents = 0;
    resolved.forEach(it => {
      const p = it.matched ? (it.matched.prices[store.chain] || 199) : 199;
      basketCents += p * it.quantity;
    });

    const distMeters = haversineDistanceMeters(
      userLocation.latitude, userLocation.longitude,
      store.latitude, store.longitude
    ) * 2; // Roundtrip

    const travelCostCents = Math.round((distMeters / 1000) * costPerKmCents);

    return {
      store,
      basketCents,
      distMeters,
      travelCostCents,
      totalCostCents: basketCents + travelCostCents,
    };
  });

  singleEvaluations.sort((a, b) => a.totalCostCents - b.totalCostCents);
  const bestSingle = singleEvaluations[0];

  // 3. Multi-store 2-stop evaluations
  let bestMulti = null;

  for (let i = 0; i < stores.length; i++) {
    for (let j = i + 1; j < stores.length; j++) {
      const s1 = stores[i];
      const s2 = stores[j];

      let basketCents = 0;
      const s1Items = [];
      const s2Items = [];

      resolved.forEach(it => {
        const p1 = it.matched ? (it.matched.prices[s1.chain] || 199) : 199;
        const p2 = it.matched ? (it.matched.prices[s2.chain] || 199) : 199;

        if (p1 <= p2) {
          s1Items.push({ name: it.matched ? it.matched.name : it.raw_text, price: p1, qty: it.quantity });
          basketCents += p1 * it.quantity;
        } else {
          s2Items.push({ name: it.matched ? it.matched.name : it.raw_text, price: p2, qty: it.quantity });
          basketCents += p2 * it.quantity;
        }
      });

      // If either store got 0 items, no point in multi-store
      if (s1Items.length === 0 || s2Items.length === 0) continue;

      // Distance user -> s1 -> s2 -> user
      const intraDist = haversineDistanceMeters(s1.latitude, s1.longitude, s2.latitude, s2.longitude);
      let routeMeters = 0;
      routeMeters += haversineDistanceMeters(userLocation.latitude, userLocation.longitude, s1.latitude, s1.longitude);
      // Clustered discount if < 500m
      if (intraDist <= 500) {
        routeMeters += intraDist * 0.2; // Minor parking/walking effort
      } else {
        routeMeters += intraDist;
      }
      routeMeters += haversineDistanceMeters(s2.latitude, s2.longitude, userLocation.latitude, userLocation.longitude);

      const extraDistMeters = Math.max(0, routeMeters - bestSingle.distMeters);
      const travelPenaltyCents = Math.round((extraDistMeters / 1000) * costPerKmCents);
      const grossSavingsCents = bestSingle.basketCents - basketCents;
      const netSavingsCents = grossSavingsCents - travelPenaltyCents;

      if (!bestMulti || netSavingsCents > bestMulti.netSavingsCents) {
        bestMulti = {
          stores: [s1, s2],
          s1Items,
          s2Items,
          basketCents,
          grossSavingsCents,
          travelPenaltyCents,
          netSavingsCents,
          routeMeters,
          isClustered: intraDist <= 500,
        };
      }
    }
  }

  return {
    bestSingle,
    bestMulti,
    recommendedMode: (bestMulti && bestMulti.netSavingsCents > 50) ? 'MULTI_STORE' : 'SINGLE_STORE',
  };
}

console.log('=== TEST SUITE 2: OPTIMIZATION ENGINE & TRADEOFF LOGIC ===\n');

// SCENARIO 1: Clustered Stores in Deutz
// User is right in Deutz near Aldi Deutz & Lidl Deutz (<350m apart)
// List contains both discounter staples and items with distinct prices (e.g. Müller Milchreis, Ísey Skyr, Galbani Mozzarella)
const result1 = runOptimizer({
  userLocation: { latitude: 50.9280, longitude: 6.9790 },
  items: [
    { raw_text: 'Skyr', quantity: 2 },
    { raw_text: 'Vollmilch', quantity: 3 },
    { raw_text: 'Butter', quantity: 1 },
    { raw_text: 'Nutella', quantity: 1 },
    { raw_text: 'Klopapier', quantity: 1 },
    { raw_text: 'Spaghetti', quantity: 2 },
    { raw_text: 'Müller Milchreis', quantity: 4 }, // Lidl 0.69 vs Aldi 0.79 -> 40c saving
    { raw_text: 'Galbani Mozzarella', quantity: 3 }, // Lidl 1.59 vs Aldi 1.69 -> 30c saving
    { raw_text: 'Wasa Knäckebrot', quantity: 2 }, // Lidl 1.79 vs Aldi 1.89 -> 20c saving
    { raw_text: 'Bio Bananen', quantity: 1 },
  ],
  stores: sampleStores,
  costPerKmCents: 30,
});

console.log('Scenario 1 (Deutz Cluster with Price Divergence):');
console.log(`  Best Single Store: ${result1.bestSingle.store.name} (${(result1.bestSingle.basketCents / 100).toFixed(2)} €)`);
if (result1.bestMulti) {
  console.log(`  Multi-Store Combination: ${result1.bestMulti.stores.map(s => s.name).join(' + ')}`);
  console.log(`  Multi-Store Basket: ${(result1.bestMulti.basketCents / 100).toFixed(2)} €`);
  console.log(`  Gross Savings: ${(result1.bestMulti.grossSavingsCents / 100).toFixed(2)} €`);
  console.log(`  Travel Penalty: ${(result1.bestMulti.travelPenaltyCents / 100).toFixed(2)} €`);
  console.log(`  Net Savings: ${(result1.bestMulti.netSavingsCents / 100).toFixed(2)} €`);
  console.log(`  Clustered stores (<500m): ${result1.bestMulti.isClustered}`);
}
console.log(`  Recommendation: ${result1.recommendedMode}`);

assert(result1.bestSingle.basketCents > 0, 'Single store basket must be greater than 0');
assert(result1.bestMulti !== null, 'Multi-store route should be discovered when price variance exists');
assert(result1.bestMulti.basketCents <= result1.bestSingle.basketCents, 'Multi-store basket must be <= single store basket');

// SCENARIO 2: Detour Penalty Test
// If an item only has a 5-cent saving, but second store is 8 km away, net saving will be negative!
const isolatedStoreTest = [
  sampleStores[0], // Lidl Kalk
  sampleStores[4], // Rewe Mülheim (3.8 km away)
];

const result2 = runOptimizer({
  userLocation: { latitude: 50.9335, longitude: 6.9942 }, // At Lidl Kalk
  items: [
    { raw_text: 'Salz', quantity: 1 }, // 6-cent difference at most
  ],
  stores: isolatedStoreTest,
  costPerKmCents: 50, // 0.50 EUR/km
});

console.log('\nScenario 2 (Detour Penalty Check):');
console.log(`  Net savings of detour: ${result2.bestMulti ? (result2.bestMulti.netSavingsCents / 100).toFixed(2) + ' €' : 'N/A'}`);
console.log(`  Recommendation: ${result2.recommendedMode}`);

assert.strictEqual(
  result2.recommendedMode,
  'SINGLE_STORE',
  'When detour cost outweighs item savings, recommendation MUST be SINGLE_STORE'
);

// SCENARIO 3: Cluster Multi-Store with Positive Net Savings (Lidl Kalk + REWE Center Kalk < 220m)
const result3 = runOptimizer({
  userLocation: { latitude: 50.9340, longitude: 6.9950 }, // Kalk center between both stores
  items: [
    { raw_text: 'Somat Gold', quantity: 2 },            // Lidl 7.99 vs Rewe 8.49 -> 1.00 € saving at Lidl
    { raw_text: 'Kerrygold', quantity: 2 },              // Lidl 2.39 vs Rewe 2.79 -> 0.80 € saving at Lidl
    { raw_text: 'Skyr', quantity: 2 },                   // Lidl 1.19 vs Rewe 1.39 -> 0.40 € saving at Lidl
    { raw_text: 'Barilla Spaghetti', quantity: 3 },      // Rewe 1.49 vs Lidl 1.89 -> 1.20 € saving at Rewe
    { raw_text: 'Ritter Sport', quantity: 3 },           // Rewe 1.19 vs Lidl 1.49 -> 0.90 € saving at Rewe
    { raw_text: 'Ristorante', quantity: 2 },             // Rewe 2.49 vs Lidl 3.29 -> 1.60 € saving at Rewe
  ],
  stores: [sampleStores[0], sampleStores[1]], // Lidl Kalk & REWE Kalk (<220m apart)
  costPerKmCents: 30,
});

console.log('\nScenario 3 (Kalk Cluster Lidl + Rewe with Positive Net Savings):');
console.log(`  Best Single Store: ${result3.bestSingle.store.name} (${(result3.bestSingle.basketCents / 100).toFixed(2)} €)`);
if (result3.bestMulti) {
  console.log(`  Multi-Store Combination: ${result3.bestMulti.stores.map(s => s.name).join(' + ')}`);
  console.log(`  Multi-Store Basket: ${(result3.bestMulti.basketCents / 100).toFixed(2)} €`);
  console.log(`  Gross Savings: ${(result3.bestMulti.grossSavingsCents / 100).toFixed(2)} €`);
  console.log(`  Travel Penalty: ${(result3.bestMulti.travelPenaltyCents / 100).toFixed(2)} €`);
  console.log(`  Net Savings: ${(result3.bestMulti.netSavingsCents / 100).toFixed(2)} €`);
  console.log(`  Clustered stores (<500m): ${result3.bestMulti.isClustered}`);
}
console.log(`  Recommendation: ${result3.recommendedMode}`);

assert(result3.bestMulti !== null, 'Multi-store combination must exist');
assert.strictEqual(result3.recommendedMode, 'MULTI_STORE', 'Cluster optimization with real savings MUST recommend MULTI_STORE');
assert(result3.bestMulti.netSavingsCents > 100, 'Net savings in Kalk cluster should exceed 1.00 €');

console.log('\n✅ All Optimization & Tradeoff Engine Tests Passed Successfully!\n');
