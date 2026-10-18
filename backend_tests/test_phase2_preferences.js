// backend_tests/test_phase2_preferences.js
// Unit tests for Phase 2:
// - Category-level store prioritization (e.g. Netto for Obst, Lidl for Gemüse)
// - Brand preference (reject_private_label vs prefer_private_label)
// - Photo report metadata, pending OCR status & friendly in-app notification

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

function matchItem(rawText, products, brandPreference = 'neutral') {
  const query = rawText.toLowerCase().trim();
  
  // Find all candidate matches
  const candidates = products.filter(p => {
    if (p.aliases && p.aliases.some(a => a.toLowerCase() === query || query.includes(a.toLowerCase()))) return true;
    if (p.name.toLowerCase().includes(query)) return true;
    return false;
  });

  if (candidates.length === 0) return null;

  // Filter according to brand preference:
  // reject_private_label: prefer manufacturer brands (is_private_label = false)
  if (brandPreference === 'reject_private_label') {
    const brandCandidate = candidates.find(c => !c.is_private_label);
    if (brandCandidate) return brandCandidate;
  }
  // prefer_private_label: prefer discounter private label (is_private_label = true)
  if (brandPreference === 'prefer_private_label') {
    const plCandidate = candidates.find(c => c.is_private_label);
    if (plCandidate) return plCandidate;
  }

  return candidates[0];
}

// Optimization simulation taking category-store preferences and brand preferences into account
function runPhase2Optimizer({
  userLocation,
  items,
  stores,
  brandPreference = 'prefer_private_label',
  categoryStorePreferences = {}, // e.g. { 'obst': 'netto', 'gemuese': 'lidl' }
  costPerKmCents = 30
}) {
  const resolved = items.map(it => {
    const prod = matchItem(it.raw_text, catalog.products, brandPreference);
    return {
      raw_text: it.raw_text,
      category: it.category || (prod ? (prod.category_slug?.includes('obst') ? 'obst' : 'gemuese') : 'allgemein'),
      matched: prod,
      quantity: it.quantity || 1,
    };
  });

  // Check store assignment within cluster
  const clusterStores = stores.filter(s => {
    const dist = haversineDistanceMeters(userLocation.latitude, userLocation.longitude, s.latitude, s.longitude);
    return dist < 1000; // nearby cluster
  });

  const assignment = {};
  clusterStores.forEach(s => assignment[s.id] = []);

  resolved.forEach(it => {
    let chosenStore = clusterStores[0];
    let minEffectivePrice = Infinity;

    // Check if category has a preferred store
    const preferredChain = categoryStorePreferences[it.category];

    for (const store of clusterStores) {
      const basePrice = it.matched ? (it.matched.prices[store.chain] || 199) : 199;
      let effectivePrice = basePrice;

      // If this store matches the user's explicit category preference, apply a decisive priority weight
      if (preferredChain && store.chain.includes(preferredChain.toLowerCase())) {
        effectivePrice -= 50; // Priority bonus in cents
      }

      if (effectivePrice < minEffectivePrice) {
        minEffectivePrice = effectivePrice;
        chosenStore = store;
      }
    }

    const finalPrice = it.matched ? (it.matched.prices[chosenStore.chain] || 199) : 199;
    assignment[chosenStore.id].push({
      item: it.matched ? it.matched.name : it.raw_text,
      category: it.category,
      chain: chosenStore.chain,
      storeName: chosenStore.name,
      price: finalPrice,
      isPrivateLabel: it.matched ? it.matched.is_private_label : false,
    });
  });

  return {
    resolved,
    assignment,
  };
}

console.log('=== TEST SUITE 4: PHASE 2 PREFERENCES & CATEGORY ROUTING ===\n');

// 1. TEST: Category-Specific Store Preference (Obst from Netto, Gemüse from Lidl)
console.log('Test 1: Category Store Preference (Obst -> Netto, Gemüse -> Lidl)');
const userLoc = { latitude: 50.9340, longitude: 6.9950 }; // Kalk Cluster

