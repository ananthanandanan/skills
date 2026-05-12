---
name: handoff
description: Generate a Markdown handoff document summarizing the current conversation so another agent (Claude, Codex, opencode, pi, ampcode, Cursor, or a fresh session) can resume without re-deriving context. Produces docs/<slug>-handoff.md. Invoke explicitly when a session is near its context limit.
disable-model-invocation: true
allowed-tools:
  - Bash(ls *)
  - Bash(mkdir *)
  - Bash(git rev-parse *)
  - Bash(git symbolic-ref *)
  - Write
---

# handoff

This skill runs **when context is nearly exhausted**. Budget is the constraint. Draft from what's already in conversation context — do not re-read files, do not grep, do not ask interview questions, do not run a self-check pass. One `Write` call is the goal.

## Output path

`docs/<slug>-handoff.md` where `<slug>` is a 2–3 word kebab-case identifier derived from the session's main agenda (or the user's freeform argument to the slash command, if given).

- Lowercase, alphanumeric + hyphens only.
- If the file exists, append `-2`, `-3`, … — never clobber.
- `mkdir -p docs` if needed.

## Audience

Another LLM coding agent with Read/Write/Bash but **zero prior context**. Write for them: concrete paths, exact commands, exact error strings. No prose pleasantries, no recap of the dialogue.

## Sections (in order)

Include only sections with real content. Omit or write `None this session.` for empty ones — never pad.

1. **Header** — one-line crux (what this session was about), branch, date, working dir.
2. **Agenda** — 2–4 sentences on the goal.
3. **Files read** — bullet list: path + half-sentence on why it mattered.
4. **Files written / edited** — table: `File | Change`.
5. **Bugs found** — symptom + root cause (if known) + file:line.
6. **Fixes made** — what was broken + the fix + where.
7. **Skills used** — `/ank:<skill>` invocations + outcome. Omit if none.
8. **Links / references** — URLs, issue/PR numbers, doc paths.
9. **Key decisions** — non-obvious choices + *why*. Prevents re-litigation.
10. **Current state** — what works, what's half-done, what's untested. Quote actual build/test output if you ran any; say so if you didn't.
11. **Open questions / not done** — explicit gaps, deferred items.
12. **Next steps** — concrete, ordered. Each item must be actionable without a clarifying question (e.g. "read `frontend/lib/auth.ts` and trace `refreshToken()`" — not "figure out auth"). Write this last.

**Optional** (include only if substantial and quick to produce): a fenced ASCII layout/architecture diagram, key types/state shape, or API surface touched.

Shape: tables for file lists, fenced ASCII for diagrams, short headers, no filler prose.

## Constraints

- **Markdown only.** No HTML, images, or external assets.
- **No invented paths, line numbers, commits, or counts.** If unsure, omit — don't verify, you don't have the budget. The receiving agent will grep.
- **No transcript dump.** Distill the work, not the dialogue.
- **No interview.** Use the user's slash-command argument if given; otherwise derive the slug and crux yourself.
- **No self-check pass.** Get the file written.
- **Don't run builds, tests, or migrations** to populate the doc. Report state as observed.
