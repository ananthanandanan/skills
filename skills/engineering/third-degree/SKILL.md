---
name: third-degree
description: Interview the user to converge on a shared, concrete understanding of a feature before any planning or implementation — the front of the ank pipeline (third-degree → visualise-plan → review-board). Use whenever the user invokes /ank:third-degree, says they have a "rough idea", asks you to "flush out the requirements", "interview me", "interrogate me", or otherwise signals the spec is fuzzy and needs pinning down before code or a plan is written.
allowed-tools: Read, Bash, Grep, Glob, AskUserQuestion
---

# Third degree

The user has an idea but hasn't pressure-tested it. Interview them relentlessly — **one question at a time** — walking down each branch of the decision tree and resolving dependencies between decisions as you go. Before every question, grep the codebase for an existing convention, prior decision, or analogous feature that already answers it; if you find one, state the inferred answer in a single line ("Inferring X from `path/to/file` — say so if wrong.") and move on without asking. When you must ask, use `AskUserQuestion` with 2–4 concrete options and put your **Recommended** pick first with a one-line reason — never an open-ended prompt; structured options converge faster than free text. Keep going until you have genuine shared understanding — no fixed cap, but stop the moment further questions would just be ceremony. End by echoing back a tight bulleted summary of the resolved spec and asking "ready for /ank:visualise-plan?" — do **not** start planning or coding inside this skill.
