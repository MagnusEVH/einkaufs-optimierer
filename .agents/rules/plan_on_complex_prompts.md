# Regel: Automatische Plan-Erstellung bei komplexen Aufgaben

## Auslöser
Jede Nutzeranfrage, die eines oder mehrere der folgenden Kriterien erfüllt:
- Betrifft mehr als eine Datei.
- Ändert Datenstrukturen, Schemas oder State Management (`Riverpod` / `Supabase`).
- Erfordert neue Features, Refactoring oder komplexe Logik (z. B. in `optimizer_service.dart` oder neuen Scrapern).

## Pflichtverhalten des Agenten
Bevor Code geschrieben oder Dateien geändert werden:
1. **Plan formulieren:**
   - **Ziel:** Was wird erreicht?
   - **Betroffene Dateien:** Liste aller Dateien mit exakten relativen Pfaden und Links (`[filename](file:///...)`).
   - **Geplante Schritte:** Schrittweise nummerierte Aufgaben.
   - **Rückfragen / Risiken:** Falls nötig kurz anmerken.
2. **Effizienzregel einhalten:** Nicht das gesamte Projekt durchscannen, sondern die in [AGENTS.md](file:///e:/antigravity/Projekt/AGENTS.md) dokumentierten Dateipfade direkt ansteuern.
