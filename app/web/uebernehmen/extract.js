/*
 * Übernehmen-Knopf (Bookmarklet) für den Einkaufs-Optimierer.
 *
 * Läuft nur, wenn du auf einer Angebotsseite selbst auf das Lesezeichen
 * klickst. Liest die sichtbaren Angebote dieser einen Seite und öffnet die App
 * mit den Daten im URL-Fragment (#import=…). Das Fragment wird nie an einen
 * Server gesendet; die Daten bleiben in deinem Browser.
 *
 * Kein Crawling, keine weiteren Abrufe: Es wird nur gelesen, was du siehst.
 * Platzhalter __APP_URL__ ersetzt uebernehmen.html beim Erzeugen des Lesezeichens.
 */
(function () {
  'use strict';

  var APP_URL = '__APP_URL__';
  var TEST = window.__UEBERNEHMEN_TEST__ || null;
  var MAX_OFFERS = 200;

  var CHAINS = {
    'rewe.de': 'rewe',
    'lidl.de': 'lidl',
    'aldi-sued.de': 'aldi_sued',
    'aldi-nord.de': 'aldi_nord',
    'netto-online.de': 'netto',
    'dm.de': 'dm',
    'rossmann.de': 'rossmann'
  };

  function chainOf(host) {
    for (var k in CHAINS) {
      if (host === k || host.slice(-(k.length + 1)) === '.' + k) return CHAINS[k];
    }
    return null;
  }

  var PRICE_RE = /(\d{1,3})[.,](\d{2})(?!\d)/g;
  var UNIT_RE = /(\bje\b|\bpro\b|=|\/\s*(kg|l|100\s*g|100\s*ml)\b|\b1\s*(kg|l)\b|grundpreis)/i;
  var ORIGINAL_RE = /(statt|uvp|vorher|zuletzt|bisher|ursprünglich|regulär)/i;
  var NOISE_RE = /^(aktion|angebot|neu|nur|ab|gültig|exklusiv|in den warenkorb|zum produkt|details|merken|mehr|top|tiefpreis|\*|-?\d+\s*%)/i;

  function prices(text) {
    var out = [];
    var m;
    PRICE_RE.lastIndex = 0;
    while ((m = PRICE_RE.exec(text)) !== null) out.push(parseInt(m[1], 10) * 100 + parseInt(m[2], 10));
    return out;
  }

  function lettersCount(s) {
    var m = s.match(/[a-zäöüß]/gi);
    return m ? m.length : 0;
  }

  // Ein "Preis-Blatt": Element, dessen eigener Text im Wesentlichen ein Preis ist.
  function isPriceLeaf(el) {
    if (el.children.length > 3) return false;
    var t = (el.textContent || '').trim();
    if (t.length === 0 || t.length > 40) return false;
    if (prices(t).length !== 1) return false;
    return /€|\*|^\s*-?\d{1,3}[.,]\d{2}\s*-?\s*$/.test(t) && lettersCount(t) <= 12;
  }

  function linesOf(el) {
    var raw = (el.innerText || el.textContent || '').split('\n');
    var out = [];
    for (var i = 0; i < raw.length; i++) {
      var l = raw[i].replace(/\s+/g, ' ').trim();
      if (l) out.push(l);
    }
    return out;
  }

  // Vom Preis aufwärts bis zur Produktkarte: enthält Bild oder Namen, bleibt kompakt.
  function cardFor(leaf) {
    var el = leaf;
    var best = null;
    for (var depth = 0; depth < 8 && el.parentElement; depth++) {
      el = el.parentElement;
      var text = el.innerText || el.textContent || '';
      if (text.length > 700) break;
      var hasName = linesOf(el).some(function (l) {
        return lettersCount(l) >= 4 && prices(l).length === 0 && !NOISE_RE.test(l);
      });
      if (hasName) {
        best = el;
        if (el.querySelector('img')) break;
      }
    }
    return best;
  }

  function parseCard(card) {
    var lines = linesOf(card);
    var current = [];
    var original = null;
    var unitInfo = null;
    var discount = null;
    var title = null;
    var grammage = null;

    lines.forEach(function (l) {
      var ps = prices(l);
      var d = l.match(/-\s*(\d{1,2})\s*%/);
      if (d) discount = parseInt(d[1], 10);
      if (ps.length > 0) {
        if (UNIT_RE.test(l)) {
          unitInfo = unitInfo || l;
        } else if (ORIGINAL_RE.test(l)) {
          // "1,99 € statt 2,65 €": vor dem Stichwort = Angebot, danach = Streichpreis
          var idx = l.search(ORIGINAL_RE);
          var before = prices(l.slice(0, idx));
          var after = prices(l.slice(idx));
          current = current.concat(before);
          if (after.length > 0) original = after[after.length - 1];
        } else {
          current = current.concat(ps);
        }
        return;
      }
      if (!grammage && /\d+([.,]\d+)?\s*(g|kg|ml|l|stück|st\.|er-packung|x)\b/i.test(l) && l.length < 60) grammage = l;
      if (NOISE_RE.test(l) || lettersCount(l) < 3 || l.length > 140) return;
      if (!title || lettersCount(l) > lettersCount(title)) title = l;
    });

    if (!title || current.length === 0) return null;
    if (grammage === title) grammage = null;
    var price = Math.min.apply(null, current);
    if (original === null && current.length > 1) {
      var max = Math.max.apply(null, current);
      if (max > price) original = max;
    }
    if (original !== null && original <= price) original = null;
    if (discount === null && original) discount = Math.round((1 - price / original) * 100);
    return {
      title: title,
      price_cents: price,
      original_price_cents: original,
      discount_percent: discount,
      unit_info: unitInfo || grammage
    };
  }

  function pad(n) { return (n < 10 ? '0' : '') + n; }

  // "gültig vom 24.11. bis 29.11." / "Mo., 24.11. – Sa., 29.11.2026"
  function validity(text, now) {
    var re = /(\d{1,2})\.(\d{1,2})\.(\d{2,4})?\s*(?:bis|-|–)\s*(?:[A-Za-zäöü]{2,10}\.?,?\s*)?(\d{1,2})\.(\d{1,2})\.(\d{2,4})?/;
    var m = text.match(re);
    if (!m) {
      var to = new Date(now.getTime() + 6 * 86400000);
      return { from: now.toISOString().slice(0, 10), to: to.toISOString().slice(0, 10), guessed: true };
    }
    function year(y, month) {
      if (y) return y.length === 2 ? 2000 + parseInt(y, 10) : parseInt(y, 10);
      var yr = now.getFullYear();
      if (now.getMonth() === 11 && month === 1) return yr + 1;
      if (now.getMonth() === 0 && month === 12) return yr - 1;
      return yr;
    }
    var fm = parseInt(m[2], 10);
    var tm = parseInt(m[5], 10);
    var fy = year(m[3], fm);
    var ty = year(m[6], tm);
    if (ty < fy) ty = fy + 1;
    return {
      from: fy + '-' + pad(fm) + '-' + pad(parseInt(m[1], 10)),
      to: ty + '-' + pad(tm) + '-' + pad(parseInt(m[4], 10)),
      guessed: false
    };
  }

  function toBase64Url(str) {
    var bytes = new TextEncoder().encode(str);
    var bin = '';
    for (var i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
    return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  function run() {
    var chain = TEST ? TEST.chain : chainOf(location.hostname.replace(/^www\./, ''));
    if (!chain) {
      alert('Einkaufs-Optimierer: Diese Seite gehört zu keiner unterstützten Kette.');
      return null;
    }

    var leaves = [];
    var all = document.body.getElementsByTagName('*');
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      if (el.tagName === 'SCRIPT' || el.tagName === 'STYLE') continue;
      if (isPriceLeaf(el)) leaves.push(el);
    }
    // Nur innerste Preis-Blätter behalten
    leaves = leaves.filter(function (el) {
      return !leaves.some(function (o) { return o !== el && el.contains(o); });
    });

    var cards = [];
    leaves.forEach(function (leaf) {
      var c = cardFor(leaf);
      if (c && cards.indexOf(c) < 0) cards.push(c);
    });
    // Verschachtelte Karten: die innerste gewinnt
    cards = cards.filter(function (c) {
      return !cards.some(function (o) { return o !== c && c.contains(o); });
    });

    var offers = [];
    var seen = {};
    cards.forEach(function (c) {
      var o = parseCard(c);
      if (!o) return;
      var key = o.title + '|' + o.price_cents;
      if (seen[key] || offers.length >= MAX_OFFERS) return;
      seen[key] = true;
      offers.push(o);
      if (!TEST) c.style.outline = '2px solid #059669';
    });

    var now = TEST && TEST.now ? new Date(TEST.now) : new Date();
    var v = validity(document.body.innerText || document.body.textContent || '', now);
    var payload = {
      v: 1,
      chain: chain,
      source_url: location.origin + location.pathname,
      captured_at: now.toISOString(),
      valid_from: v.from,
      valid_to: v.to,
      valid_guessed: v.guessed,
      offers: offers
    };

    if (TEST) {
      document.body.setAttribute('data-uebernehmen-result', JSON.stringify(payload));
      return payload;
    }
    if (offers.length === 0) {
      alert('Einkaufs-Optimierer: Keine Angebote erkannt. Tipp: Erst ganz nach unten scrollen, damit alle Angebote geladen sind.');
      return null;
    }
    var url = APP_URL + '#import=' + toBase64Url(JSON.stringify(payload));
    var w = window.open(url, '_blank');
    if (!w) location.href = url;
    return payload;
  }

  run();
})();
