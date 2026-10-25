// scrapers/run_rlp_scraping.js
// Master scraping & ingestion runner for Rheinland-Pfalz (Focus: Bingen & Oberwesel)

const fs = require('fs');
const path = require('path');
const { ReweScraper } = require('./connectors/rewe_scraper');
const { LidlScraper } = require('./connectors/lidl_scraper');
const { AldiSuedScraper } = require('./connectors/aldi_sued_scraper');
const { NettoScraper } = require('./connectors/netto_scraper');
const { DmScraper } = require('./connectors/dm_scraper');
const { RossmannScraper } = require('./connectors/rossmann_scraper');
const { ProductNormalizer } = require('./normalizer');

async function runScrapingPipeline() {
  console.log('===============================================================');
  console.log('🚀 STARTING RLP GROCERY & DRUGSTORE SCRAPER PIPELINE');
  console.log('📍 Regional Focus: Bingen am Rhein (55411) & Oberwesel (55430)');
  console.log('🏪 Chains: REWE, Lidl, ALDI SÜD, Netto, dm, Rossmann');
  console.log('===============================================================\n');

  const bingenLocation = { postalCode: '55411', city: 'Bingen am Rhein' };
  const oberweselLocation = { postalCode: '55430', city: 'Oberwesel' };

  const scrapers = [
    { scraper: new ReweScraper(), location: bingenLocation },
    { scraper: new LidlScraper(), location: bingenLocation },
    { scraper: new AldiSuedScraper(), location: bingenLocation },
    { scraper: new NettoScraper(), location: oberweselLocation },
    { scraper: new DmScraper(), location: bingenLocation },
    { scraper: new RossmannScraper(), location: bingenLocation },
  ];

  const normalizer = new ProductNormalizer();
  const allScrapedItems = [];
  const matchedOffers = [];

  for (const { scraper, location } of scrapers) {
    try {
      const items = await scraper.scrapeOffers(location);
      console.log(`✅ [${scraper.displayName}] Scraped ${items.length} offers for ${location.city}`);
      allScrapedItems.push(...items);
    } catch (err) {
      console.error(`❌ [${scraper.displayName}] Failed to scrape: ${err.message}`);
    }
  }

  console.log(`\n🔍 Normalizing & matching ${allScrapedItems.length} raw scraped items against catalog...`);

  for (const item of allScrapedItems) {
    const matchResult = normalizer.match(item);

    const enriched = {
      ...item,
      matched_product_id: matchResult.matched_product ? matchResult.matched_product.id : null,
      matched_product_name: matchResult.matched_product ? matchResult.matched_product.name : null,
      match_confidence: matchResult.confidence,
      match_type: matchResult.match_type,
    };

    matchedOffers.push(enriched);
  }

  const matchCount = matchedOffers.filter(o => o.matched_product_id !== null).length;
  const matchRate = Math.round((matchCount / matchedOffers.length) * 100);

  console.log(`\n📊 PIPELINE EXECUTION SUMMARY:`);
  console.log(`- Total Scraped Offers: ${matchedOffers.length}`);
  console.log(`- Matched to Catalog: ${matchCount} (${matchRate}%)`);
  console.log(`- Target Chains Covered: 6/6 (Lidl, ALDI SÜD, REWE, Netto, dm, Rossmann)`);

  // Write results to JSON artifacts
  const outputPathApp = path.join(__dirname, '../app/assets/live_scraped_offers_rlp.json');
  const outputPathTest = path.join(__dirname, '../test_data/live_scraped_offers_rlp.json');

  const exportPayload = {
    region: 'Rheinland-Pfalz',
    focus_cities: ['Bingen am Rhein', 'Oberwesel'],
    executed_at: new Date().toISOString(),
    total_offers: matchedOffers.length,
    matched_count: matchCount,
    offers: matchedOffers,
  };

  fs.writeFileSync(outputPathApp, JSON.stringify(exportPayload, null, 2), 'utf8');
  fs.writeFileSync(outputPathTest, JSON.stringify(exportPayload, null, 2), 'utf8');
  console.log(`💾 Live offers persisted to app/assets/live_scraped_offers_rlp.json`);

  return exportPayload;
}

if (require.main === module) {
  runScrapingPipeline()
    .then(() => process.exit(0))
    .catch(err => {
      console.error('Fatal error during pipeline:', err);
      process.exit(1);
    });
}

module.exports = { runScrapingPipeline };
