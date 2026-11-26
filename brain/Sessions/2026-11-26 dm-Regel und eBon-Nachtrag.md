---
type: session
datum: 2026-11-26
agent: Claude Code (Opus 5.5)
prs: [20]
tags: [session]
---
# 2026-11-26 – dm-Regel und eBon-Nachtrag

## Erledigt
- eBon-Commit (kam erst nach dem Merge von #17) auf den Stand nach #18 übertragen, Konflikte zugunsten des neuen Designs gelöst, Knöpfe ohne Emoji. PR #20, ersetzt #19. Unabhängig geprüft (Sub-Agent): freigegeben.
- Datenschutz-Satz auf `bon.html` nennt jsDelivr als Quelle der Lese-Programme.
- Übernehmen-Knopf: eigene dm-Regel (`dmOffers` in `app/web/uebernehmen/extract.js`), liest die Kachel-Beschriftung. An gespeicherter "Neu bei dm"-Seite 89/89 mit Marke, vollem Namen, Preis, Grundpreis. Test `backend_tests/test_uebernehmen_dm.js` mit nachgebauten Kacheln.
- Lidl über kaufDA geprüft: Prospekt besteht nur aus Bildern, kein Preistext → mit dem Knopf nicht machbar.

## Offen
- ALDI, Netto, Rossmann: gespeicherte Angebotsseiten fehlen noch.
- dm-Seiten mit echten Rabatten (Statt-Preis) ungeprüft, die Regel liest ein Feld mit "statt/UVP/vorher" als Originalpreis.
- dm-Kacheln tragen die EAN (`data-gtin`), wird noch nicht übernommen (nützlich für Katalog mit echten EAN).

## Gelernt
- Siehe [[Stolperfallen]]: gespeicherte Händlerseiten nur ohne ihre Skripte testen.
