/*
 * Guthaben-Scan direkt in der App: Die Flutter-App übergibt die Bild-Adresse
 * (blob:) eines gewählten Screenshots, hier läuft die Texterkennung im Browser
 * (tesseract.js, erst bei Bedarf geladen) und KontoParser liest den Stand.
 * Das Bild verlässt das Gerät nicht.
 *
 * window.eoScanBalance(imageUrl, kind) -> Promise<string|null>
 *   kind: 'euro' | 'points'
 *   Ergebnis: JSON {"value_cents":1279,"line":"…"} oder {"points":1234,…}, sonst null
 */
(function () {
  'use strict';
  var TESSERACT_URL = 'https://cdn.jsdelivr.net/npm/tesseract.js@5.1.1/dist/tesseract.min.js';

  function loadTesseract() {
    if (window.Tesseract) return Promise.resolve(window.Tesseract);
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = TESSERACT_URL;
      s.onload = function () { resolve(window.Tesseract); };
      s.onerror = function () { reject(new Error('Texterkennung konnte nicht geladen werden (Internet nötig)')); };
      document.head.appendChild(s);
    });
  }

  window.eoScanBalance = async function (imageUrl, kind) {
    var T = await loadTesseract();
    var worker = await T.createWorker('deu', 1);
    try {
      var res = await worker.recognize(imageUrl);
      var found = window.KontoParser.parseBalance(res.data.text, kind);
      return found ? JSON.stringify(found) : null;
    } finally {
      await worker.terminate();
    }
  };
})();
