---
name: visualise-plan
description: Produce a visual HTML implementation plan for a feature BEFORE writing any code. Use this skill whenever the user invokes /ank:visualise-plan, asks for an "implementation plan", says "plan this out before you build it", asks you to "visualise the plan", or otherwise signals they want to review the approach as a document before code is written. The skill assumes all clarifying questions about the feature have already been answered in this conversation — its job is to crystallise that context into a single reviewable HTML file at docs/plan/<feature-slug>.html and then HARD STOP, waiting for the user to type "approved" (or send edits) before any implementation begins.
allowed-tools: Read, Write, Bash, Grep, Glob
---

# Implementation plan

The user has just finished walking you through what they want to build. You probably know more about this feature right now than at any later point in the conversation. Your job is to **freeze that understanding into a single HTML document** they can scroll through on a phone or laptop, push back on, and only then green-light.

You are not implementing yet. You are not allowed to implement yet.

## When this skill runs

By the time this skill triggers, the user has already answered the questions you needed answered — about the feature's behavior, constraints, edge cases, scope. **Do not re-interrogate them.** If something genuinely critical is missing, write the plan with your best assumption, flag the assumption in the Future scope section, and let the user correct you in their review pass. Asking another round of questions before producing the plan defeats the point of the skill.

## What you produce

A single self-contained HTML file at:

```
docs/plan/<feature-slug>.html
```

`<feature-slug>` is a short kebab-case name for the feature (e.g. `comment-threads`, `bulk-export`, `oauth-pkce`). If the user gave you a name, use theirs.

The file is self-contained: no external CSS, no external JS, no image hosts. Everything inline. The reviewer should be able to open it offline.

A starter template lives at `references/template.html` in this skill. **Read it before writing.** It defines the visual style — the Botanical Almanac aesthetic (deep forest-green ink on bone paper, terracotta accent), monospace headings on serif body, the bubble row, and the architectural SVG conventions — and you should match that style precisely. The template is a scaffold, not a straitjacket: add sections if the feature needs them, drop a section if it genuinely doesn't apply (but say why in a one-liner rather than silently omitting).

## Required sections, in order

### 1. Title block
- Project name (eyebrow), feature title (h1).
- A short "Prompt" block restating what was asked — one paragraph, in the user's voice if possible. This is what the reviewer reads first to remember what this plan is even about.

### 2. Highlight bubbles
A row of small rounded chips showing the at-a-glance stats. Pick the ones that actually matter for this feature; typical ones:
- Effort (e.g. "~2 weeks", "~3 days")
- Files added / Files updated / Files removed (numbers)
- Surfaces or packages touched
- New tables / migrations (if backend)
- Feature flag name (if behind one)
- External dependencies added

Aim for 4–6 bubbles. Anything that takes more than a few words doesn't belong in a bubble — put it in a section.

