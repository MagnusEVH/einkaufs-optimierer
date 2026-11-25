/*
 * Guthaben-Leser für den Einkaufs-Optimierer.
 *
 * Liest aus dem Text eines Screenshots (Texterkennung) den Stand eines
 * Treueprogramms: Euro-Guthaben (REWE Bonus) oder Punkte (PAYBACK).
 * Reine Funktion ohne Seiteneffekte, im Browser (konto.html) und in Node-Tests.
 */
(function (root) {
  'use strict';

  var EURO_KEY = /(guthaben|bonus|gespart|kontostand)/i;
  var POINT_KEY = /(punktestand|punkte|°\s*p\b|pkt)/i;

  // OCR verwechselt gern Buchstaben mit Ziffern: "l2,34", "O,50"
  function fixDigits(s) {
    return s.replace(/([0-9lIO]{1,4})[.,]([0-9lIO]{2})(?=\s*(€|eur|$|\s))/gi, function (m, a, b) {
      var f = function (x) { return x.replace(/[lI]/g, '1').replace(/O/g, '0'); };
      return f(a) + ',' + f(b);
    });
  }

  function euroIn(l) {
    var m = /(\d{1,4}(?:\.\d{3})*)[.,](\d{2})\s*(€|eur)/i.exec(l) || /(€|eur)\s*(\d{1,4}(?:\.\d{3})*)[.,](\d{2})/i.exec(l);
    if (!m) return null;
    var whole = m[1] && /\d/.test(m[1]) ? m[1] : m[2];
    var dec = m[1] && /\d/.test(m[1]) ? m[2] : m[3];
    return parseInt(whole.replace(/\./g, ''), 10) * 100 + parseInt(dec, 10);
  }

  function pointsIn(l) {
    var m = /(\d{1,3}(?:[.\s]\d{3})+|\d+)\s*(?:°\s*p\b|punkte|pkt|p\b)/i.exec(l);
    return m ? parseInt(m[1].replace(/[.\s]/g, ''), 10) : null;
  }

  /**
   * @param {string} text erkannter Text
   * @param {'euro'|'points'} kind was gesucht wird
   * @returns {{value_cents?: number, points?: number, line: string} | null}
   */
  function parseBalance(text, kind) {
    var lines = fixDigits(String(text || '').replace(/\r/g, ''))
      .split('\n').map(function (l) { return l.replace(/\s+/g, ' ').trim(); }).filter(Boolean);
    var key = kind === 'points' ? POINT_KEY : EURO_KEY;
    var read = kind === 'points' ? pointsIn : euroIn;

    // 1. Zahl in der Zeile mit dem Stichwort oder in den zwei Zeilen danach
    for (var i = 0; i < lines.length; i++) {
      if (!key.test(lines[i])) continue;
      for (var k = i; k < Math.min(i + 3, lines.length); k++) {
        var v = read(lines[k]);
        if (v !== null) return kind === 'points' ? { points: v, line: lines[k] } : { value_cents: v, line: lines[k] };
      }
    }
    // 2. Punkte ohne Stichwort: erste Zahl mit °P
    if (kind === 'points') {
      for (var j = 0; j < lines.length; j++) {
        var m = /(\d{1,3}(?:[.\s]\d{3})+|\d+)\s*°\s*p\b/i.exec(lines[j]);
        if (m) return { points: parseInt(m[1].replace(/[.\s]/g, ''), 10), line: lines[j] };
      }
    }
    return null;
  }

  var api = { parseBalance: parseBalance };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.KontoParser = api;
})(this);
