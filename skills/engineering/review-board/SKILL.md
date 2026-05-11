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

**Before generating, open the reference example at `examples/walkthrough-example.html`.** It is the visual + structural target — pattern-match against it. Copy its `<style>` block and scroll-spy `<script>` **verbatim** into the new document. Match its shape: sticky sidebar with numbered TOC, scroll-spy active highlighting, story-paced sections, Why / Tradeoff / Deferred callouts, status pills, ASCII diagrams in the architecture section. The example's content is Reigner-specific (task T-05) — *the structure, voice, and density carry over; the words do not*.

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

Use `AskUserQuestion` for the things you can't infer from code. Skip any question whose answer is obvious from commit messages or the PR body — don't interrogate.

- **Headline.** "In one sentence: what does this change do, and why?" → opening paragraph of section 1.
- **Most non-obvious decision.** "What's the call here that another engineer wouldn't make by default?" → becomes a `callout.why`.
- **Tradeoff accepted.** "What did you give up to make this work?" → becomes a `callout.tradeoff`.
- **Deliberately deferred.** "What did you scope out on purpose?" → becomes the Deferred section and `callout.deferred` entries.
- **Reviewer focus.** "What specifically should the reviewer scrutinize?" → becomes the Reviewer's checklist.

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

- Branch mode: `<slug>` = current branch name with `/` replaced by `-` (e.g. `ananthanandanan/t-05-feat-agent-loop` → `ananthanandanan-t-05-feat-agent-loop`).
- PR mode: `<slug>` = `pr-<number>`.

Create `docs/review/` if it doesn't exist.

## Hard constraints

- **Single-file HTML.** No external CSS, JS, fonts, or images.
- **Copy the `<style>` block and scroll-spy `<script>` verbatim** from `examples/walkthrough-example.html`. Do not rewrite, retheme, or trim the CSS — visual consistency across walkthroughs is a feature. Replace the sidebar TOC, header (title / task ID / issue / PR / branch / commit / header pills), and `<section class="story-section">` bodies with content for the current feature. Keep the same set of CSS classes (`callout.why`, `callout.tradeoff`, `callout.deferred`, `pill.good/warn/bad/accent`, `diagram`, `pillrow`, `compact`, etc.).
- **Every Why/Tradeoff/Deferred callout must have a real cause.** No padding. If you can't write the *why* in one sentence, the callout doesn't belong.
- **Every status pill must reflect actual code state.** No aspirational `good` pills on stubs. If a module is partial, use `warn` and say so.
- **Don't invent file paths, line numbers, or test counts.** If you're not sure, grep first.
- **Don't paste the full diff into the HTML.** The reviewer has GitHub for line-by-line.
- **Don't generate a generic "this PR adds X" summary.** That's what the GitHub PR body is for. The walkthrough is for the why and the shape.

## What NOT to do

- Don't regenerate the doc on every commit. This is a finished-feature artifact, not CI output.
- Don't add screenshots or external images.
- Don't lift Reigner/T-05 prose from the example. The example is a structural reference, not a phrasing template.
- Don't include a TL;DR at the top. The first section ("Where we were") *is* the lede.
