---
name: tasks
description: Turn an approved SPEC.md into a complete TASKS.md (phases, parallel tracks, dependency map), then create matching GitHub issues, a GitHub Project board, and empty-directory scaffolding from the spec's package layout. Use whenever the user invokes /ank:tasks, says "break this into tasks", "create the issues", "wire up the project board", or otherwise signals the approved spec should become trackable, parallel-friendly work. Requires a SPEC.md to exist and the user to have explicitly approved it. The skill HARD STOPS before creating GitHub side-effects, asks for confirmation, and gracefully degrades when the gh CLI is absent or unauthenticated.
allowed-tools: Read, Write, Bash, Grep, Glob, Edit, AskUserQuestion
---

# Tasks

The user has an approved `SPEC.md`. Your job is to turn it into:

1. A `TASKS.md` with phases, parallel tracks, sized tasks, dependencies, labels, and milestones.
2. One GitHub issue per task, with labels and dependency callouts in the body.
3. A GitHub Project board with issues grouped by milestone.
4. Empty directories matching the spec's package layout.

You are **not** writing code. You are **not** scaffolding files inside the directories. You are not committing anything to git.

## Pipeline position

```
/ank:third-degree  →  /ank:spec  →  /ank:tasks  →  (build with Claude Code)  →  /ank:review-board
                                     (this)
```

This skill runs **only after** `SPEC.md` has been written and explicitly approved by the user. If there's no `SPEC.md` (root or `docs/spec/<slug>.md`), refuse and point at `/ank:spec`. If a `SPEC.md` exists but the conversation has no record of approval, ask once: "I see SPEC.md at `<path>` — has this been approved? Reply yes to proceed."

## Where TASKS.md lives

Mirror the spec's location:

| Spec location | Tasks location |
|---|---|
| `./SPEC.md` (product-level) | `./TASKS.md` |
| `./docs/spec/<slug>.md` (feature-level) | `./docs/spec/<slug>.tasks.md` |

If `TASKS.md` already exists, ask once before overwriting.

## TASKS.md shape

Every TASKS.md the skill produces follows the same structure. Preserve all of these elements — they're what makes the file parallel-friendly and trackable:

- **Phases** — Phase 0 setup → Phase 1 build the parts → Phase 2 wire it together. Every product fits this rhythm; don't invent alternatives unless the spec genuinely demands it.
- **Tracks** within Phase 1 — parallel work streams labeled A/B/C/D/E that map 1:1 to the spec's major modules. Tasks within a track are sequential; tracks themselves are independent so multiple people (or agents) can work in parallel.
- **Task IDs match issue numbers** — T-01 = #1, T-02 = #2 … T-N = #N. Sequential, gap-free.
- **Per-task fields** — commit-style title, size (`S` = hours, `M` = 1-2 days, `L` = 3+ days), `Depends on:` (hard code deps that block merge), `Coordinate with:` (soft interface agreement, no code dep), `Unblocks:` (downstream tasks that wait on this).
- **Dependency map** — ASCII art at the bottom showing the graph (use `├──`, `└──`, arrows). Lets a reader see the critical path at a glance.
- **Labels table** — `area:<track>`, `size:S/M/L`, `blocked`, with one-line "Purpose" column.
- **Milestones table** — M1 Foundations → M2 Working parts → M3 Shipped (or product-appropriate variants), with the set of issues each milestone contains and its one-line goal.

## Prerequisites — check before doing anything else

Run these checks in parallel at the start:

1. `test -f SPEC.md || ls docs/spec/*.md 2>/dev/null` — confirm a spec exists
2. `git remote -v` — confirm the repo has a remote configured
3. `gh --version 2>/dev/null` — confirm gh CLI is installed
4. `gh auth status 2>/dev/null` — confirm authentication
5. `gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null` — confirm gh can see the current repo

Branch on the results:

