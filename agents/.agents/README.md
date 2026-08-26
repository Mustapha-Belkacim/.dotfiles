# Harness-independent agent skills

Skills under `~/.agents/skills/` are read by several agent CLIs (Copilot CLI, Claude
Code, …), so they live in their own stow package rather than inside `copilot/`.

```bash
cd ~/.dotfiles && stow -t "$HOME" agents
```

## Skills

| Skill | Purpose |
|---|---|
| `sprint-readout` | Builds a data-driven reveal.js sprint readout deck: mines git commits across repos for the sprint window, groups them by issue-tracker key, enriches from Jira/GitHub, and renders achievements, business value, technical value, challenges and lessons. |

## Keeping skills employer-neutral

Nothing project-specific belongs in a committed skill file. Each skill that needs it
ships a `config.env.example` and reads a gitignored `config.env` at runtime:

```bash
cd ~/.agents/skills/sprint-readout
cp config.env.example config.env && $EDITOR config.env
```

`agents/.agents/skills/*/config.env` is gitignored. Override the location per-run with
`$SPRINT_READOUT_CONFIG`, or just export the individual variables — real environment
variables take precedence over the file.

This is deliberately *runtime* config, not the `generate-instructions.sh` codegen used
for `copilot-instructions.md`. Instructions are static text injected as context, so they
have to be generated; a skill's scripts execute, so they can simply read the config.
