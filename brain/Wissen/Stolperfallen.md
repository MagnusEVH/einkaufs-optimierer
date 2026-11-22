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
