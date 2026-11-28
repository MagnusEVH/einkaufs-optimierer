---
type: wissen
aktualisiert: 2026-11-22
tags: [wissen, stolperfalle]
---
# Stolperfallen

- **`$$` in JavaScripts `String.replace`** wird zu `$` → SQL-Funktionsrümpfe (`as $$`) gehen kaputt, wenn man Migrationen per Skript ersetzt. Ersatz als Funktion übergeben (`s.replace(a, () => b)`) oder mit dem Edit-Werkzeug ändern.
- **`raise exception` in Postgres-Funktionen** rollt alles in der Transaktion zurück, auch eingetragene Fehlversuche → Fehlversuch speichern und `null` zurückgeben, nicht werfen (`accept_invitation`).
- **Flutter Web in Cloud-Sessions:** Canvaskit kommt standardmäßig von `gstatic.com`, das hier blockiert ist → `flutter build web --no-web-resources-cdn`.
- **Schriftgewicht 600 im Web** wird künstlich fett gerendert (die Schrift hat keinen 600-Schnitt) und wirkt wie 700 → im Theme 400/500 nutzen.
- **Flutter ist in Cloud-Sessions nicht vorinstalliert:** SDK-Tarball von `storage.googleapis.com` laden (erreichbar), in den Scratchpad entpacken.
- **`flutter pub get` ändert `pubspec.lock`** (neuere Flutter-Version) → vor dem Commit zurücksetzen, falls nicht gewollt.
- **GitHub Pages Re-run:** früher „Multiple artifacts named github-pages“ – behoben, siehe [[Pages-Deploy in eigenem Job]].
- **PR-Check „1/2“** ist normal: bei PRs läuft nur `test`, Deploy wird übersprungen.
- **`WalletService` hält statischen Zustand** → Tests in `wallet_service_test.dart` sind reihenfolgeabhängig.
- **ListTile in dekoriertem Container** wirft im Test eine Assertion → `Material` statt `Container` als Hintergrund.
- **Branches bauen aufeinander auf**, wenn mehrere `AGENTS.md` ändern → Merge-Reihenfolge beachten.
- **CRLF-Zeilenenden** in einigen Dart-Dateien → mehrzeilige Ersetzungen per Skript schlagen fehl, dort gezielt editieren.
- **Angebotspreis über Katalogpreis** in `live_scraped_offers_rlp.json` (z. B. REWE Spaghetti) → Optimierer nimmt den niedrigeren Preis; Tests nur mit echten Rabatten.
- **Optimierer ändert Freitext-Zuordnung**: `matchedProduct` wird mit Bio-/Marken-Präferenz neu ermittelt, Fallback ist das gespeicherte Produkt.
- **`flutter_secure_storage` im Web** verliert Daten, wenn beim ersten Start parallel geschrieben wird (Schlüssel ohne Sperre) → App-Daten liegen in `shared_preferences`. Im Test `SharedPreferences.setMockInitialValues({})` + `PreferencesStorage.simulateReload()`.
- **Git Bash und `--base-href`**: MSYS macht aus `/einkaufs-optimierer/` einen Windows-Pfad → `MSYS_NO_PATHCONV=1 flutter build web …`.
- **Bookmarklet-Platzhalter** `__APP_URL__` steht auch im Kommentar → in `uebernehmen.html` `replaceAll` nutzen.
- **Gespeicherte Händlerseiten in Headless-Chrome** hängen bei `--dump-dom`, weil Bilder und CSS von den (bot-geschützten) Händler-Servern nachgeladen werden → externe URLs vor dem Test entfernen. Echte Händlerseiten nie ins Repo, nur nachgebaute Fixtures.
- **CRLF in `extract.js` und Dart-Dateien**: Skript-Ersetzungen vorher auf 
 normalisieren und danach zurückwandeln.
