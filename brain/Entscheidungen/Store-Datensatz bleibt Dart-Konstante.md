---
type: entscheidung
status: gilt
datum: 2026-11-22
tags: [entscheidung]
---
# Store-Datensatz bleibt Dart-Konstante

**Kontext:** Beim Aufteilen von `stores_screen.dart` stand JSON als Alternative im Raum.

**Entscheidung:** `data/rlp_stores.dart` als `const` – kein asynchrones Laden, kein Verhaltenswechsel.

**Folgen:** Umzug nach JSON/Supabase wäre ein eigener Schritt.
