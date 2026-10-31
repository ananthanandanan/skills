---
name: enhance-instructions
description: Audit and improve a repo's agent instruction files (CLAUDE.md, AGENTS.md) — prune what hurts, add a small set of proven working rules (prior-art search before building, verify before claiming done, surgical changes, UX/DX/AX tie-breaks, UI copy discipline), and pull exact commands and do-not-touch paths from the repo itself. Use whenever the user invokes /ank:enhance-instructions, or says "improve my CLAUDE.md", "enhance AGENTS.md", "audit my agent instructions", "my CLAUDE.md is ignored", or "set up agent rules for this repo". Shows a remove/rewrite/add plan and hard-stops for approval before editing.
allowed-tools:
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Bash(ls *)
  - Bash(wc *)
  - Bash(git ls-files *)
  - Bash(git log *)
---

# Enhance instructions

Make the file **shorter and sharper**. Agents follow these files and pay for every line on every task, and LLM-generated instruction files measurably lower agent success. A line stays only if it changes behaviour and the agent can't learn it from the code. A run that only appends has failed.

## 1. Find and read

- Find root `AGENTS.md` and `CLAUDE.md`, then `.claude/rules/`, `CLAUDE.local.md`, and nested copies. Touch nested files only to report contradictions.
- If both root files exist, they get the same content. Audit their combined lines once, and plan and apply one result to both. Never reduce one to an `@` import or pointer to the other. If one is a symlink to the other (`ls -l`), edit the target only. If neither exists, propose creating both with the same content.
- Read the repo signals: lockfiles, manifests, `package.json` scripts, `Makefile`, CI workflows (CI commands beat README commands), generated or vendored paths, and existing hooks in `.claude/settings.json`.

## 2. Audit every line

- **Remove:** generic advice the agent already follows, directory tours the tree already shows, duplicates.
- **Fix or remove:** claims the repo contradicts. Check that each path and command exists, then check what the file says about it against the file that defines it: what a script runs (`package.json`, `Makefile`), which configs exist or don't, versions, ports. Claims that something is absent count too. Out-of-date lines usually come from commits made after the instruction file's last edit, so use `git log` to compare its last commit with later changes to manifests, CI, and config, and check those first.
- **Rewrite:** vague aspirations ("be thorough") into something checkable.
- **Move to a hook:** "always run X after editing".
- **Ask:** contradictions, including file vs repo ("use npm" with a pnpm lockfile).
- **Keep:** the user's own specific, true rules, in their wording.

## 3. Pick additions

Add behavioural rules only from `references/rule-library.md`, and only when the rule's **Add when** signal is present and the file doesn't already cover it. If an existing line covers a rule only in part, rewrite that line to cover the rest instead of adding the rule as a new line, and keep the user's wording where you can. Fill in real commands and paths. Add repo facts only if you read them in a file this run. Keep the final file at 150 lines or fewer, cutting library rules from the bottom first. Propose anything outside the library separately as "not from the library".

## 4. Show the plan, then stop

```
AGENTS.md — 212 lines → 88 lines
Remove   L12-30 directory tour (tree shows it) · L41 "write clean code" (generic)
Rewrite  L8 "elevate UX always" → R2
Add      R1 · R3 with `pnpm test -- --run` · Don't touch: src/gen/ (`pnpm codegen`)
Hook     "run prettier after edits" → PostToolUse on Edit|Write
Ask      L15 says npm, lockfile is pnpm. Which is right?
```

Every item needs a short reason. A group with more than three items goes one item per line, indented under its label. Make no edits until the user says "approved" and has answered every **Ask**.

## 5. Apply

Edit in place and keep the user's structure. With both root files, write the same final content to each. Put added rules in one flat list under `## Working rules`, and put facts under `## Commands` and `## Don't touch`, or under existing sections like them. No intro, no summary, no citations, and never the library's **Why** text. Don't install hooks unless asked. Report the line counts and the changes in chat.

Running the skill again on its own output should give "no changes" or close to it.
