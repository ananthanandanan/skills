---
name: spec
description: Turn a rough product idea (or the output of /ank:third-degree) into a single, opinionated SPEC.md that serves as the source of truth for an entire product or feature. Use whenever the user invokes /ank:spec, says "let's design this", "draft a spec", "write the design doc", "turn this into a tech spec", or otherwise signals they want the idea crystallised into a reviewable document before tasks or code. The skill produces ONE file (SPEC.md at repo root for product-level specs, or docs/spec/<slug>.md for feature-level) and then HARD STOPS, waiting for explicit approval before any downstream skill (/ank:tasks) runs.
allowed-tools: Read, Write, Bash, Grep, Glob, AskUserQuestion
---

# Spec

The user has an idea — either fresh, or already pressure-tested via `/ank:third-degree`. Your job is to **freeze that idea into a single SPEC.md** that's sharp enough to drive task breakdown and implementation without further interrogation.

You are **not** writing tasks. You are **not** writing code. You are not even sketching the package layout in chat — you put it in the file.

## Pipeline position

```
/ank:third-degree  →  /ank:spec  →  /ank:tasks  →  (build with Claude Code)  →  /ank:review-board
   (interview)        (this)       (issues +     (implementation)             (post-feature
                                    scaffold)                                  walkthrough)
```

If the conversation already contains a third-degree summary, **use it as the analysis input** — do not re-interview. If it doesn't, do the deep analysis pass yourself (Stage 1 below) but resist the urge to ask more than 2-3 clarifying questions. The spec itself is the place to surface assumptions, via the Open Questions section.

## Where the spec lives

| Scope | Path | Trigger |
|---|---|---|
| Product-level (the whole thing) | `./SPEC.md` at repo root | Default. Use when the idea defines a new product, library, service, or app. |
| Feature-level (one slice) | `./docs/spec/<slug>.md` | Use when the user explicitly says "feature spec" or the work is scoped inside an existing product that already has a `SPEC.md`. |

If `SPEC.md` already exists at root and the user is starting fresh, ask once whether to overwrite or write the new one to `docs/spec/<slug>.md`. Never silently overwrite.

## Two shapes the skill supports

The required section list below is the union of what a strong **library/SDK spec** and a strong **SaaS/app spec** each need. Different products lean on different sections:

- **Library/SDK/CLI shape** — leans on sharp Is/Isn't, design principles, public API at a glance (a code snippet showing what using it feels like), module-by-module breakdown, acceptance criteria as testable conditions, decision log of open questions.
- **SaaS/app shape** — leans on target personas with concrete budget/constraints, tech stack rationale with comparison tables, data model, API endpoint enumeration, frontend/UX architecture, pricing model, build priority stack ordered by value-unblocking.

A strong spec borrows discipline from both shapes regardless of product type. Even a SaaS spec benefits from a sharp Is/Isn't; even a library benefits from naming its target user.

## Stages

### Stage 1 — Deep analysis (in chat, no file yet)

Synthesize the idea into a short structured analysis. Cover:

1. **Who hurts and what they're doing today.** Concrete persona(s) with budget/role context if it's a product, or developer profile if it's a library. If you can't name the user, the spec will be muddled — push back now.
2. **What this is, sharply.** One paragraph. If you can't say it without hedging, the idea isn't ready.
3. **What it explicitly isn't.** Scope cuts. The first version of every spec is too big; surface the cuts now.
4. **The riskiest unknowns.** Things that would invalidate the design if wrong. These become Open Questions in the spec.
5. **Suggested shape.** Library vs SaaS vs CLI vs internal service vs hybrid. Drives which conditional sections apply (see below).

Print the analysis in chat. **Stop and let the user redirect.** Do not write the file yet. If they say "looks right, draft it" (or equivalent — "go", "ship the spec", "lgtm"), move to Stage 2.

### Stage 2 — Product-type routing

Before drafting, resolve which conditional sections apply. If not obvious from Stage 1, ask once via `AskUserQuestion` with concrete options:

1. **Product archetype** — Library/SDK · CLI tool · SaaS application · Internal service · Hybrid
2. **Surfaces present** (multi-select if you ask) — Has a UI · Has persistent storage (DB) · Exposes HTTP/RPC routes · Has a commercial pricing model

Use Stage 1's analysis to skip this step entirely when the answer is clear (e.g., user said "I want to build a CLI" → no UI, no DB, no pricing).

### Stage 3 — Draft SPEC.md

Write the file. Use **descriptive section names** with numbers (`## 1. Problem & users`, `## 2. Is / Isn't`, …). Plain Markdown, no HTML, no inline images.

#### Required sections — every spec, in this order

