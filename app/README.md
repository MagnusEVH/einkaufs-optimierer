# Einkaufs-Optimierer (Flutter-App)

Flutter-Web/PWA-App für Lidl, Aldi Süd, Rewe, Netto, dm und Rossmann: Einkaufsliste, Preisvergleich (Single- vs. Split-Store), Karte, Wallet/Coupons und Wochenangebote. Ohne Supabase-Credentials läuft sie im Demo-Modus.

## Entwickeln

```bash
flutter pub get
flutter run -d chrome --dart-define=CARTO_API_KEY=<key>   # Key optional, sonst OpenStreetMap
flutter test
```

Daten liegen in `assets/` (einzige Quelle, wird auch von den Node-Tests in `../backend_tests/` gelesen).
Architektur, Konventionen und Befehle: siehe [../AGENTS.md](../AGENTS.md).
