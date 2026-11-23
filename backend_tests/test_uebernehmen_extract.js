// Prüft das Übernehmen-Skript (app/web/uebernehmen/extract.js) an einer
// synthetischen Testseite in Headless-Chrome. Ohne Chrome wird der Test übersprungen.

const fs = require('fs');
const os = require('os');
const path = require('path');
const assert = require('assert');
const { execFileSync } = require('child_process');

function findChrome() {
  const candidates = [
    process.env.CHROME_PATH,
    'C:/Program Files/Google/Chrome/Application/chrome.exe',
    'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
    'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
    '/usr/bin/google-chrome',
    '/usr/bin/google-chrome-stable',
    '/usr/bin/chromium-browser',
    '/usr/bin/chromium',
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  ].filter(Boolean);
  return candidates.find((p) => fs.existsSync(p)) || null;
}

const chrome = findChrome();
if (!chrome) {
  console.log('⏭️  test_uebernehmen_extract: kein Chrome gefunden, übersprungen');
  process.exit(0);
}

const root = path.join(__dirname, '..');
const extract = fs.readFileSync(path.join(root, 'app/web/uebernehmen/extract.js'), 'utf8');
const page = fs.readFileSync(path.join(__dirname, 'fixtures/uebernehmen_testseite.html'), 'utf8');

const harness = page.replace(
  '</body>',
  `<script>window.__UEBERNEHMEN_TEST__ = { chain: 'rewe', now: '2026-11-25T10:00:00Z' };</script>
<script>${extract}</script></body>`,
);
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'uebernehmen-'));
const file = path.join(tmp, 'harness.html');
fs.writeFileSync(file, harness, 'utf8');

const dom = execFileSync(
  chrome,
  ['--headless=new', '--disable-gpu', '--no-sandbox', `--user-data-dir=${path.join(tmp, 'profile')}`, '--dump-dom', `file:///${file.replace(/\\/g, '/')}`],
  { encoding: 'utf8', timeout: 60000 },
);
fs.rmSync(tmp, { recursive: true, force: true });

const m = dom.match(/data-uebernehmen-result="([^"]*)"/);
assert.ok(m, 'Ergebnis-Attribut fehlt');
const decoded = m[1].replace(/&quot;/g, '"').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>');
const result = JSON.parse(decoded);

assert.strictEqual(result.v, 1);
assert.strictEqual(result.chain, 'rewe');
assert.strictEqual(result.valid_from, '2026-11-24');
assert.strictEqual(result.valid_to, '2026-11-29');
assert.strictEqual(result.valid_guessed, false);

const byTitle = Object.fromEntries(result.offers.map((o) => [o.title, o]));

const butter = byTitle['Kerrygold Irische Butter 250g'];
assert.ok(butter, 'Butter-Angebot fehlt: ' + JSON.stringify(result.offers));
assert.strictEqual(butter.price_cents, 199);
assert.strictEqual(butter.original_price_cents, 265);
assert.strictEqual(butter.discount_percent, 25);
assert.ok(/7,96/.test(butter.unit_info), 'Grundpreis als unit_info');

const bananen = byTitle['Bananen'];
assert.ok(bananen, 'Bananen fehlen');
assert.strictEqual(bananen.price_cents, 129);
assert.strictEqual(bananen.original_price_cents, null);

const somat = byTitle['Somat Gold Spülmaschinentabs 40 Stück'];
assert.ok(somat, 'Somat fehlt');
assert.strictEqual(somat.price_cents, 399);
assert.strictEqual(somat.original_price_cents, 549);

assert.ok(!result.offers.some((o) => o.price_cents === 390), 'Versandkosten dürfen kein Angebot sein');

console.log(`✅ test_uebernehmen_extract: ${result.offers.length} Angebote korrekt erkannt`);
