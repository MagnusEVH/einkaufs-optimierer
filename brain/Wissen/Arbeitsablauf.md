---
type: wissen
aktualisiert: 2026-11-22
tags: [wissen, ablauf]
---
# Arbeitsablauf: Obsidian lokal + Claude in der Cloud

```
GitHub-Repo (main)
 ├─ brain/  ← dieser Vault-Inhalt
 ├─ Cloud-Claude / Antigravity: lesen brain/, arbeiten, pflegen brain/, pushen auf claude/…-Branch
 └─ Nutzer: mergt PR → Obsidian Git (Auto-Pull) holt Code + Notizen auf den PC
```

- Aufträge von überall: claude.ai/code oder Claude-App.
- Agenten-Notizen erscheinen lokal **erst nach dem Merge**.
- Eigene Notizen des Nutzers werden von Obsidian Git committet und gepusht – Agenten lesen sie beim nächsten Auftrag.
- Private Notizen, die nicht ins Repo sollen: außerhalb von `brain/` in einem gitignorierten Ordner.

> [!danger] Keine Passwörter, Keys oder Tokens in Notizen – das Repo liegt auf GitHub.

Regeln für Agenten: [AGENTS.md – Zweites Gehirn](../../AGENTS.md)
