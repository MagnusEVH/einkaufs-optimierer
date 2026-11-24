// Übernehmen-Knopf, REWE-Regel: nachgebaute Angebotskacheln in Headless-Chrome.
// Prüft die Fälle aus dem Praxistest (V43): Streichpreis und "Niedrigster Preis
// der letzten 30 Tage" sind kein Angebotspreis. Ohne Chrome übersprungen.
const assert = require('assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');

const candidates = [
  process.env.CHROME_PATH,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  '/usr/bin/google-chrome',
  '/usr/bin/google-chrome-stable',
  '/usr/bin/chromium',
  '/usr/bin/chromium-browser',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
].filter(Boolean);
const chrome = candidates.find((p) => fs.existsSync(p));
if (!chrome) {
  console.log('⏭️  test_uebernehmen_rewe: kein Chrome gefunden, übersprungen');
  process.exit(0);
}

const root = path.join(__dirname, '..');
const extract = fs.readFileSync(path.join(root, 'app/web/uebernehmen/extract.js'), 'utf8');
const page = fs.readFileSync(path.join(__dirname, 'fixtures/uebernehmen_rewe_kacheln.html'), 'utf8');
const harness = page.replace(
  '</body>',
  `<script>window.__UEBERNEHMEN_TEST__ = { chain: 'rewe', now: '2026-11-24T10:00:00Z' };</script>
<script>${extract}</script></body>`,
);
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'uebernehmen-rewe-'));
const file = path.join(tmp, 'harness.html');
fs.writeFileSync(file, harness, 'utf8');
const dom = execFileSync(
  chrome,
  ['--headless=new', '--disable-gpu', '--no-sandbox', `--user-data-dir=${path.join(tmp, 'profile')}`, '--dump-dom', 'file:///' + file.split(path.sep).join('/')],
  { encoding: 'utf8', timeout: 60000 },
);
fs.rmSync(tmp, { recursive: true, force: true });

const m = dom.match(/data-uebernehmen-result="([^"]*)"/);
assert.ok(m, 'Ergebnis-Attribut fehlt');
const result = JSON.parse(m[1].replace(/&quot;/g, '"').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>'));

// Gültigkeit aus der Kalenderwoche: Montag bis Samstag
assert.strictEqual(result.valid_from, '2026-11-23');
assert.strictEqual(result.valid_to, '2026-11-28');
assert.strictEqual(result.valid_guessed, false);

const by = Object.fromEntries(result.offers.map((o) => [o.title, o]));
assert.deepStrictEqual(Object.keys(by), ['Kinder Country', 'Dr. Oetker Ristorante Pizza Salame', 'Cola-Mix Kasten', 'Kaffeekapseln'],
  'Doppelte Kachel einmal, reine Bonus-Kachel ohne Preis weggelassen');

assert.strictEqual(by['Kinder Country'].price_cents, 199);
assert.strictEqual(by['Kinder Country'].original_price_cents, 329);
assert.strictEqual(by['Kinder Country'].discount_percent, 40);
assert.strictEqual(by['Kinder Country'].unit_info, 'je 9 x 23,5-g-Pckg., (1 kg = 9,41 €)');
assert.strictEqual(by['Kinder Country'].source_id, '111');

assert.strictEqual(by['Dr. Oetker Ristorante Pizza Salame'].price_cents, 177, 'nicht 1,79 aus dem 30-Tage-Hinweis');
assert.strictEqual(by['Dr. Oetker Ristorante Pizza Salame'].original_price_cents, null);

assert.strictEqual(by['Cola-Mix Kasten'].price_cents, 1199);
assert.strictEqual(by['Cola-Mix Kasten'].original_price_cents, 1699);
assert.ok(/\+2,00 € REWE Bonus/.test(by['Cola-Mix Kasten'].unit_info), 'Bonus als Hinweis');

assert.strictEqual(by['Kaffeekapseln'].price_cents, 499);
assert.ok(/ab-Preis/.test(by['Kaffeekapseln'].unit_info));

console.log('✅ test_uebernehmen_rewe: REWE-Kacheln korrekt erkannt');
