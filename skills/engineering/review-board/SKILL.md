---
name: review-board
description: Generate a single-file HTML "story-paced" walkthrough of a finished feature for human code review. Use after completing a feature or merging a PR — produces docs/review/<slug>.html with sidebar nav, Why/Tradeoff/Deferred callouts, status pills, and a reviewer's checklist.
disable-model-invocation: false
allowed-tools:
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git show *)
  - Bash(git rev-parse *)
  - Bash(git symbolic-ref *)
  - Bash(git status *)
  - Bash(gh pr view *)
  - Bash(gh pr diff *)
  - Bash(bash *)
  - Read
  - Write
  - AskUserQuestion
---

# review-board

## What this skill produces

A single self-contained HTML file at `docs/review/<slug>.html` that a human reviewer can read top-to-bottom to understand a finished feature. Not a diff summary — GitHub already does that. The value is the **why** and the **shape**: what we were trying to do, the non-obvious decisions, the tradeoffs accepted, what was deferred, and what to spot-check.

**Before generating, open the reference example at `examples/walkthrough-example.html`.** It is the visual + structural target — pattern-match against it. Copy its `<style>` block and scroll-spy `<script>` **verbatim** into the new document. Match its shape: sticky sidebar with numbered TOC, scroll-spy active highlighting, story-paced sections, Why / Tradeoff / Deferred callouts, status pills, ASCII diagrams in the architecture section. The example's content describes one specific past feature — *the structure, voice, and density carry over; the words do not*.

## Inputs (two modes)

- **No argument** — walkthrough of the current branch's diff vs the repo's default branch. Detect the default with `git symbolic-ref refs/remotes/origin/HEAD` (fallback to `main`).
- **PR number or URL** (`/review-board 39` or `/review-board https://github.com/owner/repo/pull/39`) — use `gh pr view <n> --json title,body,commits,files` and `gh pr diff <n>` as the source of truth.

## Required gathering steps (do all of these before drafting)

1. Run `scripts/collect_context.sh [pr_number]` from the skill directory. It produces sectioned output with `=== HEADER ===` markers — parse it instead of making 8 separate calls.
2. From the output, extract: branch, base, commit list, diff stat, changed files, PR title/body (if applicable).
3. Get the full diff. If `git diff <base>...HEAD` (or `gh pr diff <n>`) exceeds 5000 lines, do **not** paste it — summarize file-by-file from the stat instead.
4. Read 2–3 of the most-changed files **in full** (not just the diff) so you understand context, not just the delta.
5. Read any task spec / issue body referenced by commits or PR body (e.g. `TASKS.md` entry, GitHub issue body).

## Required interview

Use `AskUserQuestion` for things you can't infer from code. Skip any question whose answer is obvious from commit messages, PR body, **or the current chat conversation**.

**Pick the right mode before asking:**

- **High-context mode** — if the chat that invoked this skill already contains strong signals for the answers (the user has been discussing this work with you turn-by-turn), do **not** issue a four-question interrogation. Instead, write your best read of all five answers and surface them as a single `AskUserQuestion` with mutually-exclusive options for the most contested call (usually the *non-obvious decision* or *tradeoff*), and note the other reads in the question's body. Let the user redirect rather than answer from scratch.
- **Cold-start mode** — if you were invoked with little prior chat context, ask the full five questions below. One question at a time, with concrete option choices that make the user pick rather than free-type.

**The five things to elicit (in either mode):**

- **Headline.** One sentence: what does this change do, and why? → opens section 1.
- **Most non-obvious decision.** What's the call another engineer wouldn't make by default? → becomes a `callout.why`.
- **Tradeoff accepted.** What did you give up to make this work? → becomes a `callout.tradeoff`.
- **Deliberately deferred.** What did you scope out on purpose? → becomes the Deferred section.
- **Reviewer focus.** What should the reviewer scrutinize? → becomes the Reviewer's checklist.

## Required output sections (the story arc)

Adapt section *names* to the feature, but keep the arc:

