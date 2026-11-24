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
  var MAX_OFFERS = 500;

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
  var LEGAL_RE = /(niedrigster preis|letzten 30 tage|30-tage)/i;
  var NOISE_RE =/^(aktion|angebot|neu|nur|ab|gültig|exklusiv|in den warenkorb|zum produkt|details|merken|mehr|top|tiefpreis|\*|-?\d+\s*%)/i;

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

  // Durchgestrichene Preise (Streichpreis) in einer Karte, als Cent-Werte.
  function struckPrices(card) {
    var out = [];
    var els = card.querySelectorAll('s, del, strike, [style*="line-through"], [class*="strike"], [class*="cross-out"]');
    for (var i = 0; i < els.length; i++) out = out.concat(prices(els[i].textContent || ''));
    return out;
  }

  function parseCard(card) {
    var lines = linesOf(card);
    var struck = struckPrices(card);
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
        if (LEGAL_RE.test(l)) {
          // "Niedrigster Preis der letzten 30 Tage: 3,29 €" ist kein Angebotspreis
          if (original === null) original = ps[ps.length - 1];
        } else if (UNIT_RE.test(l)) {
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

    // Durchgestrichene Werte sind Streichpreise, nie der aktuelle Preis
    if (struck.length > 0) {
      var rest = current.filter(function (p) { return struck.indexOf(p) < 0; });
      if (rest.length > 0) {
        current = rest;
        original = Math.max.apply(null, struck);
      }
    }
    // Überschrift oder Titel-Element schlägt die längste Textzeile
    var head = card.querySelector('h1, h2, h3, h4, h5, [class*="title"], [class*="name"], [data-testid*="title"]');
    var headText = head ? (head.textContent || '').replace(/\s+/g, ' ').trim() : '';
    if (headText && lettersCount(headText) >= 3 && prices(headText).length === 0 && headText.length <= 140) title = headText;
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

  function isoDate(d) { return d.getUTCFullYear() + '-' + pad(d.getUTCMonth() + 1) + '-' + pad(d.getUTCDate()); }

  // Montag bis Samstag der ISO-Kalenderwoche ("2026/48")
  function weekRange(spec) {
    var m = /^(\d{4})\/(\d{1,2})$/.exec(spec || '');
    if (!m) return null;
    var year = parseInt(m[1], 10);
    var week = parseInt(m[2], 10);
    var jan4 = new Date(Date.UTC(year, 0, 4));
    var monday = new Date(jan4.getTime() - ((jan4.getUTCDay() + 6) % 7) * 86400000 + (week - 1) * 7 * 86400000);
    var saturday = new Date(monday.getTime() + 5 * 86400000);
    return { from: isoDate(monday), to: isoDate(saturday), guessed: false };
  }

  // REWE: Angebotskacheln tragen Titel und Preise strukturiert im Link
  // ("Kinder Country, 1,99 € statt 3,29 €" / "…, Aktionspreis 1,77 € +0,50 € REWE Bonus Guthaben").
  function reweOffers() {
    var tiles = document.querySelectorAll('article.cor-offer-renderer-tile');
    if (tiles.length === 0) return null;
    var out = [];
    var week = null;
    for (var i = 0; i < tiles.length; i++) {
      var tile = tiles[i];
      var link = tile.querySelector('[data-offer-title]');
      if (!link) continue;
      var title = (link.getAttribute('data-offer-title') || '').trim();
      var label = link.getAttribute('aria-label') || '';
      if (!title) continue;
      week = week || link.getAttribute('data-offer-week');
      var rest = label.indexOf(title) === 0 ? label.slice(title.length) : label;
      var bonusIdx = rest.search(/\+\s*\d/);
      var bonus = bonusIdx >= 0 ? rest.slice(bonusIdx).replace(/^\+\s*/, '+').trim() : null;
      var pricePart = bonusIdx >= 0 ? rest.slice(0, bonusIdx) : rest;
      var sIdx = pricePart.search(/statt/i);
      var cur = prices(sIdx >= 0 ? pricePart.slice(0, sIdx) : pricePart);
      var orig = sIdx >= 0 ? prices(pricePart.slice(sIdx)) : [];
      if (cur.length === 0) continue; // nur Bonus-Guthaben, kein Preis
      var adds = tile.querySelectorAll('.cor-offer-information__additional');
      var info = [];
      for (var k = 0; k < adds.length; k++) {
        var a = (adds[k].textContent || '').replace(/^\s*,\s*/, '').trim();
        if (a) info.push(a);
      }
      if (/\bab\s+\d/.test(pricePart)) info.unshift('ab-Preis, je nach Sorte');
      if (bonus) info.push(bonus);
      var price = cur[0];
      var original = orig.length > 0 && orig[0] > price ? orig[0] : null;
      out.push({
        el: tile,
        offer: {
          title: title,
          price_cents: price,
          original_price_cents: original,
          discount_percent: original ? Math.round((1 - price / original) * 100) : null,
          unit_info: info.length > 0 ? info.join(', ') : null,
          source_id: link.getAttribute('data-offer-nan') || null
        }
      });
    }
    return { items: out, validity: weekRange(week) };
  }

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

    var now = TEST && TEST.now ? new Date(TEST.now) : new Date();
    var offers = [];
    var seen = {};
    var v = null;
    function add(o, el) {
      var key = o.source_id || (o.title + '|' + o.price_cents);
      if (seen[key] || offers.length >= MAX_OFFERS) return;
      seen[key] = true;
      offers.push(o);
      if (!TEST && el) el.style.outline = '2px solid #059669';
    }

    var special = chain === 'rewe' ? reweOffers() : null;
    if (special && special.items.length > 0) {
      special.items.forEach(function (it) { add(it.offer, it.el); });
      v = special.validity;
    } else {
      genericOffers().forEach(function (it) { add(it.offer, it.el); });
    }
    v = v || validity(document.body.innerText || document.body.textContent || '', now);
    return finish(chain, now, v, offers);
  }

  // Allgemeine Erkennung über Preisangaben, für Seiten ohne eigene Regel.
  function genericOffers() {
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

    var out = [];
    cards.forEach(function (c) {
      var o = parseCard(c);
      if (o) out.push({ el: c, offer: o });
    });
    return out;
  }

  function finish(chain, now, v, offers) {
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
