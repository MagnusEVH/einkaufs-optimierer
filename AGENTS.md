# AGENTS.md – Einkaufs-Optimierer Projekt-Leitfaden

Dieser Leitfaden dient als verbindliche Orientierung für alle KI-Agenten (Claude Code, Antigravity/Gemini u. a.), um unnötige Datei-Scans zu vermeiden und Änderungen direkt zielgerichtet umzusetzen.

**Single Source of Truth:** `AGENTS.md` gilt für alle Agenten. Die Antigravity-Regel [.agents/rules/plan_on_complex_prompts.md](.agents/rules/plan_on_complex_prompts.md) verweist hierher und darf ihr nicht widersprechen. Es gibt (noch) keine `GEMINI.md`/`CLAUDE.md`; falls ein Tool eine eigene Datei verlangt, nur auf `AGENTS.md` verweisen, keine Regeln duplizieren.

---

## ⚡ Wichtigste Arbeitsregel: Automatische Plan-Erstellung bei komplexen Prompts

Wenn ein Prompt **komplex** ist (definiert als: betrifft mehr als 1 Datei, erfordert neue Datenmodelle, Architektur-Entscheidungen, neue API-Endpunkte, Refactoring oder State-Management-Änderungen), gilt ausnahmslos:

1. **Keine voreiligen Code-Edits durchführen.**
2. **Zuerst einen kompakten Umsetzungsplan vorlegen:**
   - **Ziel:** 1–2 Sätze zur beabsichtigten Lösung.
   - **Betroffene Dateien:** Exakte Auflistung der Dateien, die gelesen/geändert werden (inkl. Markdown-Links).
   - **Geplante Schritte:** Nummerierte Stichpunkte der konkreten Änderungen.
   - **Offene Fragen / Risiken:** Falls Unklarheiten oder Seiteneffekte bestehen.
3. Erst nach Vorlage des Plans (oder bei klarem Auftrag im selben Schritt geordnet nach Plan) die Dateien punktgenau editieren.

---

## 🗺️ Projekt-Architektur & Dateizuordnung

Das Projekt ist ein **Einkaufs-Optimierer für den deutschen Lebensmittel- und Drogeriemarkt** (Lidl, Aldi Süd, Rewe, Netto, DM, Rossmann) mit Multi-Store-Routing, Coupon-Wallet und Supabase/PostGIS-Backend.

### 1. Flutter Frontend (`app/lib/`)
*Framework: Flutter 3, State Management: `flutter_riverpod`, Theme: Material 3 Emerald/Slate.*

| Feature / Ordner | Zuständige Dateien | Zweck & Inhalt |
| :--- | :--- | :--- |
| **Shopping List** | `app/lib/features/shopping_list/shopping_list_screen.dart`<br>`app/lib/features/shopping_list/shopping_list_controller.dart` | Einkaufsliste, Schnellauswahl aus Katalog, Mengenanpassung |
| **Optimizer Engine UI** | `app/lib/features/optimizer/optimizer_screen.dart` | Ergebnisansicht für Single-Store vs. Split-Store (Multi-Shop-Optimierung) |
| **Stores & Karte** | `app/lib/features/stores_map/stores_screen.dart` | Filialanzeige, Radius-Suche, PostGIS-Clustering-Darstellung |
| **Wallet & Coupons** | `app/lib/features/wallet/wallet_screen.dart` | Treuekarten (Lidl Plus, Payback etc.), Coupon-Tresor, Ersparnisanzeige |
| **Preismeldungen** | `app/lib/features/price_reports/price_report_screen.dart` | Community-Preismeldungen, Quittungs- und Bon-Upload |
| **Settings** | `app/lib/features/settings/settings_screen.dart` | Store-Präferenzen, Umkreis-Filter, Transportmittel (Auto/Fahrrad/Fuß) |
| **Core Models** | `app/lib/core/models/` | `product.dart`, `list_item.dart`, `store.dart`, `optimization_result.dart`, `loyalty_wallet.dart`, `user_preferences.dart` |
| **Core Services** | `app/lib/core/services/` | `catalog_service.dart` (Katalog & Cache)<br>`optimizer_service.dart` (Optimierungs-Algorithmus)<br>`supabase_service.dart` (Supabase Client & Offline-Fallback)<br>`wallet_service.dart` (Karten & Coupons)<br>`location_service.dart` (Geolocator) |
| **Config** | `app/lib/core/config/app_config.dart` | Kachel-URLs, Carto-Key (`--dart-define=CARTO_API_KEY`) |
| **Weitere Services** | `app/lib/core/services/` | `preferences_storage.dart`, `notification_service.dart`, `analytics_service.dart` |
| **Weitere Screens** | `app/lib/features/` | `onboarding/`, `profile/`, `my_apps/` (Meine Apps Hub), `admin/` (Developer Cockpit), `shopping_list/post_shopping_summary_dialog.dart` |
| **App Entry** | `app/lib/main.dart` | Theme, ProviderScope, NavigationBar mit 5 Tabs (Einkaufsliste, Karte, Meine Apps, Angebote, Profil) |