- **Standortabfrage im Browser** kann ewig auf die Freigabe warten → `LocationService.getCurrentLocation` hat 12 s Zeitgrenze. Widget-Tests deshalb am Ende `tester.pump(Duration(seconds: 13))`.
- **Nur `#…` ändern lädt Flutter nicht neu** → Import-Links (`#import=`) beim Testen von einer anderen Seite aus öffnen.
- **Gespeicherte Händlerseiten testen**: vorher alle `<script>` entfernen (fremder Code), dann `extract.js` mit `__UEBERNEHMEN_TEST__` einsetzen. kaufDA-Prospekte sind nur Bilder, dort findet der Knopf nichts. dm-Kacheln: Text in `[data-dmid="product-tile"] span` (Marke getrennt), sichtbarer Text klebt Marke und Name zusammen.
- **Regex-Backslashes in Node-Einzeilern/Heredocs** gingen beim Einfügen verloren → Regex-Blöcke als Datei schreiben und einfügen, danach Parser-Tests laufen lassen.
- **WebAssembly-Build** bricht bei Paketen mit `dart:html`/`package:js` ab (z. B. `flutter_secure_storage` 9) → `flutter build web --wasm` nach neuen Paketen prüfen.
- **Service Worker** liegt in `app/web/sw.js`; Cache-Name `eo-v1` bei Änderungen an der Cache-Strategie hochzählen. `web/flutter_bootstrap.js` ist eine eigene Vorlage (ohne Flutters Service Worker).
- **Backslashes in Shell-Heredocs** gehen über das Agenten-Werkzeug verloren (Regex, `\n` in JS) → Skripte mit Regex als Datei schreiben (Write) und dann mit `node datei.js` ausführen.

## Service Worker und Flutter-Programm (2026-11-27)
`main.dart.wasm`/`main.dart.js` haben keine Version in der URL. Mit stale-while-revalidate läuft nach einem Deploy noch die alte App (so blieb die alte Suche nach PR #28). Eigene Dateien daher network-first, nur versionierte CDN-URLs cache-first.

## Supabase-Mails und iPhone-PWA (2026-11-27)
- Mail-Vorlagen lassen sich erst mit eigenem SMTP ändern. Ohne SMTP enthalten Bestätigungs- und Reset-Mails nur einen Link, keinen 6-stelligen Code.
- Links aus Mails öffnen auf dem iPhone Safari, nicht die Home-Bildschirm-App. Mit PKCE fehlt dort der Schlüssel, der Link scheitert. Deshalb `AuthFlowType.implicit`: Neues Passwort in Safari setzen, dann in der App anmelden. Bestätigungslinks wirken ohnehin auf dem Server.
- Registrierung ohne gültige Einladung liefert von GoTrue nur `unexpected_failure` / "Database error saving new user" (unser Trigger). Die App übersetzt das.

## Git Bash und `--base-href "/"` (2026-11-27)
Git Bash macht aus `/` einen Windows-Pfad (`E:/GIT/Git/`). Mit `MSYS_NO_PATHCONV=1 flutter build web ...` bauen.

## Passwort-Reset-Link und Apple-Schlüsselbund (2026-11-27)
- Der Reset-Link öffnet die App in Safari frisch, also mit Begrüßung davor. Die Abfrage "Neues Passwort" muss auf App-Ebene hängen (`navigatorKey`), nicht an der Hauptansicht.
- Flutter Web und iOS-Schlüsselbund: Felder in eine `AutofillGroup`, E-Mail mit `AutofillHints.username`, nach Erfolg `TextInput.finishAutofillContext()`. Sonst speichert iOS ein vorgeschlagenes Passwort ohne oder mit falschem Namen.

## App hängt beim Laden (2026-11-27)
Ein alter Cache-Worker (vor PR #29, stale-while-revalidate) kann Programmteile verschiedener Versionen mischen, dann bleibt der Ladekreis stehen. Seit PR #35: Nach 15 s erscheint "Zwischenspeicher leeren und neu laden" (meldet Cache-Worker ab, löscht Caches, lokale Daten bleiben). Supabase-Start hat ein Zeitlimit von 8 s.

- **Supabase-Mail-Links → 404:** Ohne `redirectTo` (bzw. wenn es nicht unter Redirect URLs steht) leitet Supabase auf die Site URL. Auf GitHub Pages muss der Repo-Pfad dabei sein (`/einkaufs-optimierer/`). [[2026-11-28 Mail-Link 404]]