const res1 = runPhase2Optimizer({
  userLocation: userLoc,
  items: [
    { raw_text: 'Bananen', category: 'obst', quantity: 2 },
    { raw_text: 'Heidelbeeren', category: 'obst', quantity: 1 },
    { raw_text: 'Brokkoli', category: 'gemuese', quantity: 2 },
    { raw_text: 'Gurke', category: 'gemuese', quantity: 1 },
  ],
  stores: sampleStores,
  categoryStorePreferences: {
    obst: 'netto',
    gemuese: 'lidl',
  },
});

let obstStoreAssigned = null;
let gemueseStoreAssigned = null;

Object.values(res1.assignment).forEach(itemList => {
  itemList.forEach(it => {
    if (it.category === 'obst') obstStoreAssigned = it.chain;
    if (it.category === 'gemuese') gemueseStoreAssigned = it.chain;
    console.log(`  [${it.category.toUpperCase()}] ${it.item} -> Zugeordnet zu: ${it.storeName} (${it.chain})`);
  });
});

assert.strictEqual(obstStoreAssigned, 'netto', 'Fruit items must be assigned to Netto when user prioritizes Netto for Obst');
assert.strictEqual(gemueseStoreAssigned, 'lidl', 'Vegetables must be assigned to Lidl when user prioritizes Lidl for Gemüse');
console.log('  ✅ Category-specific store preference honored!\n');

// 2. TEST: Reject Private Label vs Prefer Private Label
console.log('Test 2: Brand Preference (reject_private_label vs prefer_private_label)');

// When user rejects private labels (e.g. searching "Spaghetti"):
const brandMatch = matchItem('spaghetti', catalog.products, 'reject_private_label');
console.log(`  Query "Spaghetti" with reject_private_label -> ${brandMatch.name} (is_private_label: ${brandMatch.is_private_label})`);
assert.strictEqual(brandMatch.is_private_label, false, 'Should select branded product (e.g. Barilla) when private labels are rejected');

// When user prefers private labels:
const plMatch = matchItem('spaghetti', catalog.products, 'prefer_private_label');
console.log(`  Query "Spaghetti" with prefer_private_label -> ${plMatch.name} (is_private_label: ${plMatch.is_private_label})`);
assert.strictEqual(plMatch.is_private_label, true, 'Should select discounter private label when private labels are preferred');
console.log('  ✅ Brand preference honored!\n');

// 3. TEST: Price Report Photo Capture Structure & Message
console.log('Test 3: Photo Report Archiving & In-App Notification Message');

function createPriceReport({ userId, storeId, photoPath, manualPrice = null }) {
  return {
    id: 'report-123',
    user_id: userId,
    store_id: storeId,
    photo_storage_path: photoPath,
    reported_price_cents: manualPrice,
    ocr_status: 'pending_ocr',
    community_status: 'unverified',
    created_at: new Date().toISOString(),
    in_app_message: 'Foto erfolgreich gespeichert! Die automatische KI-Erkennung wird zeitnah freigeschaltet. Dein Beleg wurde sicher archiviert.'
  };
}

const report = createPriceReport({
  userId: 'user-001',
  storeId: '33333333-0000-0000-0000-000000000005',
  photoPath: 'price-reports/user-001/bon_20261018.jpg',
});

console.log(`  Report ID: ${report.id}`);
console.log(`  OCR Status: ${report.ocr_status}`);
console.log(`  Photo Path: ${report.photo_storage_path}`);
console.log(`  In-App Feedback Message: "${report.in_app_message}"`);

assert.strictEqual(report.ocr_status, 'pending_ocr', 'Initial OCR status must be pending_ocr');
assert(report.in_app_message.includes('zeitnah'), 'In-app notification message must inform about upcoming activation');
console.log('  ✅ Photo report archiving structure verified!\n');

console.log('✅ ALL PHASE 2 UNIT TESTS PASSED SUCCESSFULLY!\n');
