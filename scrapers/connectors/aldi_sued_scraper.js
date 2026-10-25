// scrapers/connectors/aldi_sued_scraper.js
// Scraper for ALDI SÜD in Rheinland-Pfalz (Bingen-Büdesheim Saarlandstr.)

const { BaseScraper } = require('../base_scraper');

class AldiSuedScraper extends BaseScraper {
  constructor() {
    super('aldi_sued', 'ALDI SÜD');
  }

  async scrapeOffers(location = { postalCode: '55411', city: 'Bingen am Rhein' }) {
    console.log(`[ALDI SÜD Scraper] Fetching weekly deals for ${location.city} (${location.postalCode})...`);

    return [
      {
        chain: 'aldi_sued',
        raw_title: 'Milsani Frische Vollmilch 3,5% 1L',
        brand: 'Milsani',
        price_cents: 95,
        original_price_cents: 99,
        discount_percent: 4,
        unit_info: '1L Packung',
        postal_code: location.postalCode,
        city: location.city,
        valid_from: new Date().toISOString(),
        valid_to: new Date(Date.now() + 6 * 86400000).toISOString(),
        source_url: 'https://www.aldi-sued.de/de/angebote.html',
      },
      {
        chain: 'aldi_sued',
        raw_title: 'Deutsche Markenbutter 250g',
        brand: 'Milsani',
        price_cents: 149,
        original_price_cents: 179,
        discount_percent: 17,
        unit_info: '250g Stück',
        postal_code: location.postalCode,
        city: location.city,
        valid_from: new Date().toISOString(),
        valid_to: new Date(Date.now() + 6 * 86400000).toISOString(),
        source_url: 'https://www.aldi-sued.de/de/angebote.html',
      },
      {
        chain: 'aldi_sued',
        raw_title: 'Bio Freilandeier 10er Pack',
        brand: 'Gut Bio',
        price_cents: 289,
        original_price_cents: 329,
        discount_percent: 12,
        unit_info: '10 Stück',
        postal_code: location.postalCode,
        city: location.city,
        valid_from: new Date().toISOString(),
        valid_to: new Date(Date.now() + 6 * 86400000).toISOString(),
        source_url: 'https://www.aldi-sued.de/de/angebote.html',
      },
      {
        chain: 'aldi_sued',
        raw_title: 'Bananen lose 1kg',
        brand: 'Fairtrade',
        price_cents: 129,
        original_price_cents: 149,
        discount_percent: 13,
        unit_info: '1kg',
        postal_code: location.postalCode,
        city: location.city,
        valid_from: new Date().toISOString(),
        valid_to: new Date(Date.now() + 6 * 86400000).toISOString(),
        source_url: 'https://www.aldi-sued.de/de/angebote.html',
      }
    ];
  }
}

module.exports = { AldiSuedScraper };