1. **Problem & target user(s)** — Who hurts, what they're doing today, what their constraints/budget are. If multiple personas, build for the simplest first and name the monetization/adoption target separately.
2. **Is / Isn't** — Sharp commitment. What this is in two paragraphs; what it explicitly isn't in a bulleted list. Non-negotiable even for SaaS specs — scope creep starts when this section is fuzzy.
3. **Design principles** — Non-negotiables. 5-8 numbered principles each spec module is judged against. These are the rules the spec applies to itself.
4. **Public API / user-facing surface at a glance** — The shortest possible "what does using this feel like" snippet. For a library: a `main.py` example. For a CLI: a command session. For a SaaS: the canonical user journey in 4-6 steps. The reader should understand the product after reading this section alone.
5. **Module / component breakdown** — One subsection per major module. For each: purpose, public types/interfaces, key responsibilities. Sized to fit on one screen per module.
6. **Build priority stack** — Ordered list of features by what unblocks value fastest. *Not* chronological — purely "if you shipped only N features, ship these in this order." Forces ruthless scope cuts.
7. **Build order** — Week-by-week (or phase-by-phase) execution sequence. Differs from §6: this is *when*, that was *what matters most*.
8. **Acceptance criteria** — Testable conditions for "v0 is shippable." 5-10 bullet points, each verifiable by a person or a test. *This is the spec's contract with itself; do not skip.*
9. **Open questions** — Decision log. Each question is a real fork (not a placeholder). Format: numbered list; resolved ones get `✅ Resolved:` prefix with a one-line rationale. The decision log lives in the spec, not in chat.

#### Conditional sections — include only when triggered

| Section | Trigger | Shape |
|---|---|---|
| **Tech stack rationale** | ≥2 candidate technologies for any layer where the choice isn't obvious | Table with "Layer / Choice / Why not the alternative" columns; one row per non-obvious decision |
| **Data model** | Persistent storage present | Table-by-table SQL where the schema matters; fold payload shapes (JSONB, message envelopes) into the module that owns them rather than top-level |
| **API endpoints** | HTTP/RPC routes exposed | Flat list grouped by resource; one route per line (`GET  /api/foo/:id`) |
| **Frontend / UX architecture** | UI present | Project structure tree + one canonical layout (ASCII or prose) + visual treatment rules |
| **Pricing / business model** | Commercial product | Tier table with price + key limits per tier |
| **Success metrics** | Always recommended; required if commercial | PMF/adoption signals for SaaS; install count / adoption metrics for libraries |
| **Glossary** | Spec >10 printed pages OR introduces ≥5 domain terms | Flat term:definition list |
| **Reference mapping** | Spec is a rewrite/extraction of prior art | Old-concept → new-equivalent table |

Place conditional sections after the required nine, in the order listed.

### Stage 4 — Hard stop

After writing the file:

1. Confirm the file path in chat: `Written: SPEC.md` (or `docs/spec/<slug>.md`).
2. List the section headings in the order they appear, so the user knows what to scroll to.
3. Call out any assumption you had to make that surfaced in an Open Question — one line each.
4. **Stop.** Do not run `/ank:tasks`. Do not propose tasks. Do not write code. Do not touch other files.
5. End your message with:

   > Review the spec and reply with **"approved"** to lock it in (then run `/ank:tasks` when ready), or send edits and I'll revise.

Anything other than explicit approval ("approved", "lgtm", "ship it", "lock it in") is treated as edits — revise the file and stop again. Repeat until approved.

## Hard constraints

- **No inline code dumps over ~20 lines.** Describe shapes (type signatures, JSON structure, table columns) but don't paste full model classes, route handlers, or app factories. Those belong in the implementation, not the spec. If a code snippet is critical (e.g., a tricky algorithm, a non-obvious data shape), keep it under 25 lines.
- **Every Open Question is a real fork.** No placeholders, no "TBD." If it doesn't have at least two plausible answers, it's not a question — it's a decision the spec should make.
- **Every Acceptance Criterion is testable.** "Works well" is not a criterion. "5+ of 20 eval cases pass with valid citations" is.
- **Is / Isn't is non-negotiable.** Even for SaaS specs. Specs that omit this section drift in scope as soon as implementation starts.
- **Don't invent API surface.** If you describe a function, type, or endpoint, it must be one the user could plausibly write — not aspirational naming.
- **Don't include scaffolding instructions.** Setup commands, `docker-compose.yml`, dependency lists belong in `TASKS.md` Phase 0, not in the spec. The spec says *what gets built*; tasks say *how to set it up*.
- **Sentence case in headings.** "Public API at a glance," not "Public API At A Glance."
- **Strong opinions; no hedging filler.** If a section ends up generic ("consider various approaches…"), cut it.

## When the user pushes for shortcuts

Common requests to refuse:

- "Just write the spec, skip the analysis" → Do Stage 1 anyway, but inline and short (5-8 bullets). Skipping it produces muddled specs.
- "Make it shorter" → Cut conditional sections that don't apply. Don't cut required ones.
- "Also write the tasks" → No. That's `/ank:tasks`. The hard stop is the point.
- "Add a scaffold/code snippet for X" → If X is non-obvious data shape, keep under 25 lines. If X is boilerplate, refuse and point at the relevant task.

## A note on the analysis you're tempted to do in chat

If you find yourself thinking through tradeoffs in chat ("we could either A or B…"), stop and put the tradeoff in the spec — usually as an Open Question with the two branches, or as a Design Principle if you've decided. Conversation-only reasoning evaporates; the spec is the durable artifact.
