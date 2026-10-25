// scrapers/base_scraper.js
// Standardized base class for grocery & drugstore scrapers

class BaseScraper {
  /**
   * @param {string} chain - Identifier ('rewe', 'lidl', 'aldi_sued', 'netto', 'dm', 'rossmann')
   * @param {string} displayName - Human-readable name
   */
  constructor(chain, displayName) {
    this.chain = chain;
    this.displayName = displayName;
    this.userAgents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15',
      'Mozilla/5.0 (Linux; Android 14; SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36'
    ];
  }

  getRandomUserAgent() {
    return this.userAgents[Math.floor(Math.random() * this.userAgents.length)];
  }

  /**
   * Helper to execute safe HTTP GET request with retry & timeout
   */
  async safeFetch(url, options = {}) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), options.timeout || 10000);

    const headers = {
      'User-Agent': this.getRandomUserAgent(),
      'Accept': 'application/json, text/html, */*',
      'Accept-Language': 'de-DE,de;q=0.9,en;q=0.8',
      ...options.headers,
    };

    try {
      const response = await fetch(url, {
        ...options,
        headers,
        signal: controller.signal,
      });
      clearTimeout(timeout);
      return response;
    } catch (err) {
      clearTimeout(timeout);
      throw err;
    }
  }

  /**
   * Parse German price string e.g. "1,49 €", "1.49", "€ 0,99" to integer cents (149, 99)
   */
  parsePriceCents(priceStr) {
    if (typeof priceStr === 'number') return Math.round(priceStr * 100);
    if (!priceStr) return 0;
    const clean = priceStr.toString().replace(/[^0-9,\.]/g, '').replace(',', '.');
    const parsed = parseFloat(clean);
    return isNaN(parsed) ? 0 : Math.round(parsed * 100);
  }

  /**
   * Abstract method to be overridden by each chain connector
   * @param {Object} location - { postalCode: '55411', city: 'Bingen am Rhein' }
   * @returns {Promise<Array<ScrapedOffer>>}
   */
  async scrapeOffers(location) {
    throw new Error(`scrapeOffers() not implemented for ${this.chain}`);
  }
}

module.exports = { BaseScraper };
