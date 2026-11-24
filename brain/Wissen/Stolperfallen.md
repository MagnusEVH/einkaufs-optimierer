---
type: wissen
aktualisiert: 2026-11-22
tags: [wissen, stolperfalle]
---
# Stolperfallen

- **Flutter Web in Cloud-Sessions:** Canvaskit kommt standardmäßig von `gstatic.com`, das hier blockiert ist → `flutter build web --no-web-resources-cdn`.
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
