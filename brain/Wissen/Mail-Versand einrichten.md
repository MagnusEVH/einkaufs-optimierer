---
type: wissen
aktualisiert: 2026-11-28
tags: [supabase, mail, anleitung]
---
# Mail-Versand (Brevo-SMTP)

Grundlage für das Anmelde-System: Ohne eigenes SMTP gehen nur 2 Mails pro Stunde raus, und die Mail-Texte lassen sich nicht ändern (also kein Code in der Mail). **Eingerichtet am 2026-11-28**, siehe [[2026-11-28 Mail-Link 404]].

> [!info] Warum Brevo statt Gmail
> Gmail-SMTP braucht ein App-Passwort, und das setzt die Zwei-Schritt-Bestätigung voraus. Google sperrt beides bei neuen Konten oft für Tage. Brevo (kostenlos, 300 Mails/Tag) geht ohne.

> [!warning] Der SMTP-Schlüssel steht nur bei Brevo und Supabase. Nie in Notizen, Chat oder Repo.

## Stand
| Wo | Einstellung |
|---|---|
| Brevo → Absender | Gmail-Adresse des Projekts, bestätigt |
| Supabase → Emails → SMTP | Host `smtp-relay.brevo.com`, Port `587`, Benutzer = SMTP-Anmeldung aus Brevo (SMTP & API), Passwort = SMTP-Schlüssel, Absendername „Einkaufs-Optimierer“ |
| Supabase → Rate Limits | 30 Mails pro Stunde (automatisch mit SMTP) |
| Supabase → Providers → Email | Confirm email an, OTP 6 Ziffern, gültig 3600 s, Mindestpasswort 8 |
| Supabase → URL Configuration | Site URL und Redirect URL = `https://magnusevh.github.io/einkaufs-optimierer/` (Redirect mit `**`) |
| Supabase → Templates | „Confirm sign up“ und „Reset password“ mit `{{ .Token }}` im Betreff und groß im Text, Link nur klein darunter |

## Schlüssel erneuern
Brevo → SMTP & API → „SMTP-Schlüssel generieren“ → bei Supabase unter SMTP ins Feld Password einfügen → Save. Alten Schlüssel in Brevo löschen.

## Hinweise
- Absender ist eine Gmail-Adresse ohne eigene Domain: erste Mails landen evtl. im Spam. Saubere Lösung später: eigene Domain mit DKIM/DMARC
- Probe: App → Anmelden → „Passwort vergessen“ → Code kommt in Sekunden → Code und neues Passwort → angemeldet. Am 2026-11-28 erfolgreich auf dem iPhone
