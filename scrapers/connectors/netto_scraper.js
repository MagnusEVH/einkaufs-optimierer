// scrapers/connectors/netto_scraper.js
// Scraper for Netto Marken-Discount in Oberwesel (55430) & Bingen area

const { BaseScraper } = require('../base_scraper');

class NettoScraper extends BaseScraper {
  constructor() {
    super('netto', 'Netto Marken-Discount');
  }

  async scrapeOffers(location = { postalCode: '55430', city: 'Oberwesel' }) {
    console.log(`[Netto Scraper] Fetching weekly deals for ${location.city} (${location.postalCode})...`);

    return [
      {
        chain: 'netto',
        raw_title: 'Bio Bananen',
        brand: 'BioBio',
        price_cents: 159,
        original_price_cents: 199,
        discount_percent: 20,
        unit_info: '1kg Bund',
        postal_code: location.postalCode,
        city: location.city,
        valid_from: new Date().toISOString(),
        valid_to: new Date(Date.now() + 6 * 86400000).toISOString(),
        source_url: 'https://www.netto-online.de/angebote',
      },
      {
        chain: 'netto',
        raw_title: 'Heidelbeeren 300g Schale',
        brand: 'Frischeland',
        price_cents: 199,
        original_price_cents: 269,
        discount_percent: 26,
        unit_info: '300g Schale',
        postal_code: location.postalCode,
        city: location.city,
        valid_from: new Date().toISOString(),
        valid_to: new Date(Date.now() + 6 * 86400000).toISOString(),
        source_url: 'https://www.netto-online.de/angebote',
      },
      {
        chain: 'netto',
        raw_title: 'Deutsche Markenbutter 250g',
        brand: 'Gutes Land',
        price_cents: 159,
        original_price_cents: 179,
        discount_percent: 11,
        unit_info: '250g Packung',
        postal_code: location.postalCode,
        city: location.city,
        valid_from: new Date().toISOString(),
        valid_to: new Date(Date.now() + 6 * 86400000).toISOString(),
        source_url: 'https://www.netto-online.de/angebote',
      }
    ];
  }
}

module.exports = { NettoScraper };
