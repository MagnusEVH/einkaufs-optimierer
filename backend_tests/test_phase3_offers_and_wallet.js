// backend_tests/test_phase3_offers_and_wallet.js
// Unit tests for Phase 3:
// - Weekly promotional offers price overrides
// - Loyalty wallet points accounting across retail chains
// - Coupon discount deductions (percentage, minimum spend thresholds, points multiplier)

const assert = require('assert');
const catalog = require('../test_data/products_seed_250.json');
const sampleData = require('../test_data/sample_offers_and_wallet.json');

const weeklyOffers = sampleData.weekly_offers;
const loyaltyAccounts = sampleData.sample_loyalty_accounts;
const userCoupons = sampleData.sample_user_coupons;

console.log('=== TEST SUITE 5: PHASE 3 OFFERS & LOYALTY WALLET ===\n');

// 1. TEST: Weekly Promotional Offer Override
console.log('Test 1: Weekly Promotional Offers Price Override');

function getEffectiveItemPrice(productName, chain) {
  const prod = catalog.products.find(p => p.name.toLowerCase().includes(productName.toLowerCase()));
  if (!prod) return null;

  const basePrice = prod.prices[chain] || 199;

  // Check if an active offer exists
  const activeOffer = weeklyOffers.find(o => 
    o.chain === chain && 
    o.is_active && 
    o.product_name.toLowerCase().includes(productName.toLowerCase())
  );

  if (activeOffer) {
    return {
      priceCents: activeOffer.discount_price_cents,
      regularPriceCents: basePrice,
      hasOffer: true,
      offerTitle: activeOffer.title,
      savingsCents: basePrice - activeOffer.discount_price_cents,
    };
  }

  return {
    priceCents: basePrice,
    regularPriceCents: basePrice,
    hasOffer: false,
    savingsCents: 0,
  };
}

// Kerrygold Butter at Lidl has an offer of 2.19 € (regular: 2.39 €)
const kerrygoldPrice = getEffectiveItemPrice('Kerrygold', 'lidl');
console.log(`  Kerrygold Butter at Lidl: ${kerrygoldPrice.priceCents / 100} € (Regulär: ${kerrygoldPrice.regularPriceCents / 100} €) - Offer: "${kerrygoldPrice.offerTitle}"`);
assert.strictEqual(kerrygoldPrice.hasOffer, true, 'Active weekly offer must be flagged');
assert.strictEqual(kerrygoldPrice.priceCents, 219, 'Price must match the weekly promotional price');
assert(kerrygoldPrice.savingsCents > 0, 'Promotional offer must yield positive savings');
console.log('  ✅ Weekly offer override verified!\n');

// 2. TEST: Loyalty Wallet Points Accounting
console.log('Test 2: Loyalty Wallet Points Accounting per Retail Chain');

let totalWalletValueCents = 0;
loyaltyAccounts.forEach(acc => {
  console.log(`  [${acc.chain.toUpperCase()}] ${acc.program_name}: ${acc.points_balance} Punkte (~${(acc.points_value_cents / 100).toFixed(2)} € Guthaben)`);
  totalWalletValueCents += acc.points_value_cents;
});

const payback = loyaltyAccounts.find(a => a.chain === 'rewe');
const lidlPlus = loyaltyAccounts.find(a => a.chain === 'lidl');
const deutschlandCard = loyaltyAccounts.find(a => a.chain === 'netto');

assert(payback.points_balance > 0, 'Rewe Payback points must be recorded');
assert(lidlPlus.points_balance > 0, 'Lidl Plus points must be recorded');
assert(deutschlandCard.points_balance > 0, 'Netto DeutschlandCard points must be recorded');
console.log(`  Gesamtes Guthaben über alle Ketten: ${(totalWalletValueCents / 100).toFixed(2)} €`);
assert.strictEqual(totalWalletValueCents, 2700, 'Total points value must match sum (14.20 + 4.50 + 8.30 = 27.00 €)');
console.log('  ✅ Loyalty wallet accounting verified!\n');

