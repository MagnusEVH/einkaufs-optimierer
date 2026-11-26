---
type: entscheidung
status: gilt
datum: 2026-11-26
tags: [entscheidung]
---
# Haushalte statt Kontowechsel

**Kontext:** Familie soll Listen teilen. Wunsch: in die eigene Liste und in die der Eltern wechseln können.

**Entscheidung:** Ein Konto pro Person. Listen gehören einem Haushalt, ein Konto kann in mehreren Haushalten sein. Gewechselt wird der Haushalt, nicht das Konto. Der aktive Haushalt liegt im Client, nicht im Login-Token (Beitritt und Austritt wirken sofort). Weitere Haushalte legt der Admin an, z. B. "Eltern", den er auch ohne Konten der Eltern pflegen kann.

**Folgen:** Datenmodell `households`, `household_members`, `invitations` in [Migration](../../supabase/migrations/20261126000001_konten_haushalte.sql). Kein Teilen von Passwörtern.
