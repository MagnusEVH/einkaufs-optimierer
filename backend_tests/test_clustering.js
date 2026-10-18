// backend_tests/test_clustering.js
// Unit tests for PostGIS-equivalent Haversine distance & 500m store clustering

const assert = require('assert');
const stores = require('../test_data/sample_stores_germany.json');

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

function clusterStores(storeList, thresholdMeters = 500) {
  const n = storeList.length;
  const parent = Array.from({ length: n }, (_, i) => i);

  function find(i) {
    if (parent[i] === i) return i;
    parent[i] = find(parent[i]);
    return parent[i];
  }

  function union(i, j) {
    const rootI = find(i);
    const rootJ = find(j);
    if (rootI !== rootJ) parent[rootI] = rootJ;
  }

  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const dist = haversineDistanceMeters(
        storeList[i].latitude,
        storeList[i].longitude,
        storeList[j].latitude,
        storeList[j].longitude
      );
      if (dist <= thresholdMeters) {
        union(i, j);
      }
    }
  }

  const clusterMap = new Map();
  let clusterCounter = 1;

  return storeList.map((s, idx) => {
    const root = find(idx);
    if (!clusterMap.has(root)) {
      clusterMap.set(root, clusterCounter++);
    }
    return {
      ...s,
      cluster_id: clusterMap.get(root),
    };
  });
}

console.log('=== TEST SUITE 1: STORE CLUSTERING (< 500m) ===\n');

// 1. Distance between Lidl Kalk and REWE Kalk
const distKalk = haversineDistanceMeters(
  stores[0].latitude, stores[0].longitude,
  stores[1].latitude, stores[1].longitude
);
console.log(`Distance Lidl Kalk <-> Rewe Kalk: ${distKalk} m`);
assert(distKalk < 500, 'Lidl and Rewe in Kalk should be within 500m');

// 2. Distance between Aldi Deutz and Lidl Deutz
const distDeutz = haversineDistanceMeters(
  stores[2].latitude, stores[2].longitude,
  stores[3].latitude, stores[3].longitude
);
console.log(`Distance Aldi Deutz <-> Lidl Deutz: ${distDeutz} m`);
assert(distDeutz < 500, 'Aldi and Lidl in Deutz should be within 500m');

// 3. Distance between Kalk and Deutz
const distKalkDeutz = haversineDistanceMeters(
  stores[0].latitude, stores[0].longitude,
  stores[2].latitude, stores[2].longitude
);
console.log(`Distance Kalk <-> Deutz: ${distKalkDeutz} m`);
assert(distKalkDeutz > 1000, 'Kalk and Deutz should NOT be in the same cluster');

// 4. Run clustering
const clustered = clusterStores(stores, 500);
console.log('\nClustering results:');
clustered.forEach(s => {
  console.log(`  [Cluster ${s.cluster_id}] ${s.name} (${s.chain})`);
});

// Assert cluster grouping
assert.strictEqual(clustered[0].cluster_id, clustered[1].cluster_id, 'Lidl Kalk and Rewe Kalk must share cluster_id');
assert.strictEqual(clustered[2].cluster_id, clustered[3].cluster_id, 'Aldi Deutz and Lidl Deutz must share cluster_id');
assert.notStrictEqual(clustered[0].cluster_id, clustered[2].cluster_id, 'Kalk and Deutz must have different clusters');
assert.notStrictEqual(clustered[4].cluster_id, clustered[0].cluster_id, 'Isolated Mülheim store must be distinct cluster');

console.log('\n✅ All Clustering Tests Passed Successfully!\n');
