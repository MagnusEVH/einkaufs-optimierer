---
type: session
datum: 2026-11-27
agent: Claude Code (Opus 5.5)
prs: [31]
tags: [session]
---
# 2026-11-27 – Stufe 3b: Haushalte

## Erledigt
- `household_service.dart`: Haushalte laden (mit Rolle), aktuellen merken (lokal + `profiles.last_household_id`), Gruppe anlegen, umbenennen, Code erzeugen (Mitglied oder Owner), Code einlösen, Mitglieder mit Namen, Rollen, Entfernen, Austreten, eigener Name
- Titel der Liste zeigt den Haushalt, antippen öffnet die Auswahl (nur angemeldet)
- Verwalten-Seite: Mitglieder, Einladen, Code teilen über das Teilen-Menü (Web Share API, sonst Zwischenablage)
- Abfrageform gegen das echte PostgREST geprüft (Verknüpfung `household_members` → `households` wird gefunden)
- 102 Flutter-Tests grün (6 neue)

## Offen
- Echter Durchlauf mit Konto (Magnus registriert sich)
- 3c: Liste je Haushalt abgleichen. Bis dahin wechselt die Auswahl nur den Titel

## Gelernt
- `PreferencesStorage` cacht die Instanz: in Widget-Tests `simulateReload()` im `setUp`, sonst sickern Werte durch
