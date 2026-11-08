// scrapers/price_quality_monitor.js
// Automated Price History Tracking, 6-Hour Cache Sync, and Anomaly Detection

class PriceQualityMonitor {
  constructor() {
    this.priceHistory = [];
    this.anomalies = [];
    this.lastCacheSync = new Date();
  }

  /**
   * Evaluates incoming scraped prices against historical baseline
   * Detects unrealistic swings (>50% divergence) and stores price history points
   * @param {Array} scrapedBatch - [{ product_id, chain, price_cents, source, title }]
   */
  processPriceUpdate(scrapedBatch) {
    const now = new Date();
    const evaluated = [];

    for (const item of scrapedBatch) {
      const entry = {
        product_id: item.product_id,
        chain: item.chain,
        price_cents: item.price_cents,
        source: item.source || 'scraper_api',
        recorded_at: now.toISOString(),
      };

      // 1. Check for pricing anomalies (e.g. price 0 or extreme jump)
      if (item.price_cents <= 0) {
        this.logAnomaly('zero_price', item, 'Produktpreis darf nicht 0 oder negativ sein.');
        continue;
      }

      if (item.baseline_cents && item.baseline_cents > 0) {
        const changePercent = Math.abs((item.price_cents - item.baseline_cents) / item.baseline_cents) * 100;
        if (changePercent > 50) {
          this.logAnomaly(
            'extreme_price_jump',
            item,
            `Unplausibler Preissprung um ${changePercent.toFixed(1)}% (${(item.baseline_cents / 100).toFixed(2)} € -> ${(item.price_cents / 100).toFixed(2)} €).`
          );
          // Mark for review, do not silently apply
          entry.flagged_for_review = true;
        }
      }

      this.priceHistory.push(entry);
      evaluated.push(entry);
    }

    return {
      evaluatedCount: evaluated.length,
      anomaliesCount: this.anomalies.length,
      syncedAt: now.toISOString(),
    };
  }

  logAnomaly(type, item, reason) {
    const report = {
      type,
      product_id: item.product_id,
      chain: item.chain,
      title: item.title,
      price_cents: item.price_cents,
      reason,
      timestamp: new Date().toISOString(),
    };
    this.anomalies.push(report);
    console.warn(`[QualityMonitor Warning] ${type.toUpperCase()}: ${reason}`);
  }

  /**
   * 6-Hour Cache Sync Validator
   */
  isSyncDue(intervalHours = 6) {
    const hoursElapsed = (new Date() - this.lastCacheSync) / (1000 * 60 * 60);
    return hoursElapsed >= intervalHours;
  }

  markSynced() {
    this.lastCacheSync = new Date();
    console.log(`[QualityMonitor] Cache successfully re-synced at ${this.lastCacheSync.toISOString()}`);
  }

  /**
   * Generates a Data Quality Report for the Developer Dashboard
   */
  getQualitySummary() {
    const totalEntries = this.priceHistory.length;
    const flagged = this.priceHistory.filter(p => p.flagged_for_review).length;
    const healthScore = totalEntries > 0 ? (((totalEntries - flagged) / totalEntries) * 100).toFixed(1) : 100.0;

    return {
      totalTrackedPrices: totalEntries,
      flaggedCount: flagged,
      anomaliesCount: this.anomalies.length,
      healthScorePercent: parseFloat(healthScore),
      lastSync: this.lastCacheSync.toISOString(),
      supportedRegions: ['Mainz-Bingen', 'Rhein-Hunsrück'],
    };
  }
}

module.exports = { PriceQualityMonitor };

