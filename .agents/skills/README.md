# Agent Skills (vendored)

Die Obsidian-Skills stammen aus [obsidianmd/obsidian-skills](https://github.com/obsidianmd/obsidian-skills), Commit `b110b2f8e9eb1f287892f937050dfd40af862cbb`, MIT-Lizenz (siehe `LICENSE-obsidian-skills`).

Nicht von Hand ändern. Aktualisieren:

```bash
git clone --depth 1 https://github.com/obsidianmd/obsidian-skills.git /tmp/obsidian-skills
cp -r /tmp/obsidian-skills/plugins/obsidian/skills/* .agents/skills/
```

Danach den Commit oben anpassen. Claude Code nutzt diese Kopie nicht, sondern das Plugin aus `.claude/settings.json`.
