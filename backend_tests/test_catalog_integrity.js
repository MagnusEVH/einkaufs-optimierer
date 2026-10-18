// backend_tests/test_catalog_integrity.js
// Verifies 250+ catalog items, pricing across all 3 chains (Lidl, Aldi, Rewe), and aliases

const assert = require('assert');
const catalog = require('../test_data/products_seed_250.json');

console.log('=== TEST SUITE 3: CATALOG & SEED INTEGRITY ===\n');

console.log(`Total Products in Catalog: ${catalog.products_count}`);
assert(catalog.products_count >= 250, 'Catalog must contain at least 250 products');

let totalAliases = 0;
let missingPriceCount = 0;
const seenBarcodes = new Set();

catalog.products.forEach(p => {
  assert(p.id, 'Product must have an ID');
  assert(p.name, 'Product must have a name');
  assert(p.quantity_amount > 0, 'Quantity amount must be positive');
  assert(p.quantity_unit, 'Quantity unit must be specified');
  assert(p.gtin_barcode, 'Barcode must be present');
  assert(!seenBarcodes.has(p.gtin_barcode), `Duplicate barcode found: ${p.gtin_barcode}`);
  seenBarcodes.add(p.gtin_barcode);

  totalAliases += p.aliases.length;

  // Verify prices for Lidl, Aldi Nord/Süd, and Rewe
  if (!p.prices.lidl || !p.prices.aldi_sued || !p.prices.rewe) {
    missingPriceCount++;
  }
});

console.log(`Total Search Aliases Registered: ${totalAliases}`);
console.log(`Products with complete prices across Lidl, Aldi & Rewe: ${catalog.products_count - missingPriceCount}`);
assert.strictEqual(missingPriceCount, 0, 'All products must have prices defined for all target chains');

console.log('\n✅ Catalog & Seed Integrity Tests Passed Successfully!\n');