1. **Where we were** — the starting point. What existed before. What was missing.
2. **What this PR sets out to do** — scope table: files + role + status pill (`good` / `warn` / `bad` / `accent`).
3. **The shape of the change** — architecture / control flow. Include an ASCII `.diagram` block if there is one to draw.
4. **Per-piece deep dives** — one `story-section` per significant module or decision. This is where most Why/Tradeoff callouts live.
5. **What was deliberately deferred** — `callout.deferred` entries with reasons.
6. **How it was tested** — what's covered, what's intentionally not, total counts (verify with grep — don't invent).
7. **Reviewer's checklist** — the highest-leverage things to spot-check, as `ul.compact`.

## Output path

Write to `docs/review/<slug>.html`:

- **PR mode:** `<slug>` = `pr-<number>`.
- **Branch mode, feature branch** (current branch ≠ default branch): `<slug>` = current branch name with `/` replaced by `-` (e.g. `feature/new-checkout` → `feature-new-checkout`).
- **Branch mode, on the default branch** (`main`/`master`, i.e. `collect_context.sh` reports `mode=single-head`): using the literal branch name would clobber the file on the next merge. Use `commit-<short-sha>` instead (e.g. `commit-a1b2c3d`).

Create `docs/review/` if it doesn't exist.

## Hard constraints

- **Single-file HTML.** No external CSS, JS, fonts, or images.
- **Copy the `<style>` block and scroll-spy `<script>` verbatim** from `examples/walkthrough-example.html`. Do not rewrite, retheme, or trim the CSS — visual consistency across walkthroughs is a feature. Replace the sidebar TOC, header (title / task ID / issue / PR / branch / commit / header pills), and `<section class="story-section">` bodies with content for the current feature. Keep the same set of CSS classes (`callout.why`, `callout.tradeoff`, `callout.deferred`, `pill.good/warn/bad/accent`, `diagram`, `pillrow`, `compact`, etc.).
- **Every Why/Tradeoff/Deferred callout must have a real cause.** No padding. If you can't write the *why* in one sentence, the callout doesn't belong.
- **Every status pill must reflect actual code state.** No aspirational `good` pills on stubs. If a module is partial, use `warn` and say so.
- **Don't invent file paths, line numbers, or test counts.** If you're not sure, grep first.
- **Don't paste the full diff into the HTML.** The reviewer has GitHub for line-by-line.
- **Don't generate a generic "this PR adds X" summary.** That's what the GitHub PR body is for. The walkthrough is for the why and the shape.

## Self-check before declaring done

After writing the HTML, run these checks. Fix anything that fails; don't tell the user the file is ready until they all pass.

1. **Example-content leak grep.** The example file describes a specific unrelated feature. The new file must not retain its proper nouns, task IDs, or branded identifiers. Before drafting, skim the example and collect its distinctive terms (project name, task IDs, module names, custom class names — anything that wouldn't appear in *any* random codebase). After drafting, grep the new file for those terms and confirm none survive:
   ```bash
   grep -nE 'Term1|Term2|Term3' docs/review/<slug>.html | grep -v '<!--'
   ```
   Any hit that wasn't deliberately written for the current feature is a bug — re-edit.
2. **Anchor consistency.** Every `<li><a href="#X">` in the sidebar must match a `<section id="X">` further down, and vice versa. Mismatches break the scroll-spy and the TOC links. Run:
   ```bash
   diff <(grep -oE 'href="#[a-z0-9-]+"' docs/review/<slug>.html | sort -u) \
        <(grep -oE 'id="[a-z0-9-]+"' docs/review/<slug>.html | sort -u | sed 's/id=/href=#/' | sed 's/"/"#/' )
   ```
   (or just eyeball the two lists side by side.)
3. **File-path honesty.** For every file path mentioned in the HTML, verify it exists. `ls` the ones you cited.
4. **Status pill honesty.** Re-scan every `<span class="pill good|warn|bad">`. For each, confirm the underlying code actually matches that label. If you used `good` for "implemented", that file should actually be implemented — not stubbed.
5. **Callout density.** Every `callout.why`, `callout.tradeoff`, and `callout.deferred` should have a real cause expressible in one sentence. If you can't, delete the callout.

## What NOT to do

- Don't regenerate the doc on every commit. This is a finished-feature artifact, not CI output.
- Don't add screenshots or external images.
- Don't lift the example's project-specific prose verbatim. The example is a structural reference, not a phrasing template.
- Don't include a TL;DR at the top. The first section ("Where we were") *is* the lede.
