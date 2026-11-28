---
type: wissen
aktualisiert: 2026-11-28
tags: [supabase, mail, anleitung]
---
# Mail-Versand einrichten (Gmail-SMTP)

Grundlage für das Anmelde-System: Ohne eigenes SMTP gehen nur 2 Mails pro Stunde raus, und die Mail-Texte lassen sich nicht ändern (also kein Code in der Mail). Entscheidung: Gmail mit App-Passwort, siehe [[2026-11-28 Mail-Link 404]].

> [!warning] Das App-Passwort nur bei Supabase eintragen. Nie in Notizen, Chat oder Repo.

## 1. Gmail-Konto (einmalig)
1. Eigenes Konto anlegen, z. B. `einkaufsapp.<name>@gmail.com` (nicht das private)
2. https://myaccount.google.com/security → **Bestätigung in zwei Schritten** einschalten
3. https://myaccount.google.com/apppasswords → Name „Supabase“ → **Erstellen** → 16-stelliges Passwort kopieren (Leerzeichen weglassen)

## 2. Supabase: SMTP
Dashboard → Projekt → **Authentication → Emails → SMTP Settings** → „Enable Custom SMTP“

| Feld | Wert |
|---|---|
| Sender email | die Gmail-Adresse |
| Sender name | Einkaufs-Optimierer |
| Host | `smtp.gmail.com` |
| Port | `465` |
| Username | die Gmail-Adresse |
| Password | das App-Passwort |
| Minimum interval | 60 Sekunden |

## 3. Supabase: Grenzen und Code
- **Authentication → Rate Limits** → „Rate limit for sending emails“: `30` pro Stunde
- **Authentication → Sign In / Providers → Email**: „Confirm email“ an, „Email OTP Expiration“ `3600`, „Email OTP Length“ `6`. „Secure password change“ darf an bleiben (die App fragt dann selbst einen Code ab)

## 4. Supabase: Adressen
**Authentication → URL Configuration**
- Site URL: `https://magnusevh.github.io/einkaufs-optimierer/`
- Redirect URLs → Add URL: `https://magnusevh.github.io/einkaufs-optimierer/**`

## 5. Supabase: Mail-Texte
**Authentication → Emails → Templates**. Bei beiden Vorlagen Betreff und Text ersetzen.

**Confirm signup** – Betreff: `Dein Code: {{ .Token }}`
```html
<h2>Willkommen beim Einkaufs-Optimierer</h2>
<p>Gib diesen Code in der App ein:</p>
<p style="font-size:32px;font-weight:bold;letter-spacing:6px">{{ .Token }}</p>
<p>Der Code gilt eine Stunde. Hast du dich nicht registriert, ignoriere diese Mail.</p>
<p style="color:#888;font-size:12px">Notfalls geht auch dieser Link: <a href="{{ .ConfirmationURL }}">E-Mail bestätigen</a></p>
```

**Reset Password** – Betreff: `Code für dein neues Passwort: {{ .Token }}`
```html
<h2>Neues Passwort</h2>
<p>Gib diesen Code in der App unter „Passwort zurücksetzen“ ein:</p>
<p style="font-size:32px;font-weight:bold;letter-spacing:6px">{{ .Token }}</p>
<p>Der Code gilt eine Stunde. Hast du nichts angefordert, ignoriere diese Mail. Dein Passwort bleibt dann gleich.</p>
<p style="color:#888;font-size:12px">Notfalls geht auch dieser Link: <a href="{{ .ConfirmationURL }}">Passwort zurücksetzen</a></p>
```

## 6. Probe
App → Anmelden → „Passwort vergessen“ → Code kommt in wenigen Sekunden (sonst im Spam schauen) → Code und neues Passwort eingeben → angemeldet.
