---
type: entscheidung
status: gilt
datum: 2026-11-24
tags: [entscheidung]
---
# Bonpreise ersetzen Katalogpreise

**Kontext:** Der Katalog enthält Beispielpreise. Echte Normalpreise einer Filiale stehen auf dem Kassenbon. Ergänzt [[Echte Preise per Uebernehmen-Knopf statt Scraper]].

**Entscheidung:**
- Bon-Scan als eigene Seite [bon.html](../../app/web/bon.html): Texterkennung mit tesseract.js im Browser, das Foto verlässt das Gerät nicht. Der Bon-Leser ([parse.js](../../app/web/bon/parse.js)) ist eine reine Funktion mit Node-Test.
- Ein zugeordneter Bonpreis ersetzt im Optimierer 60 Tage lang den Katalogpreis dieser Kette (`ObservedPriceService`). Angebote gelten weiter, wenn sie günstiger sind.
- Bestätigte Zuordnungen Text → Produkt merkt sich die App (für Bon und Übernehmen-Knopf).
- Ein neuer Angebotsimport ersetzt frühere Übernahmen derselben Kette mit überschneidender Gültigkeit. So verschwinden falsch erkannte Preise beim nächsten Import.

**Folgen:**
- Alles nur lokal (`shared_preferences`), nichts im öffentlichen Repo.
- tesseract.js und deutsche Sprachdaten kommen vom CDN (Version gepinnt), offline geht nur das manuelle Einfügen des Textes.
