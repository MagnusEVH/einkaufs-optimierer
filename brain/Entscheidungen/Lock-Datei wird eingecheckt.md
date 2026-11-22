---
type: entscheidung
status: gilt
datum: 2026-11-22
tags: [entscheidung]
---
# Lock-Datei wird eingecheckt

**Kontext:** Datei war getrackt, stand aber in `.gitignore`.

**Entscheidung:** Lock-Datei bewusst einchecken (App, reproduzierbare Builds).

**Folgen:** Lokales `flutter pub get` mit neuerer Flutter-Version ändert sie – nicht mitcommitten, wenn nicht gewollt.
