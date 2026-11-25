// Treue-Apps: Guthaben-Leser (app/web/konto/parse.js) und Bonus-Zeilen im
// Kassenbon-Leser (app/web/bon/parse.js) an typischen Texten der Texterkennung.
const assert = require('assert');
const path = require('path');
const { parseBalance } = require(path.join(__dirname, '../app/web/konto/parse.js'));
const { parseReceipt } = require(path.join(__dirname, '../app/web/bon/parse.js'));

// REWE-App-Startseite: Betrag in der Zeile unter dem Stichwort, "l" statt "1"
const rewe = parseBalance(`
09:41
Hallo Magnus
Dein Bonus-Guthaben
l2,79 €
Guthaben einlösen
`, 'euro');
assert.strictEqual(rewe.value_cents, 1279, 'REWE-Guthaben aus Folgezeile, l als 1 gelesen');

// PAYBACK: Punktestand mit Tausenderpunkt und °P
const pb = parseBalance(`
PAYBACK
Punktestand
1.234 °P
entspricht 12,34 €
`, 'points');
assert.strictEqual(pb.points, 1234);

// Ohne Stichwort, aber mit °P
assert.strictEqual(parseBalance('Willkommen\n 980 °P \nCoupons', 'points').points, 980);

// Nichts Lesbares
assert.strictEqual(parseBalance('Willkommen in der App', 'euro'), null);

// Kassenbon mit REWE-Bonus-Zeilen (Zeilen nach der Summe zählen mit)
const bon = parseReceipt(`
REWE Markt GmbH
BANANE CHIQUITA      1,35 B
SUMME           EUR  1,35
REWE Bonus
Bonus-Guthaben eingelöst   -2,00
Mit diesem Einkauf gesammelt  0,45 €
Dein neues Bonus-Guthaben  12,79 €
Datum: 24.11.2026
`);
assert.strictEqual(bon.loyalty.detected, true);
assert.strictEqual(bon.loyalty.program, 'rewe');
assert.strictEqual(bon.loyalty.redeemed_cents, 200);
assert.strictEqual(bon.loyalty.earned_cents, 45);
assert.strictEqual(bon.loyalty.balance_cents, 1279);
assert.deepStrictEqual(bon.items.map((i) => i.title), ['BANANE CHIQUITA'], 'Bonuszeilen sind keine Artikel');

// Bon ohne Treue-Zeilen
const plain = parseReceipt(`
LIDL
GURKE 0,69 A
SUMME 0,69
`);
assert.strictEqual(plain.loyalty.detected, false);
assert.strictEqual(plain.loyalty.program, 'lidl_plus');

// PAYBACK-Punkte auf dem Bon
const dm = parseReceipt(`
dm-drogerie markt
ZAHNPASTA 1,95
SUMME 1,95
PAYBACK Punkte 3 °P
Punktestand 1.237 °P
`);
assert.strictEqual(dm.loyalty.program, 'payback');
assert.strictEqual(dm.loyalty.points, 3);
assert.strictEqual(dm.loyalty.balance_points, 1237);

console.log('test_konto_parse: ok');
