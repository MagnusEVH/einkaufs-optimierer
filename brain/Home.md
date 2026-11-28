---
type: home
aktualisiert: 2026-11-25
---
# 🧠 Einkaufs-Optimierer – Zweites Gehirn

Einstieg für Nutzer und Agenten. Regeln: [AGENTS.md](../AGENTS.md) · Ablauf: [[Arbeitsablauf]]

## Aktueller Stand
- `main` ist grün und live auf GitHub Pages (Deploy-Lauf #28).
- App läuft im **Demo-Modus** (ohne Supabase).
- Texte als Demo gekennzeichnet, Kartenlizenz-Hinweis da, Cockpit nur im Debug-Build (PR #11, gemergt).
- Optimierer rechnet korrekt (Umkreis, Fahrtkosten, keine Pauschalpreise), Review-Sonden als Tests, Rückfrage bei Freitext, Liste und Einstellungen werden gespeichert (PR #12, gemergt).
- Echte Angebote per Übernehmen-Knopf (`uebernehmen.html`): REWE mit eigener Regel (444/444 richtig), dm mit eigener Regel (89/89 an gespeicherter Seite), Lidl über kaufDA nicht möglich (Prospekt nur Bilder), andere Ketten allgemein und ungeprüft. Neuer Import ersetzt alte Fehler.
- Speichern im Browser repariert (PR #14, gemergt).
- Wochenrunde im Angebote-Tab, Bon-Scan (`bon.html`, Texterkennung im Browser), Bonpreise ersetzen Katalogpreise (PR #15, gemergt).
- Benutzerreise neu: Liste mit Icons, Planung mit Vorschlägen, Einkaufsmodus, Meine Märkte, Meine Apps mit App öffnen und Guthaben-Scan. PR #16, gemergt.
- Feinschliff: WebAssembly, Cache-Worker, ein Onboarding-Bildschirm, Guthaben-Scan direkt in der App. PR #17, gemergt.
- Design-Pass nach unslop: warme Neutrale, ruhige Schrift, Abschluss als Kassenbon. PR #18, gemergt.
- REWE-eBon (PDF) einlesen (PR #20/#24), dm-Regel für den Übernehmen-Knopf (PR #21/#25), Kerrygold-Zuordnung (PR #22), Unslop-Polish nach Screenshot-Audit (PR #23), alle gemergt.
- Konten und Haushalte: neues Supabase-Schema mit 24 RLS-Tests (PGlite in der CI), noch nicht eingespielt. PR #26.
- Suche 2: Eier zuerst, Gewohnheit als Gleichstand, Cache liefert neue Version sofort (PR #29).
- Stufe 3a Konto: Anmelden, Registrieren mit Code, Passwort vergessen, Konto löschen. Migrationen live, App bleibt bis 3c lokal (PR #30).
- Stufe 3b Haushalte: Auswahl im Listentitel, Gruppen, Einladungscodes, Rollen (PR #31).
- Stufe 3c Abgleich: gemeinsame Liste je Haushalt, offline-Warteschlange, Realtime (PR #32).
- Mail-Links zeigen auf die App statt auf die 404 (Branch `claude/mail-link-ziel`).
- Letzte Session: [[2026-11-28 Mail-Link 404]]

## Offene Baustellen
- [[Supabase-Anbindung]] – hoch, in Arbeit (Schema live, 3a–3c fertig, Live-Schaltung offen)
- [[Carto-Key-Rotation]] – hoch, Aufgabe für den Nutzer
- [[Live-Scraper]] – ersetzt durch Übernehmen-Knopf
- [[CI-Analyze-Gate]] – niedrig
- [[Mobile-Builds]] – niedrig

Alle Baustellen, Entscheidungen und Sessions als Tabelle: [[Übersicht.base|Übersicht]]

## Wissen
- [[Architektur]] · [[Stolperfallen]] · [[Arbeitsablauf]]

## Ordner
`Baustellen/` · `Entscheidungen/` · `Sessions/` · `Wissen/` · `_Vorlagen/`
