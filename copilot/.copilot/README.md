# Personal Copilot setup

My lean, cross-project GitHub Copilot CLI configuration. Loaded automatically for
**every** project. Repo-level config (`AGENTS.md`, `.github/instructions/**`) always
takes precedence when it conflicts.

Philosophy borrowed from spec-first / "vibe coding" workflows (Peter Steinberger),
plus explicit verification gates — kept deliberately minimal.

## What's here

| File | Purpose |
|------|---------|
| `copilot-instructions.md` | Core operating principles applied to every session: code-is-cheap iteration, spec-before-code, tight feedback loops, delegate/parallelize, clean shipping. |
| `agents/` | Not here any more: the **Spec**, **Ship** and **Harden** agents live in the private, harness-independent `~/.agents` repo (`~/.agents/agents`), and its `install.sh` points `~/.copilot/agents` (and `~/.claude/agents`) there. |

I intentionally rely on the CLI's **built-in** agents (explore, task, general-purpose,
code-review, research, rubber-duck) instead of recreating them. **Harden** wraps the
built-in `code-review` agent in a fix-and-re-check loop rather than replacing it.

## How I use it

- New feature / fuzzy request → invoke **Spec** first (or plan mode, `shift+tab`):
  `Use the Spec agent to plan {idea}`
- Implement a planned change cleanly → **Ship**:
  `Use the Ship agent to implement {spec/task}`
- Review-and-fix a change before pushing → **Harden**:
  `Use the Harden agent on this branch`
- One-shot findings only (no fixes) → built-in `/review`.
- Quick lookups, builds → built-in agents (`/agent`, or just ask).

## Tuning

- Add personal skills under `~/.agents/skills/<name>/SKILL.md` (auto-loaded by
  relevance, and harness-independent). They live in a **separate private repo**
  (`~/.agents`), not here — see its README. Anything employer-specific belongs
  there, never in this public repo.
- For more autonomy, run with `--yolo` / `/autopilot`; for parallel subagents, `/fleet`.
- Keep this lean — only add an agent/skill when a built-in can't already do the job.
