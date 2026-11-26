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
  console.log('⏭️  test_uebernehmen_dm: kein Chrome gefunden, übersprungen');
  process.exit(0);
}

const root = path.join(__dirname, '..');
const extract = fs.readFileSync(path.join(root, 'app/web/uebernehmen/extract.js'), 'utf8');
const page = fs.readFileSync(path.join(__dirname, 'fixtures/uebernehmen_dm_kacheln.html'), 'utf8');
const harness = page.replace(
  '</body>',
  `<script>window.__UEBERNEHMEN_TEST__ = { chain: 'dm', now: '2026-11-24T10:00:00Z' };</script>
<script>${extract}</script></body>`,
);
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'uebernehmen-dm-'));
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

const by = Object.fromEntries(result.offers.map((o) => [o.source_id, o]));
assert.deepStrictEqual(Object.keys(by), ['1000001', '1000002', '1000003', '1000004', '1000005'],
  'Doppelte Kachel einmal, Kachel ohne Preis weggelassen');

assert.strictEqual(by['1000001'].title, 'dmBio Trockenfrüchte, Apfelcrunchies, 35 g', 'Marke mit Leerzeichen vor dem Namen');
assert.strictEqual(by['1000001'].price_cents, 295);
assert.strictEqual(by['1000001'].original_price_cents, null);
assert.strictEqual(by['1000001'].unit_info, '0,035 kg (84,29 € je 1 kg)');

assert.strictEqual(by['1000002'].title, 'Mivolis Sterile Kompressen 7,5 cm x 7,5 cm, 10 St', 'ohne angehängte Kategorie');
assert.strictEqual(by['1000002'].price_cents, 185, 'nicht 7,50 aus dem Namen');
assert.strictEqual(by['1000003'].unit_info, null);
assert.strictEqual(by['1000004'].title, 'dm home Trinkglas, transparent (250 ml), 1 St', 'Marke nicht doppelt');

assert.strictEqual(by['1000005'].price_cents, 75);
assert.strictEqual(by['1000005'].original_price_cents, 95);
assert.strictEqual(by['1000005'].discount_percent, 21);

assert.strictEqual(result.valid_guessed, true, 'dm-Seite nennt keinen Zeitraum');

console.log('✅ test_uebernehmen_dm: dm-Kacheln korrekt erkannt');