- **All pass:** proceed through all stages.
- **No spec:** refuse; point at `/ank:spec`.
- **No git remote:** print a one-line warning, ask the user to add a remote, then stop.
- **gh missing or unauthenticated, OR `gh repo view` fails:** proceed through Stages 1-3 (proposal → draft TASKS.md → approval), then **stop before issue creation**. Tell the user:

   > Written: `TASKS.md` with N tasks. To create matching GitHub issues and the project board, run `gh auth login` (or install gh from <https://cli.github.com>), then re-run `/ank:tasks` — I'll pick up from issue creation and backfill the issue numbers into TASKS.md.

## Stages

### Stage 1 — Phase + track proposal (in chat, no file yet)

Read the spec end-to-end. In particular, study:

- **Module breakdown** (the §5-ish modules) → these become parallel tracks
- **Build order** (the weekly plan) → this becomes phase boundaries
- **Build priority stack** → this resolves track ordering and labels Phase 1 vs Phase 2

Propose, in chat:

- Phase 0 setup task list (1-3 tasks, always includes "initialize package / repo skeleton + CI")
- Phase 1 parallel tracks (A/B/C…) — one track per major spec module; name them descriptively
- Phase 2 integration tasks — recipes, examples, end-to-end wiring, hero demo
- Labels (`area:<track>`, `size:S/M/L`, `blocked`)
- Milestones (M1 Foundations → M2 Working parts → M3 Shipped, or product-appropriate variants)

Print the proposal as a tight bulleted summary. **Stop.** Let the user redirect track names, phase splits, or scope. Only proceed when they say "looks good, draft tasks" or equivalent.

### Stage 2 — Draft TASKS.md

Write the file using the structure described in "TASKS.md shape" above:

1. **Header** — product name + one-line description. Note that issue numbers will match task IDs once created. Include a "How to read this" block (Depends on / Coordinate with / S-M-L sizing).
2. **Phase 0 — Setup** — bullet list of setup tasks. Each task: `[ ] **T-NN** ` ``commit-style title`` `` `size` `` with sub-bullets for scope and `_Unblocks_` line.
3. **Phase 1 — Build the parts** — `### Track X — <name>` per parallel stream, each containing its task list in dependency order.
4. **Phase 2 — Wire it together** — integration tasks (recipes, examples, hero demo).
5. **Dependency map** — ASCII art (`├──`, `└──`, arrows) showing inter-task edges. Same shape as the reference exemplar.
6. **Labels table** — `area:*`, `size:*`, status labels.
7. **Milestones table** — M1/M2/M3 with goals and included issues.

Task IDs are sequential across all phases (T-01, T-02, …). **Do not skip numbers** — they must map 1:1 to GitHub issue numbers in Stage 5.

Size each task by gut feel: S = hours, M = 1-2 days, L = 3+ days. Don't sandbag — if a task feels like a week, it's an L and probably should be split.

**Deps are derived, not invented.** Read them from the spec's module layout and build order: if module B's public API uses types defined in module A, B depends on A. If two modules share an interface without code coupling, that's "Coordinate with" — soft, no merge ordering required.

### Stage 3 — Approval gate

After writing:

1. Confirm the file path: `Written: TASKS.md (N tasks across Phase 0/1/2)`.
2. Summarize: tracks, total task count, milestone breakdown.
3. End with:

   > Review TASKS.md and reply with **"approved"** to create GitHub issues and the project board, or send edits and I'll revise.

Anything but explicit approval = edits; revise and stop again.

### Stage 4 — Confirm before GitHub side-effects

After approval, **before any `gh` command that creates state**, print the planned operations:

```
About to create on <owner>/<repo>:
  • N issues (T-01 … T-NN), each labeled per the labels table
  • 1 GitHub Project board: "<product-name> v0"
  • Add all N issues to the project, grouped by milestone

Reply "create" to proceed, or send edits.
```

Wait for an explicit `create` / `ship it` / `go ahead`. Anything else = stop.

### Stage 5 — Create issues + project board

Once confirmed, execute in this order:

1. **Create labels** that don't exist yet: `gh label create <name> --description "<desc>" --color <hex>`. Use neutral colors. Skip if `gh label list` already includes them.
2. **Create issues sequentially** (not parallel — issue numbering must be deterministic):
   - For each task in TASKS.md order, run `gh issue create --title "<title>" --body "<body>" --label "<labels>"`.
   - The body includes: the task description from TASKS.md, `**Depends on:** #X, #Y` lines if applicable, `**Coordinate with:** #Z` lines if applicable, and a backlink to the spec section.
   - Capture the issue number from the gh output (it prints the URL; the trailing path segment is the number).
3. **Verify ID mapping.** After creating all issues, confirm `T-NN` maps to `#NN` (typically the first task you create gets the next free issue number; if the repo already has issues, the mapping is offset). If mapping is offset (e.g., T-01 → #15), **stop and report**:

   > Heads up: this repo already has issues, so T-01 maps to #15, T-02 to #16, … Reply `backfill` and I'll rewrite TASKS.md with the actual issue numbers, or `cancel` to delete the created issues and start fresh elsewhere.

   Don't delete unprompted — the user owns that call.
4. **Backfill issue numbers into TASKS.md.** Replace `**T-NN**` headers with `**[T-NN #N](https://github.com/<owner>/<repo>/issues/N)**` and update the dependency map ASCII art to use the real `#N` references.
5. **Create the GitHub Project board.** Use `gh project create --owner <owner> --title "<product> v0"`. Capture the project number. If `gh project` fails (older gh, missing scope), fall back to creating a classic Projects board via API or just report "project creation skipped — please create manually and add the milestone issues."
6. **Add issues to the project** using `gh project item-add <number> --owner <owner> --url <issue-url>` per issue. Group by milestone in a "Status" or "Milestone" field if the gh version supports custom fields.

### Stage 6 — Empty-directory scaffold

Read the spec's package layout section (typically §3 in library specs, §5/§8 in SaaS specs — find the ASCII tree). For every directory in the tree, run `mkdir -p <path>`. **Do not create files inside.** No `__init__.py`, no placeholder READMEs, no stubs.

If the layout includes files at the leaves (e.g., `loop.py`), still only create the parent directory. The user (or Claude Code in build phase) owns file creation.

### Stage 7 — Final summary

Print a one-screen summary:

```
✓ TASKS.md written (N tasks)
✓ N GitHub issues created on <owner>/<repo>
✓ Project board: <url>
✓ Directory scaffold: <count> directories created from SPEC §<n> layout

Next: pick up T-01 (#1) and start building. /ank:review-board after you ship a feature.
```

Stop. Don't propose starting on T-01.

## Hard constraints

- **Never create issues without explicit confirmation.** The Stage 4 gate is non-negotiable. Even if the user said "go ahead and do everything" earlier — visible side-effects on GitHub get their own confirm.
- **Task IDs must be sequential and gap-free.** T-01, T-02, … T-N. No skipping.
- **Don't invent dependencies.** Every "Depends on" must be derivable from the spec's module layout or build order. If you're guessing, leave it off.
- **Issue numbers must match task IDs OR be backfilled honestly.** If the repo has existing issues that offset numbering, report it and let the user choose — don't silently create T-01 = #15 without flagging.
- **Don't skip the gh CLI fallback.** Missing/unauth gh → write TASKS.md, stop, instructions. Never half-create issues.
- **Don't create files inside scaffolded directories.** `mkdir -p` only. No `touch`, no placeholder content.
- **Don't commit or push.** All operations are local + GitHub API. If the user asks you to commit, treat it as a separate request after this skill completes.
- **One issue per task.** Don't bundle. Don't split. The TASKS.md task list is the contract.
- **Sentence case in titles** ("Initialize Python package" not "Initialize Python Package"). Conventional-commit-style prefixes (`feat:`, `chore:`, `feat(scope):`) are encouraged.

## When the user pushes for shortcuts

- "Skip the approval, just create the issues" → No. Stage 4 stays. The cost of confirming is seconds; the cost of 30 wrong issues is much higher.
- "Also scaffold the files inside, not just dirs" → No. That's the build phase's job. Empty dirs only.
- "Use my existing TASKS.md, don't rewrite it" → Skip Stage 2, jump to Stage 4. But still read it end-to-end and surface anything inconsistent with the spec.
- "Create issues without a spec" → No. Run `/ank:spec` first. Tasks without a spec drift instantly.

## A note on the gh CLI fallback

When `gh` is missing or unauthenticated, the skill must still be useful. Producing TASKS.md is 80% of the value — the GitHub side-effects are a nicety. Make the degraded path feel intentional, not broken:

- Write TASKS.md normally (with `**T-NN**` headers, no issue links yet)
- Add a note at the top: `> Issue numbers pending — re-run /ank:tasks after \`gh auth login\` to create issues and backfill links.`
- In Stage 5, when the user re-runs after auth, detect this case (TASKS.md exists without issue links) and skip Stages 1-3, going straight to Stage 4 confirmation.
