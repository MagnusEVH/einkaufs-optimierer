// REWE-eBon (digitaler Kassenbon aus der REWE-App, PDF mit echtem Text):
// Artikel und REWE-Bonus-Zeilen im Format von 2025/26 sowie im älteren Format.
// Zeilenformat nach dem Text, den der PDF-Leser in bon.html aus einem eBon gewinnt.
const assert = require('assert');
const path = require('path');
const { parseReceipt } = require(path.join(__dirname, '../app/web/bon/parse.js'));

const neu = parseReceipt(`
REWE Markt GmbH
Schultheiss-Kollei-Str. 19
55411 Bingen
EUR
BROCCOLI 1,79 B
FRISCHMILCH 3,8 2,19 B
TOM. MINI RISPE 1,79 B
LEERGUT -0,25 A *
--------------------------------------
SUMME EUR 5,52
======================================
24.11.2026 18:31 Bon-Nr.:4711
Deine REWE Bonus-Vorteile heute
Mit diesem Einkauf hast du 0,83 EUR
REWE Bonus-Guthaben gesammelt:
Bonus-Coupon(s)
10% auf REWE Regiona 0,18 EUR
0,50EUR auf Little L 0,50 EUR
Aktuelles Bonus-Guthaben: 7,66 EUR
`);

assert.strictEqual(neu.chain, 'rewe');
assert.strictEqual(neu.date, '2026-11-24');
assert.deepStrictEqual(neu.items.map((i) => i.title), ['BROCCOLI', 'FRISCHMILCH 3,8', 'TOM. MINI RISPE']);
assert.strictEqual(neu.loyalty.detected, true);
assert.strictEqual(neu.loyalty.program, 'rewe');
assert.strictEqual(neu.loyalty.earned_cents, 83, 'Betrag aus der Vorzeile');
assert.strictEqual(neu.loyalty.balance_cents, 766);
assert.strictEqual(neu.loyalty.redeemed_cents, undefined, 'Coupons sind kein eingelöstes Guthaben');

const alt = parseReceipt(`
REWE Markt GmbH
BANANE 1,35 B
SUMME EUR 1,35
Eingesetztes REWE Guthaben: 2,00 EUR
Neues REWE Guthaben: 9,26 EUR
`);
assert.strictEqual(alt.loyalty.detected, true);
assert.strictEqual(alt.loyalty.redeemed_cents, 200);
assert.strictEqual(alt.loyalty.balance_cents, 926);

console.log('test_ebon_parse: ok');