### 3. Milestones / Targets
Slice the work into independently reviewable chunks, rendered as a **timeline**: left-aligned date column, vertical rail with bullet dots in the middle, content on the right. The first milestone (the foundation slice that's actively about to start) uses a filled green dot; later ones add `class="upcoming"` to the `.milestone` for the terracotta-ring dot.

For each milestone:
- A timestamp or order marker in `.when` ("Week 1 · Mon–Tue", or just "Slice 1")
- A short title in `<h3>` inside `.body`
- 1–2 sentences on what lands and what's user-visible
- Tag chips for the packages / paths it touches

Order them so each slice is shippable on its own (even if behind a flag). The reviewer is going to use this section to decide whether to break the work into separate PRs.

### 4. Data flow
**This is the section the reviewer cares about most.** It shows how the new feature plugs into the existing codebase — which existing modules get called, what new modules get introduced, and the direction of data and method calls.

Render it as an inline SVG inside the `.flow` container. The visual language is **architectural**: thick rectangular boxes, deliberate placement, no decoration, no curves-for-curves'-sake, no soft shadows on diagram elements. The template provides these classes — use them:

- **Existing modules**: `class="node"` (ink stroke, 2.5px). Always show the ones the new feature touches.
- **New modules**: `class="node-new"` (terracotta stroke, 2.5px). Visually distinct from existing.
- **Box label**: `class="node-label"` (mono, 12px) — the module/file name (e.g. `<CommentComposer>`, `comments.create`).
- **Box sublabel**: `class="node-sub"` (mono, 10px) — its package or path (e.g. `apps/web`, `packages/api`).
- **Sync edges**: `class="stroke-solid"` — synchronous request/response, direct method calls.
- **Async edges**: `class="stroke-dash"` — async, fire-and-forget, realtime fan-out, queued work.
- **Edge labels**: `class="edge-label"` — the operation name ("optimistic insert", "broadcast", "INSERT").

Layout rules:
- Use 90° angles for connectors. No diagonals unless absolutely necessary.
- Boxes line up on a visible grid — keep x/y coordinates on multiples of 10 or 20.
- Leave breathing room. A diagram with 6 boxes and lots of whitespace beats one with 12 crammed boxes.

If the feature has two distinct paths (write path + read path, or sync + async), put them side by side in the same SVG with a short legend underneath. The template already includes a default legend ("Solid = request/response. Dashed = async / fire-and-forget. Terracotta border = new module.") — keep it, but feel free to add a feature-specific line.

A reviewer should be able to trace a request from UI → API → persistence → fan-out by following the arrows, and know which files to open during code review.

### 5. Mockup
A visual of what the feature looks like to a user. Render it in plain HTML/CSS inside the `.mock` container — not a screenshot, not an external image. Lo-fi is fine; pixel-perfect is wasted effort here. Goals:
- Show placement, hierarchy, empty state, error state if relevant.
- If the feature has multiple surfaces (e.g. a primary view + a notification/sidebar), include both, labeled "A ·" and "B ·".

For purely backend features, skip this section but say so explicitly with a one-line "No UI surface — backend only."

### 6. Files added / updated / removed
A flat list, grouped by operation. For each file:
- The operation tag (`add` / `update` / `remove`)
- The full path
- One line on why this file exists / what changes / why it's being removed

Don't list every test file or every type definition — list the files a reviewer should open to understand the change. If a file's only purpose is "barrel export," skip it.

### 7. Key code
The 1–3 snippets most likely to be done wrong if left unspecified. Examples of what belongs here:
- A migration with non-obvious constraints (soft deletes, composite keys, indexes).
- An optimistic-update hook where temp-id reconciliation is easy to mess up.
- A reducer or state machine where the transitions matter.
- A regex or parser where the edge cases matter.

Examples of what does NOT belong here:
- Boilerplate CRUD.
- Standard component scaffolding.
- Anything the reviewer can write correctly on autopilot.

Each snippet gets a caption with its file path, then a `<pre class="code">` block. Keep snippets short — under ~25 lines each. If a snippet is longer than that, it's probably doing too much.

### 8. Future scope
What's deliberately out of scope, what assumptions you made, and what's worth revisiting after v1. For each item:
- A short title (often phrased as a question)
- A paragraph on the tradeoff
- A "Decide with · who · when" meta line if it has an owner or deadline

This is also where you flag any assumption you had to make because the conversation didn't pin it down. Flagging it here is much better than blocking on another round of questions.

## Style requirements — Botanical Almanac

The template at `references/template.html` is the source of truth for style. The palette and treatment is fixed — do not improvise alternate colors or "modernize" the look:

- **Background** `#f5f0e1` (bone paper) · **panels** `#fbf8ec` (slightly lighter) · **prompt panel** `#f1ead5` · **bubbles** `#fff`
- **Ink** `#1a2e1f` (deep forest green) for all primary text and strokes
- **Soft ink** `#5a6b5a` (muted green-gray) for secondary text, sublabels, captions
- **Rule** `#d8cfb4` — thin 1px borders for cards/panels/dividers
- **Accent** `#b4541a` (terracotta) — used only for: the `Prompt` label, new-module borders in the data flow, upcoming-milestone dot rings, and optional code keyword tint. Don't sprinkle it elsewhere.
- **Typography**: **serif for all body and headings** (`"Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif`). H1 is 40px/600, H2 is 26px/600, H3 is 17px/600 — the serif weight does the work. Monospace (`ui-monospace, "JetBrains Mono", Menlo, monospace`) is reserved for: the eyebrow line, section-number chips, bubble labels/values, file paths, tags, code, SVG text, and `<code>` spans.
- **Panels** (bubbles, flow box, mockup box, code block, prompt box): flat — 1px `--rule` border, 8–12px radius, **no offset shadow**. The previous "clay shadow" look has been retired in favor of cleaner cards.
- **Prompt** sits in a `.prompt-box` (soft paper-soft background, rounded) with a small terracotta uppercase "PROMPT" label above the paragraph. Not a left-bar italic quote.
- **Section numbers** (`01`, `02`, …) render as a small monospace chip with `--tag-bg` background, placed inline next to the `<h2>` via a `.section-head` flex row.
- **File operation colors**: `add` → `#2d5938` (deep green), `update` → `#856104` (amber), `remove` → `#8a3320` (rust).
- Mobile-friendly: max-width 760px, single column, viewport meta tag present.
- **Sentence case** in headings and labels — never Title Case, never ALL CAPS (except the tiny letter-spaced eyebrow lines).
- No JavaScript. Pure HTML + inline CSS + inline SVG. No external fonts, no CDN.

## The hard stop

After you write the file:

1. Confirm the file path in chat: `Written: docs/plan/<feature-slug>.html`.
2. List the section headings you ended up with so the user knows what to scroll to.
3. **Stop.** Do not start implementing. Do not write code. Do not edit other files.
4. End your message with:
   > Review the plan and reply with **"approved"** to start implementation, or send edits and I'll revise the plan.

If the user replies with anything other than an explicit approval ("approved", "ship it", "go ahead", "lgtm proceed"), treat it as edits to the plan — revise the HTML and stop again. Repeat until they approve. Only then proceed to implementation.

This stop is not negotiable. If the user prepends "skip the plan, just build it" to their initial request, that's a separate flow and this skill shouldn't have triggered in the first place — back out gracefully.

## A note on the questions you're tempted to ask

If you find yourself wanting to ask the user "what about X?" before writing the plan, ask whether X is something the plan itself can surface. Usually it is — write the plan with your best assumption, put the assumption in Future scope, and let the user correct it during review. The whole value of this skill is that the HTML *is* the conversation; questions you ask in chat are questions that won't be visible when the user scrolls back to the plan later.
