---
type: entscheidung
status: gilt
datum: 2026-11-23
tags: [entscheidung]
---
# Echte Preise per Übernehmen-Knopf statt Scraper

**Kontext:** Echte Preise sollten per Scraping kommen. Prüfung am 2026-11-23: ALDI SÜD und Netto blocken automatische Abrufe (Bot-Schutz, 403), die dm-Such-API ist per `robots.txt` komplett gesperrt, REWE-Angebotsseiten sind bot-geschützt, Lidl- und Rossmann-Preise werden erst im Browser gerendert.

**Entscheidung:** Keine Scraper, die `robots.txt` oder Bot-Schutz umgehen, auch keine Browser-Automation mit Konto. Stattdessen ein Bookmarklet ([extract.js](../../app/web/uebernehmen/extract.js)): Der Nutzer öffnet die Angebotsseite selbst, ein Klick liest nur diese Seite und übergibt die Daten per URL-Fragment an die App. Ergänzend später Bon-Scan und Open Prices.

**Folgen:**
- Daten bleiben im Browser des Nutzers (Fragment geht an keinen Server), nichts landet im öffentlichen Repo.
- Funktioniert für jede Kette, deren Seite der Nutzer im Browser sieht; Erkennung ist heuristisch, deshalb Vorschau mit Abhaken.
- `scrapers/` liefert weiter nur Beispieldaten.
