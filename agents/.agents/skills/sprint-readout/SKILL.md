---
name: sprint-readout
description: >-
  Build a data-driven reveal.js sprint readout presentation. Mines git commits across
  repos for the sprint window, groups them by issue-tracker key (e.g. ABC-1234),
  enriches from Jira or GitHub, and renders a deck covering achievements, business
  value, technical value, challenges and lessons.
  USE FOR: sprint readout, sprint review deck, sprint presentation, sprint demo slides,
  "what did I ship this sprint", biweekly readout, reveal.js sprint deck.
  DO NOT USE FOR: generic slide decks unrelated to a sprint.
---

# Sprint readout deck

Produces `<OUTPUT_DIR>/sprint-readout-<since>-to-<until>.html` — a self-contained
reveal.js deck.

## Configuration

All machine- and employer-specific values live in `config.env` next to this file
(`config.env.example` is the committed template; `config.env` itself is not committed).
Override the path with `$SPRINT_READOUT_CONFIG`.

**Read `config.env` before doing anything else.** It defines the presenter and team
name, output directory, reference decks, repo scan root, issue-key prefix and brand
colours. `new_deck.sh` and `collect_commits.py` both load it automatically — you only
need to read it yourself to know which tracker to query and where the reference decks
are.

If `config.env` is missing, say so and offer to create it from `config.env.example`
rather than guessing values or hard-coding a project name into the deck.

**Reference decks:** if `REFERENCE_DECKS_DIR` contains previous readouts, read the most
recent one before writing. It is the style and narrative gold standard and beats
anything in this file.

## Workflow

### 1 · Settle the inputs

Ask only for what's missing, in one message:

- **sprint window** (`--since` / `--until`, `YYYY-MM-DD`)
- **repos** — default: scan `REPO_SCAN_ROOT`; confirm the list found
- **challenges + lessons** — the human-only data. Point the user at
  `assets/sprint-input.template.md`; copy it to `<session-files>/sprint-input.md`
  for them to fill, or accept it inline in chat.

Do not start writing slides before the sprint-input content exists. It is half the deck.

### 2 · Mine the commits

```bash
python3 <skill>/scripts/collect_commits.py \
  --since <since> --until <until> \
  --json  <session-files>/commits.json \
  --markdown <session-files>/commits.md
```

Defaults come from `config.env`. Override per run with `--repos <paths…>`,
`--scan-root`, `--max-depth N`, `--author <email>`, `--branches current`,
`--key-prefix ABC`.

Read `commits.md` first — it is the digest. Drop into `commits.json` for per-commit
paths, diffstats and `primary_ticket` (the key in the subject line, as opposed to keys
merely referenced in the body) when writing a deep dive.

The collector de-duplicates commits that appear in several checkouts or under several
SHAs after a rebase; `totals.duplicates_collapsed` tells you how many. Quote the
de-duplicated numbers on the deck.

**Always handle the untagged commits.** They are listed separately; either attribute
them to a ticket manually or fold them into a "smaller items" line. Never silently drop
work.

### 3 · Enrich from the issue tracker

Driven by `ISSUE_TRACKER` in `config.env`:

- **`jira`** — fetch summary, type, status and description via the Atlassian MCP
  (`getJiraIssue`, cloudId from `JIRA_CLOUD_ID`). Batch with
  `searchJiraIssuesUsingJql`, e.g. `key in (ABC-101, ABC-102, …)`.
  Never post Jira comments.
- **`github`** — use the GitHub MCP `issue_read` / `search_issues` against
  `GITHUB_ISSUE_REPO`.
- **`none`** — skip; rely on commit subjects and bodies alone.

Use the tracker for the *intent* of the work; use the commits for what was *actually*
done. Where they disagree, the commits win — and that disagreement is often worth a
slide.

### 4 · Derive the story

Do not render one slide per ticket. Cluster tickets into **3–5 workstreams** by theme,
then choose the **2–4 tickets that deserve a deep dive** (biggest diffstat, production
impact, or the most interesting reasoning). Everything else goes in a "smaller items"
table.

For each deep dive and each workstream, write both explicitly:

- **Business value** — who benefits, what outcome changed, ideally a number.
  Not "refactored the adapter" but "the nightly job is green, so the dashboard is no
  longer stale for the people who act on it".
- **Technical value** — the invariant, capability or risk-reduction gained. Debt paid,
  failure class eliminated, test coverage, reversibility.

If a ticket has no articulable business value, say so out loud on the slide — that's
honest and it's better than inventing one.

### 5 · Render

```bash
bash <skill>/scripts/new_deck.sh <since> <until>
```

This copies `assets/template.html`, inlines `assets/theme.css`, appends the `BRAND_*`
overrides from `config.env`, fills in the presenter/team identity, and refuses to
overwrite an existing deck. Then fill in every remaining `{{PLACEHOLDER}}` and duplicate
the deep dive section per ticket. Use `assets/slide-patterns.md` for the block
vocabulary.

Target shape (~14–18 slides): title · by the numbers · workstreams · deep dives ·
smaller items · delivery data · challenges · lessons · next · closing.

### 6 · Verify before handing over

- `grep -c '{{' <deck>` returns 0 — no leftover placeholders
- `grep -c '<section' <deck>` matches the slide count you intended
- every `<section>` has an `<aside class="notes">`
- KPI numbers on the "by the numbers" slide match `commits.json` totals exactly
- open it and check nothing overflows (see the layout budget in
  `assets/slide-patterns.md`)

## Writing rules

- **Evidence over adjectives.** Every claim carries a number, a query result, a row
  count or a log line. "28,885 rows / 28,885 distinct ids / 0 duplicates" beats "the
  data was clean".
- **Speaker notes carry the real content.** Slides are scaffolding; the `<aside>` is a
  spoken paragraph — full sentences, the reasoning, the thing that was surprising, the
  nuance deliberately preserved. Write them as if speaking aloud.
- **Name what was wrong, including your own wrong turns.** Inherited hypotheses that
  turned out false, bugs that survived review, tickets closed as Won't Do — these are
  the most valuable slides. Justify Won't Do with evidence.
- **First person, plain language, no corporate filler.** Contractions are fine.
- **Set up three takeaways in the title notes and close the loop on them** in the
  closing slide notes.
- **Do not inflate.** Ticket counts are not throughput; say which ones were one-liners.

## Files

| Path | Purpose |
|---|---|
| `config.env.example` | Committed template for the per-machine values |
| `config.env` | Actual per-machine values — not committed |
| `assets/theme.css` | Neutral visual theme; `BRAND_*` overrides layer on top |
| `assets/template.html` | Slide scaffold with `{{PLACEHOLDER}}`s |
| `assets/slide-patterns.md` | Copy-paste block vocabulary + layout budget |
| `assets/sprint-input.template.md` | Human-only input: challenges, lessons, blockers |
| `scripts/collect_commits.py` | Git → per-ticket / per-repo / totals JSON + markdown |
| `scripts/new_deck.sh` | Template + theme + brand + identity → new dated deck |
