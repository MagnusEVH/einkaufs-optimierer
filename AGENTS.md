# AGENTS.md – Einkaufs-Optimierer Projekt-Leitfaden

Dieser Leitfaden dient als verbindliche Orientierung für alle KI-Agenten, um unnötige Datei-Scans zu vermeiden und Änderungen direkt zielgerichtet umzusetzen.

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
| **App Entry** | `app/lib/main.dart` | Theme, ProviderScope, NavigationBar mit 5 Tabs |

### 2. Backend & Datenbank (`supabase/`)
*PostgreSQL mit PostGIS-Erweiterung, Row Level Security (RLS) und RPC-Funktionen.*

| Ordner / Datei | Zweck |
| :--- | :--- |
| `supabase/migrations/20261018000001_initial_schema.sql` | Grundtabellen (`stores`, `products`, `prices`, PostGIS-Geometrien) |
| `supabase/migrations/20261018000002_rls_and_functions.sql` | RPC-Funktionen (z. B. Umkreissuche `get_stores_in_radius`) & RLS |
| `supabase/migrations/20261018000003_seed_catalog_250.sql` | 250 Basis-Produkte mit EANs und Kategorien |
| `supabase/migrations/20261018000005_phase2_preferences_and_reports.sql` | Tabellen für Preis-Reports und Nutzer-Präferenzen |
| `supabase/migrations/20261018000006_phase3_offers_and_wallet.sql` | Angebote, Treuekarten & aktivierte Coupons |

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

### 4. Tests (`backend_tests/`)
*Automatisierte Tests zur Validierung der Optimierungs- und Scraping-Logik.*
* `backend_tests/test_optimization_engine.js`: Prüft Single- vs. Multi-Store Algorithmus.
* `backend_tests/test_clustering.js`: Prüft PostGIS Distanz- und Filial-Clustering.

---

## 🚀 Direktanweisungen für Agenten (Efficiency Rules)

1. **Kein globales Durchsuchen des Repos:** Wenn der User eine Feature-Anfrage stellt, konsultiere obige Tabelle und navigiere direkt zur zuständigen Datei.
2. **Targeted Edits:** Verwende immer `replace_file_content` oder `multi_replace_file_content` mit exakten Zeilenbereichen, niemals unbedacht ganze Dateien neu schreiben.
3. **Typensicherheit:** Bei Änderungen an Datenmodellen in `app/lib/core/models/` immer prüfen, ob `toJson()` / `fromJson()` und die Provider in `app/lib/core/services/` synchron bleiben.
