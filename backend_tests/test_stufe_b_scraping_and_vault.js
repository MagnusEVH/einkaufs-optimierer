// backend_tests/test_stufe_b_scraping_and_vault.js
// Automated verification for Stufe B: RLP Scraping, Bingen/Oberwesel Clustering, 6 Chains & Vault

const assert = require('assert');
const fs = require('fs');
const path = require('path');
const { runScrapingPipeline } = require('../scrapers/run_rlp_scraping');
const { ThirdPartyVaultService } = require('../scrapers/vault_service');

function haversineMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c);
}

async function runStufeBTests() {
  console.log('=== TEST SUITE 6: STUFE B – RLP SCRAPING, BINGEN & OBERWESEL CLUSTERING & VAULT ===\n');

  // --- TEST 1: STORE CLUSTERING IN BINGEN & OBERWESEL ---
  console.log('Test 1: Store Clustering in Bingen am Rhein & Oberwesel');
  const storesData = JSON.parse(fs.readFileSync(path.join(__dirname, '../app/assets/sample_stores_germany.json'), 'utf8'));

  const aldiBingen = storesData.find(s => s.name.includes('ALDI SÜD Bingen'));
  const lidlBingen = storesData.find(s => s.name.includes('Lidl Filiale Bingen'));
  const dmBingen = storesData.find(s => s.name.includes('dm-drogerie markt Bingen'));
  const rossmannBingen = storesData.find(s => s.name.includes('Rossmann Drogeriemarkt Bingen'));
  const nettoOberwesel = storesData.find(s => s.name.includes('Netto Marken-Discount Oberwesel'));
  const reweOberwesel = storesData.find(s => s.name.includes('REWE City Oberwesel'));

  assert(aldiBingen && lidlBingen, 'Bingen Büdesheim discounters must be present');
  const distBuedesheim = haversineMeters(aldiBingen.latitude, aldiBingen.longitude, lidlBingen.latitude, lidlBingen.longitude);
  console.log(`  Distance ALDI SÜD Bingen <-> Lidl Bingen: ${distBuedesheim} m`);
  assert(distBuedesheim < 500, 'ALDI and Lidl in Büdesheim must be within 500m cluster');

  const distDrogerie = haversineMeters(dmBingen.latitude, dmBingen.longitude, rossmannBingen.latitude, rossmannBingen.longitude);
  console.log(`  Distance dm Bingen <-> Rossmann Bingen: ${distDrogerie} m`);
  assert(distDrogerie < 500, 'dm and Rossmann in Bingen must be within 500m cluster');

  const distOberwesel = haversineMeters(nettoOberwesel.latitude, nettoOberwesel.longitude, reweOberwesel.latitude, reweOberwesel.longitude);
  console.log(`  Distance Netto Oberwesel <-> REWE Oberwesel: ${distOberwesel} m`);
  assert(distOberwesel < 500, 'Netto and REWE in Oberwesel must be within 500m cluster');
  console.log('  ✅ Bingen & Oberwesel Store Clustering verified!\n');

  // --- TEST 2: SCRAPER PIPELINE EXECUTION ---
  console.log('Test 2: Scraper Pipeline Execution for 6 Chains');
  const pipelineResult = await runScrapingPipeline();

  assert(pipelineResult.total_offers > 0, 'Scraper must return offers');
  assert(pipelineResult.matched_count >= 15, 'At least 15 items should be matched to catalog');

  const chainsFound = new Set(pipelineResult.offers.map(o => o.chain));
  console.log(`  Chains extracted: ${Array.from(chainsFound).join(', ')}`);
  assert(chainsFound.has('rewe'), 'REWE offers must be present');
  assert(chainsFound.has('lidl'), 'Lidl offers must be present');
  assert(chainsFound.has('aldi_sued'), 'ALDI SÜD offers must be present');
  assert(chainsFound.has('netto'), 'Netto offers must be present');
  assert(chainsFound.has('dm'), 'dm offers must be present');
  assert(chainsFound.has('rossmann'), 'Rossmann offers must be present');
  console.log('  ✅ Scraper coverage across all 6 chains verified!\n');

  // --- TEST 3: CATALOG MATCHING INTEGRITY ---
  console.log('Test 3: Catalog Matching & Drogerie Ingestion');
  const alouetteOffer = pipelineResult.offers.find(o => o.raw_title.includes('Alouette Toilettenpapier'));
  assert(alouetteOffer, 'Alouette Toilettenpapier must be scraped');
  assert(alouetteOffer.matched_product_id !== null, 'Alouette must match Toilettenpapier catalog item');
  console.log(`  Matched: "${alouetteOffer.raw_title}" -> "${alouetteOffer.matched_product_name}" (Confidence: ${alouetteOffer.match_confidence})`);

  const dmHafermilch = pipelineResult.offers.find(o => o.raw_title.includes('dmBio Hafermilch'));
  assert(dmHafermilch, 'dmBio Hafermilch must be scraped');
  console.log(`  Matched: "${dmHafermilch.raw_title}" -> "${dmHafermilch.matched_product_name}" (Confidence: ${dmHafermilch.match_confidence})`);
  console.log('  ✅ Catalog normalization verified!\n');

  // --- TEST 4: THIRD-PARTY VAULT & LOYALTY SYNC ---
  console.log('Test 4: Third-Party Credential Vault & Coupon Sync');
  const vault = new ThirdPartyVaultService();

  // Link Rossmann account
  const rossAccount = await vault.linkAccount('user-001', 'rossmann', 'kunde.bingen@gmail.com', 'superSecretPass123!');
  assert.strictEqual(rossAccount.masked_identifier, 'k***@gmail.com', 'Email must be masked for DSGVO compliance');
  assert(!rossAccount.session_token.includes('superSecretPass123!'), 'Plaintext password must never appear in token');

  // Sync Rossmann data (verify 10% coupon)
  const rossSync = await vault.syncAccountData('user-001', 'rossmann');
  assert(rossSync.active_coupons.some(c => c.title.includes('10% Rabatt')), 'Rossmann 10% coupon must be available');
  console.log(`  Rossmann Coupon synced: ${rossSync.active_coupons[0].title}`);

  // Link and sync PAYBACK account
  const pbAccount = await vault.linkAccount('user-001', 'payback', '3083421299991234', 'pbPin123');
  assert.strictEqual(pbAccount.masked_identifier, '•••• 1234', 'Card number must be masked to last 4 digits');
  const pbSync = await vault.syncAccountData('user-001', 'payback');
  assert.strictEqual(pbSync.points_balance, 2040, 'PAYBACK points must be 2040');
  console.log(`  PAYBACK points synced: ${pbSync.points_balance} Punkte (~${(pbSync.points_value_cents / 100).toFixed(2)} €)`);
  console.log('  ✅ Third-party credential vault & loyalty sync verified!\n');

  console.log('🎉 ALL STUFE B TESTS PASSED SUCCESSFULLY!');
}

runStufeBTests().catch(err => {
  console.error('Test suite failed:', err);
  process.exit(1);
});
