# Personal operating principles

These are my personal, cross-project defaults. Repository-level instructions
(`AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/**`) always
win over these when they conflict — they describe the project; this describes how I work.

## Mindset: code is cheap, iteration is the product

- Optimize for fast, correct iterations — not for a perfect first draft.
- Don't get attached to generated code. If an approach is wrong, throw it away and
  regenerate rather than patching something that fights you.
- Spend the saved effort on the hard, differentiating parts: the spec, the edge cases,
  the architecture decisions — the things that need real human judgment.

## Spec before code (for anything non-trivial)

- For a feature or a multi-file change, write or read the spec first. Use plan mode
  (`shift+tab`) or the **Spec** agent to turn a rough idea into a crisp plan.
- Surface unknowns *before* writing code: list assumptions, ambiguities, and the
  questions a fresh engineer would ask. Resolve the blocking ones, then build.
- A good spec names: the goal, the inputs/outputs, the affected files, what must
  NOT change (invariants), and the known risks.
- Skip this for trivial edits — don't ceremony-wrap a one-line fix.

## Tight feedback loops

- After every change, close the loop: run the relevant test/build/lint and read the
  output before moving on. Never declare done on unverified work.
- **Never leave a failing test or broken build.** If a change breaks something, fix it
  or revert it in the same turn.
- Prefer the smallest signal that proves correctness: a single test, a `curl`, a
  type-check — not a full suite when a focused run suffices.
- Use real evidence over assumption: logs, actual API/JSON payloads, screenshots,
  and error output. When debugging UI or visual issues, ask for a screenshot.

## File operations

- **Never use `rm` (or `rm -rf`) to delete files or directories.** Use a trash
  utility instead, so anything deleted is recoverable: `trash` (macOS / npm
  `trash-cli`), `gio trash` or `trash-put` (Linux), or the platform equivalent.
  If no trash utility is available, stop and ask me rather than falling back to `rm`.
- **Never delete-and-recreate a file to change it.** Edit the existing file in place
  with the edit tool. Rewriting from scratch loses history, permissions, and any
  content you didn't know about.
- Same rule for renames/moves: use `git mv`/`mv`, not delete + create.
- Only create a new file when the file genuinely doesn't exist yet.

## Delegate and parallelize

- Use the right tool for the job. Delegate self-contained research to **explore**,
  noisy command runs (tests/builds/installs) to **task**, and long multi-step work
  to subagents — keep the main context clean.
- Launch independent work streams in parallel rather than serializing them.
- Batch independent tool calls into one turn (multiple reads, multiple edits).

## Prompts and communication

- Be concise. Default to the shortest response that fully answers.
- Make precise, surgical changes that fully address the request. Don't refactor
  unrelated code in the same change; note unrelated issues instead of fixing them.
- Only comment code where the intent isn't obvious from the code itself.
- Ask a focused question when a decision materially changes the approach — don't
  guess on ambiguous, high-impact choices.

## Shipping

- Use Conventional Commits: `type(scope): summary` (`feat`, `fix`, `refactor`,
  `chore`, `docs`, `test`). Body explains *why*, not *what*.
- Stage only the files that belong to the change. Never commit secrets. Never
  force-push shared branches.
- Don't include co-authors or reviewers in the commit message.

## Creating Jira tickets

Whenever I ask you to create a Jira ticket use the Atlassian MCP server and create the ticket with following defaults:

- **cloudId**: `{{JIRA_CLOUD_ID}}`
- **Project**: `{{JIRA_PROJECT}}` ({{JIRA_PROJECT_NAME}})
- **Labels**: `{{JIRA_LABELS}}`
- **Responsible Team** (`{{JIRA_CF_RESPONSIBLE_TEAM}}`): `{{JIRA_RESPONSIBLE_TEAM}}`
- **Owner** (`{{JIRA_CF_OWNER}}`): `{{JIRA_OWNER_NAME}}` → `{"id": "{{JIRA_OWNER_ID}}"}`
- **Traffic Light** (`{{JIRA_CF_TRAFFIC_LIGHT}}`): `{{JIRA_TRAFFIC_LIGHT_NAME}}` → `{"id": "{{JIRA_TRAFFIC_LIGHT_ID}}"}`
- **Assignee**: me — `assignee_account_id: "{{JIRA_ASSIGNEE_ACCOUNT_ID}}"`

Pass the custom/Owner/Traffic Light/Responsible Team values via `additional_fields`, e.g.:
`{"labels": {{JIRA_LABELS}}, "{{JIRA_CF_RESPONSIBLE_TEAM}}": {{JIRA_RESPONSIBLE_TEAM}}, "{{JIRA_CF_OWNER}}": {"id": "{{JIRA_OWNER_ID}}"}, "{{JIRA_CF_TRAFFIC_LIGHT}}": {"id": "{{JIRA_TRAFFIC_LIGHT_ID}}"}}`

Always write the ticket description (and any updates to it) in **Markdown format**, not
Jira wiki markup. When the Atlassian MCP tool exposes a body/markup format option, set it
to Markdown (`atlas_doc_format` / `bodyFormat: markdown`) so the content is authored and
updated as Markdown.

Set the ticket **issue type** (default `Task`) depending on what I requested.

## Looking up Jira tickets

- Whenever I ask you to look up, find, read, or search for a Jira ticket/issue,
  use the **Atlassian MCP** server (cloudId `{{JIRA_CLOUD_ID}}`).
- Any link starting with `{{JIRA_BASE_URL}}` is **our Jira**. Treat the
  trailing key (e.g. `{{JIRA_BASE_URL}}/browse/{{JIRA_PROJECT}}-3554`) as the issue key and fetch it via the
  Atlassian MCP rather than trying to open the URL directly.
