// Bon-Scan: Der Kassenbon-Leser (app/web/bon/parse.js) an typischen Bon-Texten,
// wie sie die Texterkennung liefert (inkl. typischer Lesefehler).
const assert = require('assert');
const path = require('path');
const { parseReceipt } = require(path.join(__dirname, '../app/web/bon/parse.js'));

// REWE-Stil: Mengen- und Gewichtszeile unter dem Artikel, Pfand, Rabatt
const rewe = parseReceipt(`
REWE Markt GmbH
Schultheiss-Kollei-Str. 19
55411 Bingen
UID Nr.: DE812706034
                     EUR
KINDER COUNTRY 9ER   1,99 B
BANANE CHIQUITA      1,35 B
  0,452 kg x 2,99 EUR/kg
JA! H-MILCH 1,5%     1,98 B
  2 Stk x 0,99
COCA COLA 1,5L       1,29 A
PFAND 0,25 EURO      0,25 A
RISTORANTE SALAME    l,77 B
RABATT              -0,20 B
--------------------------
SUMME           EUR  8,43
Geg. BAR        EUR 10,00
Datum: 24.11.2026  18:31
`);

assert.strictEqual(rewe.chain, 'rewe');
assert.strictEqual(rewe.date, '2026-11-24');
assert.strictEqual(rewe.date_guessed, false);
assert.strictEqual(rewe.total_cents, 843);
const by = Object.fromEntries(rewe.items.map((i) => [i.title, i]));
assert.deepStrictEqual(Object.keys(by), ['KINDER COUNTRY 9ER', 'BANANE CHIQUITA', 'JA! H-MILCH 1,5%', 'COCA COLA 1,5L', 'RISTORANTE SALAME'], 'Pfand, Rabatt, Summe sind keine Artikel');
assert.strictEqual(by['KINDER COUNTRY 9ER'].price_cents, 199);
assert.strictEqual(by['BANANE CHIQUITA'].price_cents, 299, 'Kilopreis aus Gewichtszeile');
assert.ok(/0,452 kg/.test(by['BANANE CHIQUITA'].unit_info));
assert.strictEqual(by['JA! H-MILCH 1,5%'].price_cents, 99, 'Stückpreis aus Mengenzeile');
assert.strictEqual(by['JA! H-MILCH 1,5%'].quantity, 2);
assert.strictEqual(by['RISTORANTE SALAME'].price_cents, 157, 'l,77 als 1,77 gelesen, Rabatt 0,20 abgezogen');
assert.ok(/Rabatt/.test(by['RISTORANTE SALAME'].unit_info));
assert.strictEqual(rewe.items_sum_cents + 25, rewe.total_cents, 'Artikel + Pfand = Summe');

// Lidl-Stil: Menge in derselben Zeile, Steuerklasse am Ende, Datum zweistellig
const lidl = parseReceipt(`
LIDL
Mainzer Str. 100, Bingen
Bananen 0,99 x 2          1,98 A
Milbona Skyr Natur        1,49 A
Preisvorteil             -0,30 A
4056489012345 Spaghetti   0,79 A
zu zahlen                 3,96
Kartenzahlung Girocard    3,96
22.11.26 17:02
`);
assert.strictEqual(lidl.chain, 'lidl');
assert.strictEqual(lidl.date, '2026-11-22');
assert.deepStrictEqual(lidl.items.map((i) => [i.title, i.price_cents]), [
  ['Bananen', 99],
  ['Milbona Skyr Natur', 119],
  ['Spaghetti', 79],
]);
assert.strictEqual(lidl.total_cents, 396);

// Ohne Datum und Kette: Datum = heute (geschätzt), Kette unbekannt
const bare = parseReceipt('Butter 2,29\nSUMME 2,29', '2026-11-25T10:00:00Z');
assert.strictEqual(bare.chain, null);
assert.strictEqual(bare.date, '2026-11-25');
assert.strictEqual(bare.date_guessed, true);
assert.strictEqual(bare.items.length, 1);

// "Netto Brutto"-Zeile in der Steuerübersicht macht den Bon nicht zu Netto
assert.strictEqual(parseReceipt('ALDI SÜD\nMilch 0,99\nSumme 0,99\nNetto Brutto 0,93 0,99').chain, 'aldi_sued');

console.log('✅ test_bon_parse: REWE-, Lidl- und Minimal-Bon korrekt gelesen');