### 2. Backend & Datenbank (`supabase/`)
*PostgreSQL mit PostGIS-Erweiterung, Row Level Security (RLS) und RPC-Funktionen.*

| Ordner / Datei | Zweck |
| :--- | :--- |
| `supabase/migrations/20261018000001_initial_schema.sql` | Grundtabellen (`stores`, `products`, `prices`, PostGIS-Geometrien) |
| `supabase/migrations/20261018000002_rls_and_functions.sql` | RPC-Funktionen (z. B. Umkreissuche `get_stores_in_radius`) & RLS |
| `supabase/migrations/20261018000003_seed_catalog_250.sql` | 250 Basis-Produkte mit EANs und Kategorien |
| `supabase/migrations/20261018000005_phase2_preferences_and_reports.sql` | Tabellen für Preis-Reports und Nutzer-Präferenzen |
| `supabase/migrations/20261018000004_seed_test_stores.sql` | Test-Filialen |
| `supabase/migrations/20261018000006_phase3_offers_and_wallet.sql` | Angebote, Treuekarten & aktivierte Coupons |
| `supabase/migrations/20261018000007_phase3_analytics_and_history.sql` | Analytics & Einkaufshistorie |
| `supabase/functions/{optimize-route,import-catalog,places-proxy}/index.ts` | Edge Functions (Deno/TypeScript) |

### 3. Scrapers & Normalizer (`scrapers/`)
*Node.js basierte Web- & API-Scraper für Discounter und Supermärkte.*

| Datei / Ordner | Zweck |
| :--- | :--- |
| `scrapers/connectors/aldi_sued_scraper.js` | Aldi Süd Angebote & Preise |
| `scrapers/connectors/lidl_scraper.js` | Lidl Sortiment & Aktionspreise |
| `scrapers/connectors/rewe_scraper.js` | Rewe Filialpreise & Angebote |
| `scrapers/connectors/dm_scraper.js` | DM Drogerie Markt |
| `scrapers/connectors/rossmann_scraper.js` | Rossmann Drogerie |
| `scrapers/connectors/netto_scraper.js` | Netto Marken-Discount |
| `scrapers/normalizer.js` | Mengeneinheiten-Harmonisierung (€/kg, €/l) |
| `scrapers/vault_service.js` | Speicherung und Validierung von Coupon-Payloads |
| `scrapers/base_scraper.js` | Basisklasse (`safeFetch`, Promo-Gültigkeitsdaten) |
| `scrapers/run_rlp_scraping.js` | Master-Runner (Bingen 55411 / Oberwesel 55430), schreibt `app/assets/live_scraped_offers_rlp.json` **und** `test_data/…` |
| `scrapers/price_quality_monitor.js` | Preisqualitäts-Check |

### 4. Tests (`backend_tests/`)
*Automatisierte Tests zur Validierung der Optimierungs- und Scraping-Logik.*
* `backend_tests/test_optimization_engine.js`: Prüft Single- vs. Multi-Store Algorithmus.
* `backend_tests/test_clustering.js`: Prüft PostGIS Distanz- und Filial-Clustering.
* Weitere: `test_catalog_integrity.js`, `test_phase2_preferences.js`, `test_phase3_offers_and_wallet.js`, `test_stufe_b_scraping_and_vault.js`.
* Flutter: `app/test/widget_test.dart`.

### 5. Sonstiges
* `web_dashboard/index.html` – statisches Dashboard; `generator_seed_250.js` – erzeugt `test_data/products_seed_250.json`.
* `.github/workflows/deploy_gh_pages.yml` – Flutter-Web-Build & Deploy auf GitHub Pages (Push auf `main`/`master`).
* `test_data/` und `app/assets/` enthalten **gespiegelte** JSON-Dateien (Seed, Stores, Offers) – bei Änderung beide synchron halten.

---

## 🚀 Direktanweisungen für Agenten (Efficiency Rules)

1. **Kein globales Durchsuchen des Repos:** Wenn der User eine Feature-Anfrage stellt, konsultiere obige Tabelle und navigiere direkt zur zuständigen Datei.
2. **Targeted Edits:** Verwende immer `replace_file_content` oder `multi_replace_file_content` mit exakten Zeilenbereichen, niemals unbedacht ganze Dateien neu schreiben.
3. **Typensicherheit:** Bei Änderungen an Datenmodellen in `app/lib/core/models/` immer prüfen, ob `toJson()` / `fromJson()` und die Provider in `app/lib/core/services/` synchron bleiben.

---

## 🔧 Build-, Test- & Run-Befehle

| Zweck | Befehl |
| :--- | :--- |
| Backend-Tests (Node, keine Dependencies/`package.json`) | `for t in backend_tests/*.js; do node "$t" || exit 1; done` |
| Einzelnen Test | `node backend_tests/test_optimization_engine.js` |
| Scraper-Pipeline (RLP) | `node scrapers/run_rlp_scraping.js` |
| Scraper-Runner mit eigenem Ausgabeordner | `runScrapingPipeline({ outputDirs: [dir] })` (Tests nutzen `os.tmpdir()`) |
| Seed neu erzeugen | `node generator_seed_250.js` (danach nach `app/assets/` spiegeln) |
| Flutter-Deps | `cd app && flutter pub get` |
| Flutter-Analyse / Tests | `cd app && flutter analyze && flutter test` |
| Lokal starten (Web) | `cd app && flutter run -d chrome --dart-define=CARTO_API_KEY=<key>` |
| Web-Release (wie CI) | `cd app && flutter build web --release --base-href "/<repo>/"` |

