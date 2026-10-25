// scrapers/normalizer.js
// Matches scraped items to the master 270-item product catalog

const fs = require('fs');
const path = require('path');

class ProductNormalizer {
  constructor(catalogPath) {
    const resolvedPath = catalogPath || path.join(__dirname, '../test_data/products_seed_250.json');
    const rawData = JSON.parse(fs.readFileSync(resolvedPath, 'utf8'));
    this.products = rawData.products || [];
    console.log(`[Normalizer] Loaded ${this.products.length} master products for catalog matching.`);
  }

  /**
   * Tokenize and normalize German text (lowercase, remove punctuation, umlauts)
   */
  tokenize(text) {
    if (!text) return [];
    return text
      .toLowerCase()
      .replace(/ä/g, 'ae')
      .replace(/ö/g, 'oe')
      .replace(/ü/g, 'ue')
      .replace(/ß/g, 'ss')
      .replace(/[^a-z0-9]/g, ' ')
      .split(/\s+/)
      .filter(t => t.length > 1);
  }

  /**
   * Calculate Jaccard token overlap similarity between 0.0 and 1.0
   */
  similarity(tokens1, tokens2) {
    if (tokens1.length === 0 || tokens2.length === 0) return 0.0;
    const s1 = new Set(tokens1);
    const s2 = new Set(tokens2);
    let intersection = 0;
    for (const t of s1) {
      if (s2.has(t)) intersection++;
    }
    const union = new Set([...s1, ...s2]).size;
    return union > 0 ? intersection / union : 0.0;
  }

  /**
   * Match a scraped item against catalog products
   * @param {Object} scrapedItem - { raw_title, brand, chain, price_cents, ... }
   * @returns {Object} { matched_product, confidence, match_type }
   */
  match(scrapedItem) {
    const rawTitle = scrapedItem.raw_title.toLowerCase();
    const rawTokens = this.tokenize(rawTitle);

    // 1. Direct Alias match (Highest priority, confidence 1.0)
    for (const prod of this.products) {
      for (const alias of prod.aliases || []) {
        const aliasLower = alias.toLowerCase();
        if (rawTitle.includes(aliasLower) || aliasLower.includes(rawTitle)) {
          return {
            matched_product: prod,
            confidence: 0.95,
            match_type: 'alias_exact',
          };
        }
      }
    }

    // 2. Name contains or Jaccard similarity
    let bestMatch = null;
    let highestSim = 0.0;

    for (const prod of this.products) {
      const prodTokens = this.tokenize(prod.name);
      const sim = this.similarity(rawTokens, prodTokens);

      if (sim > highestSim && sim >= 0.3) {
        highestSim = sim;
        bestMatch = prod;
      }
    }

    if (bestMatch && highestSim >= 0.3) {
      return {
        matched_product: bestMatch,
        confidence: Math.min(0.9, Math.round(highestSim * 100) / 100),
        match_type: 'token_similarity',
      };
    }

    return {
      matched_product: null,
      confidence: 0.0,
      match_type: 'unmatched',
    };
  }
}

module.exports = { ProductNormalizer };
