---
type: wissen
aktualisiert: 2026-11-22
tags: [wissen, architektur]
---
# Architektur (Kurzfassung)

- **App:** Flutter Web/PWA, Riverpod, Material 3. 5 Tabs: Einkaufsliste, Karte, Meine Apps, Angebote, Profil.
- **Daten:** `app/assets/` (Katalog 250 Produkte, Angebote, Stores); Karte nutzt `stores_map/data/rlp_stores.dart` (49 Filialen MZ-BIN/RH).
- **Optimierer:** lokal in `optimizer_service.dart` (Single- vs. Multi-Store, Cluster ohne Fahrtkosten); Remote via Edge Function `optimize-route`, wenn Supabase aktiv.
- **Backend:** Supabase/PostGIS, Migrationen in `supabase/migrations/` – noch nicht live verbunden ([[Supabase-Anbindung]]).
- **Scraper:** Node.js, 6 Ketten, Fokus Bingen/Oberwesel ([[Live-Scraper]]).
- **CI/CD:** GitHub Actions `test` → `build` → `deploy` auf GitHub Pages.

Vollständige Dateizuordnung: [AGENTS.md](../../AGENTS.md)
