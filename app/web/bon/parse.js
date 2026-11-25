/*
 * Kassenbon-Leser für den Einkaufs-Optimierer.
 *
 * Wandelt den Text eines Kassenbons (aus der Texterkennung oder eingefügt)
 * in Artikelzeilen mit Preis um. Reine Funktion ohne Seiteneffekte, damit sie
 * im Browser (bon.html) und in Node-Tests (backend_tests) gleich läuft.
 */
(function (root) {
  'use strict';

  var CHAINS = [
    [/\brewe\b/i, 'rewe'],
    [/\blidl\b/i, 'lidl'],
    [/aldi\s*s(ü|u|ue)d/i, 'aldi_sued'],
    [/aldi\s*nord/i, 'aldi_nord'],
    [/\baldi\b/i, 'aldi_sued'],
    [/netto\s*marken|netto-online|\bnetto\b(?!\s*(brutto|betrag|\d))/i, 'netto'],
    [/\bdm\b|dm-drogerie|drogerie\s*markt/i, 'dm'],
    [/rossmann/i, 'rossmann']
  ];

  // Ende der Artikelliste
  var STOP_RE = /^(summe|zu zahlen|total|gesamt(betrag)?|zwischensumme|betrag|endsumme)\b/i;
  // Zeilen ohne Artikel
  var SKIP_RE = /(pfand|leergut|mwst|ust\b|steuer|netto\s+brutto|brutto|rückgeld|rueckgeld|gegeben|kartenzahlung|ec-?karte|girocard|visa|mastercard|payback|bonus|coupon|punkte|kundenkarte|lidl plus|bar\b|^eur\b|^kasse|^bon\b|^beleg|^datum|^uhrzeit|^filiale|^tel|^ust-?id|^st\.?-?nr)/i;
  var DISCOUNT_RE = /(rabatt|preisvorteil|nachlass|aktion|sofortrabatt|ersparnis)/i;

  // OCR verwechselt in Preisen gern Buchstaben mit Ziffern: "l,99", "O,99"
  function fixDigits(s) {
    return s.replace(/(^|[\s-])([0-9lIO|]{1,3})[.,]([0-9lIO|]{2})(?=\s|$|[A-Z*])/g, function (m, pre, a, b) {
      var f = function (x) { return x.replace(/[lI|]/g, '1').replace(/O/g, '0'); };
      return pre + f(a) + ',' + f(b);
    });
  }

  function cents(str) {
    var m = /(-?)(\d{1,4})[.,](\d{2})/.exec(str);
    if (!m) return null;
    var v = parseInt(m[2], 10) * 100 + parseInt(m[3], 10);
    return m[1] ? -v : v;
  }

  function letters(s) {
    var m = s.match(/[a-zäöüß]/gi);
    return m ? m.length : 0;
  }

  function detectChain(text) {
    var head = text.split('\n').slice(0, 12).join('\n');
    for (var i = 0; i < CHAINS.length; i++) if (CHAINS[i][0].test(head)) return CHAINS[i][1];
    for (var k = 0; k < CHAINS.length; k++) if (CHAINS[k][0].test(text)) return CHAINS[k][1];
    return null;
  }

  function pad(n) { return (n < 10 ? '0' : '') + n; }

  function detectDate(text) {
    var re = /(\d{1,2})\.(\d{1,2})\.(\d{4}|\d{2})(?!\d)/g;
    var m;
    while ((m = re.exec(text)) !== null) {
      var d = parseInt(m[1], 10);
      var mo = parseInt(m[2], 10);
      var y = parseInt(m[3], 10);
      if (y < 100) y += 2000;
      if (d >= 1 && d <= 31 && mo >= 1 && mo <= 12 && y >= 2020 && y <= 2100) return y + '-' + pad(mo) + '-' + pad(d);
    }
    return null;
  }

  // "2 Stk x 0,99" / "2 x 0,99" / "0,99 x 2"
  var QTY_RE = /(?:^|\s)(\d{1,2})\s*(?:stk\.?|st\.?|stück)?\s*[x×*]\s*(-?\d{1,4}[.,]\d{2})/i;
  var QTY_RE2 = /(-?\d{1,4}[.,]\d{2})\s*[x×*]\s*(\d{1,2})(?:\s|$)/i;
  // "0,452 kg x 2,99 EUR/kg"
  var WEIGHT_RE = /(\d+[.,]\d{1,3})\s*kg\s*[x×*]\s*(\d{1,4}[.,]\d{2})\s*(?:eur|€)?\s*\/\s*kg/i;
  var TRAILING_PRICE_RE = /(-?\d{1,4}[.,]\d{2})\s*(?:€|eur)?\s*(?:[A-D]|\*|[A-D]\s*\*)?\s*$/i;

  function cleanTitle(s) {
    return s
      .replace(/^\s*\d{5,}\s*/, '') // Artikelnummer am Anfang
      .replace(/\s+\d{5,}\s*$/, '')
      .replace(/[*#]+/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  // Treue-Apps: Zeilen, die zeigen, dass an der Kasse eine App/Karte gescannt wurde
  var LOYALTY_RE = /(rewe\s*bonus|bonus-?guthaben|\bbonus\b|payback|punkte|°\s*p\b|lidl\s*plus|deutschlandcard|kundenkarte)/i;
  var REDEEM_RE = /(eingel(ö|o|oe)st|einl(ö|o|oe)sung|verrechnet|abgezogen)/i;
  var EARN_RE = /(gesammelt|gutgeschrieben|erhalten|sammelst|erhältst|erhaltst|\+\s*\d)/i;
  var BALANCE_RE = /((neues|aktuelles|dein|ihr)\s*(bonus-?)?guthaben|guthaben\s*(neu|aktuell|gesamt)|kontostand|punktestand)/i;
  var POINTS_WORD_RE = /punkte|°\s*p\b/i;
  var PROGRAM_BY_CHAIN = { rewe: 'rewe', lidl: 'lidl_plus', dm: 'dm', rossmann: 'rossmann', netto: 'netto' };

  function amountIn(l) {
    var m = /(-?\d{1,4}[.,]\d{2})/.exec(l);
    return m ? Math.abs(cents(m[1])) : null;
  }

  function pointsIn(l) {
    var m = /(\d{1,3}(?:\.\d{3})+|\d+)\s*(?:°\s*p\b|payback-?\s*punkte|punkte|pkt)/i.exec(l);
    return m ? parseInt(m[1].replace(/\./g, ''), 10) : null;
  }

  /** Bonus-/Punktezeilen eines Bons auswerten. */
  function parseLoyalty(lines, chain) {
    var out = { detected: false, program: null, lines: [] };
    for (var i = 0; i < lines.length; i++) {
      var l = lines[i];
      var inBlock = out.detected && (EARN_RE.test(l) || REDEEM_RE.test(l) || BALANCE_RE.test(l));
      if (!LOYALTY_RE.test(l) && !inBlock) continue;
      out.detected = true;
      out.lines.push(l);
      if (/payback/i.test(l) || (l.indexOf('°') >= 0 && POINTS_WORD_RE.test(l))) out.program = 'payback';
      var amount = amountIn(l);
      // Betrag steht oft in der Folgezeile
      if (amount === null && i + 1 < lines.length && !LOYALTY_RE.test(lines[i + 1])) amount = amountIn(lines[i + 1]);
      var pts = pointsIn(l);
      if (BALANCE_RE.test(l)) {
        if (POINTS_WORD_RE.test(l) && pts !== null) out.balance_points = pts;
        else if (amount !== null) out.balance_cents = amount;
      } else if (REDEEM_RE.test(l)) {
        if (amount !== null) out.redeemed_cents = (out.redeemed_cents || 0) + amount;
      } else if (pts !== null) {
        out.points = (out.points || 0) + pts;
      } else if (EARN_RE.test(l) && amount !== null) {
        out.earned_cents = (out.earned_cents || 0) + amount;
      }
    }
    if (!out.program && chain) out.program = PROGRAM_BY_CHAIN[chain] || null;
    return out;
  }

  function parseReceipt(text, nowIso) {
    var raw = fixDigits(String(text || '').replace(/\r/g, ''));
    var lines = raw.split('\n').map(function (l) { return l.replace(/\s+/g, ' ').trim(); }).filter(Boolean);
    var items = [];
    var total = null;
    var pendingQty = null;

    for (var i = 0; i < lines.length; i++) {
      var l = lines[i];
      if (STOP_RE.test(l)) {
        var t = TRAILING_PRICE_RE.exec(l);
        if (t) total = cents(t[1]);
        break;
      }
      var prev = items.length > 0 ? items[items.length - 1] : null;

      var w = WEIGHT_RE.exec(l);
      if (w) {
        var perKg = cents(w[2]);
        var kg = w[1].replace('.', ',');
        if (prev && letters(l.replace(WEIGHT_RE, '').replace(/eur|kg/gi, '')) < 3) {
          prev.price_cents = perKg;
          prev.unit_info = kg + ' kg à ' + w[2].replace('.', ',') + ' €/kg';
        }
        continue;
      }

      var q = QTY_RE.exec(l);
      var qty = null;
      var unit = null;
      if (q) { qty = parseInt(q[1], 10); unit = cents(q[2]); }
      else {
        var q2 = QTY_RE2.exec(l);
        if (q2) { qty = parseInt(q2[2], 10); unit = cents(q2[1]); }
      }
      var rest = l.replace(QTY_RE, ' ').replace(QTY_RE2, ' ');
      if (qty && letters(rest.replace(/stk|stück|eur/gi, '')) < 3) {
        // Mengenzeile ohne Text: gehört zum Artikel davor (oder danach)
        if (prev && !prev.unit_info) {
          prev.price_cents = unit;
          prev.unit_info = qty + ' × ' + (unit / 100).toFixed(2).replace('.', ',') + ' €';
          prev.quantity = qty;
        } else {
          pendingQty = { qty: qty, unit: unit };
        }
        continue;
      }

      var m = TRAILING_PRICE_RE.exec(l);
      if (!m) continue;
      var lineCents = cents(m[1]);
      var title = cleanTitle(l.slice(0, m.index).replace(QTY_RE, ' ').replace(QTY_RE2, ' '));

      if (lineCents < 0 || DISCOUNT_RE.test(title)) {
        // Rabattzeile verrechnet sich mit dem Artikel davor
        if (prev && lineCents < 0) {
          var perUnit = Math.round(lineCents / (prev.quantity || 1));
          prev.price_cents = Math.max(1, prev.price_cents + perUnit);
          prev.line_cents += lineCents;
          prev.unit_info = (prev.unit_info ? prev.unit_info + ', ' : '') + 'mit Rabatt';
        }
        continue;
      }
      if (SKIP_RE.test(title) || letters(title) < 3) continue;

      var item = { title: title, price_cents: lineCents, line_cents: lineCents, unit_info: null, quantity: 1 };
      if (qty && unit) {
        item.price_cents = unit;
        item.quantity = qty;
        item.unit_info = qty + ' × ' + (unit / 100).toFixed(2).replace('.', ',') + ' €';
      } else if (pendingQty) {
        item.price_cents = pendingQty.unit;
        item.quantity = pendingQty.qty;
        item.unit_info = pendingQty.qty + ' × ' + (pendingQty.unit / 100).toFixed(2).replace('.', ',') + ' €';
      }
      pendingQty = null;
      items.push(item);
    }

    var sum = items.reduce(function (a, it) { return a + it.line_cents; }, 0);
    var date = detectDate(raw);
    var chain = detectChain(raw);
    return {
      chain: chain,
      loyalty: parseLoyalty(lines, chain),
      date: date || (nowIso || new Date().toISOString()).slice(0, 10),
      date_guessed: !date,
      items: items.filter(function (it) { return it.price_cents > 0; }),
      total_cents: total,
      items_sum_cents: sum
    };
  }

  var api = { parseReceipt: parseReceipt, parseLoyalty: parseLoyalty, detectChain: detectChain, detectDate: detectDate };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.BonParser = api;
})(this);