// 3. TEST: Coupon Deductions & Minimum Spend Thresholds
console.log('Test 3: Coupon Application (Category Discount & Minimum Spend Threshold)');

function applyCouponsToSubtotal({ chain, basketSubtotalCents, categoryItems = {} }) {
  let discountCents = 0;
  const appliedCoupons = [];

  const chainCoupons = userCoupons.filter(c => c.chain === chain && c.is_active);

  for (const coup of chainCoupons) {
    // Check minimum spend
    if (basketSubtotalCents < coup.min_spend_cents) {
      console.log(`  [Info] Coupon "${coup.title}" nicht angewendet: Mindestumsatz ${coup.min_spend_cents / 100} € nicht erreicht (Warenkorb: ${basketSubtotalCents / 100} €).`);
      continue;
    }

    if (coup.discount_type === 'percent') {
      if (coup.category_slug && categoryItems[coup.category_slug]) {
        // Apply only to category
        const catSum = categoryItems[coup.category_slug];
        const d = Math.round(catSum * (coup.discount_value / 100.0));
        discountCents += d;
        appliedCoupons.push({ title: coup.title, discountCents: d });
      } else if (!coup.category_slug) {
        const d = Math.round(basketSubtotalCents * (coup.discount_value / 100.0));
        discountCents += d;
        appliedCoupons.push({ title: coup.title, discountCents: d });
      }
    } else if (coup.discount_type === 'fixed_amount') {
      const d = Math.round(coup.discount_value);
      discountCents += d;
      appliedCoupons.push({ title: coup.title, discountCents: d });
    }
  }

  return {
    originalSubtotalCents: basketSubtotalCents,
    discountCents,
    finalSubtotalCents: Math.max(0, basketSubtotalCents - discountCents),
    appliedCoupons,
  };
}

// Case 3a: Lidl Basket >= 15 € -> 1.00 € coupon triggers!
const lidlBasketHigh = applyCouponsToSubtotal({
  chain: 'lidl',
  basketSubtotalCents: 1850, // 18.50 EUR
});
console.log(`  Lidl Einkauf 18.50 €: Coupon Abzug: -${lidlBasketHigh.discountCents / 100} € -> Endsumme: ${lidlBasketHigh.finalSubtotalCents / 100} €`);
assert.strictEqual(lidlBasketHigh.discountCents, 100, '1.00 € coupon must be deducted when basket >= 15 €');
assert.strictEqual(lidlBasketHigh.finalSubtotalCents, 1750, 'Final subtotal must reflect 1.00 € discount');

// Case 3b: Lidl Basket < 15 € -> 1.00 € coupon does NOT trigger
const lidlBasketLow = applyCouponsToSubtotal({
  chain: 'lidl',
  basketSubtotalCents: 1100, // 11.00 EUR
});
console.log(`  Lidl Einkauf 11.00 €: Coupon Abzug: -${lidlBasketLow.discountCents / 100} € -> Endsumme: ${lidlBasketLow.finalSubtotalCents / 100} €`);
assert.strictEqual(lidlBasketLow.discountCents, 0, 'Coupon must NOT trigger when below minimum spend');

// Case 3c: Rewe 10% coupon on Obst
const reweBasket = applyCouponsToSubtotal({
  chain: 'rewe',
  basketSubtotalCents: 2500,
  categoryItems: {
    obst: 600, // 6.00 € fruit
  },
});
console.log(`  Rewe Einkauf (6.00 € Obst): Coupon Abzug: -${reweBasket.discountCents / 100} € -> Endsumme: ${reweBasket.finalSubtotalCents / 100} €`);
assert.strictEqual(reweBasket.discountCents, 60, '10% on 6.00 € fruit must yield 0.60 € discount');

console.log('\n✅ ALL PHASE 3 UNIT TESTS PASSED SUCCESSFULLY!\n');