Vor jedem Abschluss: Backend-Tests ausführen; bei Dart-Änderungen zusätzlich `flutter analyze` + `flutter test` (sofern Flutter installiert ist, sonst im Bericht vermerken).

## 🔑 Konfiguration (Build-Variablen)

| Variable | Pflicht | Verwendung |
| :--- | :--- | :--- |
| `CARTO_API_KEY` | optional | Carto-Basemap-Key, **nur** per `--dart-define=CARTO_API_KEY=<key>` (lokal) bzw. GitHub-Repository-Secret `CARTO_API_KEY` (CI). Ohne Key nutzt die Karte OpenStreetMap-Kacheln. Niemals im Quellcode, in `.env`-Dateien im Repo oder in Commits ablegen. Hinweis: Bei Flutter Web ist der Key im ausgelieferten Bundle sichtbar – bei Carto auf die Domain beschränken. |

## 📐 Konventionen

* **Sprache:** UI-Texte und Doku auf Deutsch; Code, Bezeichner und Commit-Typen auf Englisch (Conventional Commits: `feat(scope):`, `fix(scope):`).
* **Geld:** Preise intern als Integer-Cent (`price_cents`), Umrechnung nur in der Anzeige.
* **Ketten-IDs:** klein geschrieben (`lidl`, `aldi_sued`, `rewe`, `netto`, `dm`, `rossmann`).
* **Scraper:** je Kette ein Connector, erbt von `BaseScraper`; Live-Abruf via `safeFetch` mit Fallback auf kuratierte Daten; Einheiten nur über `normalizer.js`.
* **Migrationen:** nur neue, fortlaufend nummerierte Dateien (`2026…_NNNNNN_name.sql`) anlegen; bestehende nie ändern. Neue Tabellen immer mit RLS.
* **Flutter:** State via Riverpod, Material 3; ohne Supabase-Credentials läuft die App im Demo-Modus (`SupabaseService.isDemoMode`) – neue Features müssen offline/demo funktionieren.
* **Testläufe & Fixtures:** Tests dürfen eingecheckte Dateien in `app/assets/` oder `test_data/` nicht überschreiben. Generieren Tests Daten, in einen temporären Ordner schreiben oder nach dem Lauf per `git checkout -- <datei>` zurücksetzen. Vor dem Commit `git status` prüfen.
* **Secrets:** niemals im Quellcode oder Git. Nur per `--dart-define` bzw. `.env` (gitignored).

## 📊 Projektstatus (Stand 2026-11-22)

**Umgesetzt:** Phase 1 (Schema, 250er-Katalog, Edge Functions, Optimizer, Flutter-App) · Phase 2 (Kategorie-Präferenzen, Eigenmarken-Regeln, Preismeldungen) · Phase 3 (Wochenangebote mit Gültigkeit, Wallet/Coupons, Analytics, Onboarding, Meine Apps, Developer Cockpit, Push-Engine) · Stufe B (RLP-Fokus Bingen/Oberwesel, 6 Ketten, Credential-Vault) · Karte mit CartoDB-Tiles · GitHub-Pages-Deploy. Alle 6 Backend-Test-Skripte laufen grün.

**Baustellen / bekannte Lücken:**
1. Scraper liefern faktisch **statische Beispieldaten**; Live-Endpunkte (z. B. Lidl-Flyer) werden nur angefragt, aber nicht ausgewertet.
2. ~~Carto-Key im Quellcode~~ – entfernt (nur noch `--dart-define`). Der alte Key steht noch in der Git-Historie → bei Carto rotieren und als Secret `CARTO_API_KEY` hinterlegen.
3. Supabase ist im Standard nicht angebunden (Demo-Modus); Migrationen/Edge Functions sind nicht gegen eine echte Instanz verifiziert.
4. Flutter-Tests: nur ein Widget-Test; keine Tests für Optimizer-Service/Wallet in Dart (Tests liegen nur als JS-Logik-Spiegel).
5. Doppelte Datenhaltung `test_data/` ↔ `app/assets/`; `app/README.md` ist noch Flutter-Boilerplate; `pubspec.lock` ist getrackt, obwohl in `.gitignore`.
6. `stores_screen.dart` (~1600 Zeilen) ist ein Refactoring-Kandidat; Google-Maps/Android/iOS-Build noch nicht aktiv (nur Web/PWA).
7. ~~Kein CI für Tests~~ – Workflow führt Backend-Tests + `flutter test` vor dem Deploy aus (`needs: test`). `flutter analyze` ist bewusst noch **nicht** im Gate (bestehende Warnungen), Flutter-Version ist nicht fixiert (`stable`).
