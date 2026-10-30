# Rule library

The only behavioural rules this skill may add. Each entry has:

- **Add when**: the repo signal that makes the rule earn its place. If the signal is absent, skip the rule.
- **Skip when**: the existing file already covers it, or the repo makes it irrelevant.
- **Text**: the wording to insert. Adapt nouns to the repo (real command names, real paths). Keep the length.
- **Why**: for the plan you show the user. Never paste the "Why" into the target file.

Rules are numbered by priority. Under a tight line budget, cut from the bottom.

---

## Core rules

### R1. Prior art before scratch

- **Add when:** the repo builds features (not a docs-only or config-only repo).
- **Skip when:** the file already tells the agent to research before building.
- **Text:**
  > For a feature you haven't built before, search GitHub and the package registry for existing implementations first. Compare two or three approaches in a short note, then build. Prefer a maintained library over hand-rolled code unless the dependency cost is higher than the code.
- **Why:** An agent writing from scratch reinvents solved problems and misses edge cases that mature projects already handle. Comparing approaches first also shows the user the options before code locks one in.

### R2. Decide for the user, the developer, and the agent

- **Add when:** always a candidate. This is the checkable version of "elevate UX, DX, and AX without breaking anything".
- **Skip when:** the file already defines how to choose between approaches.
- **Text:**
  > When two approaches are both correct, choose the one that is better for the end user, then for the developer who maintains it, then for the next agent that reads it (greppable names, one obvious entry point, scripts instead of steps that live only in someone's head). If those pull in different directions, name the trade-off in your reply. "Don't break anything" means existing tests pass and public APIs, CLI flags, config keys, and stored data stay compatible unless the task says otherwise.
- **Why:** An instruction like "elevate UX, DX, and AX always" gives the agent nothing to check, so it changes nothing. A tie-break order plus a definition of "breaking" gives the agent something it can verify.

### R3. Verify before claiming done

- **Add when:** the repo has a test, build, typecheck, or lint command.
- **Skip when:** the file already has a definition of done that requires running checks.
- **Text:**
  > Before saying a task is done, run `<test command>` (and `<typecheck/lint command>` if relevant) and report what ran and what passed. If you could not run a check, say so plainly. Never write "should work" in place of a result.
- **Why:** Premature "it's done" claims are the most common complaint about coding agents. Naming the exact command removes any excuse to skip it.

### R4. Surgical changes

- **Add when:** always a candidate.
- **Skip when:** the file already limits the scope of edits.
- **Text:**
  > Change only what the task needs. No drive-by refactors, renames, reformatting, or dependency bumps. If you spot an unrelated problem, mention it at the end of your reply instead of fixing it.
- **Why:** Unrelated edits make diffs hard to review and hide regressions. This rule keeps every diff the size of its task.

### R5. Ask when the fork matters

- **Add when:** always a candidate.
- **Skip when:** the file already says when to ask the user and when to proceed.
- **Text:**
  > If a requirement can be read two ways and the readings lead to different code, ask one question before building. If the choice is low-stakes or easy to reverse, pick the conventional option and say which one you picked.
- **Why:** Silent assumptions are expensive to unwind after the code is written. But asking about everything makes the agent slow, so the rule says when asking is worth it.

### R6. Simplest thing that works

- **Add when:** always a candidate.
- **Skip when:** the file already bans speculative abstraction.
- **Text:**
  > Write the simplest code that solves the task. No abstractions, config options, or fallback paths for cases the task doesn't have. Three similar lines are better than a premature helper.
- **Why:** Agents over-engineer by default: wrapper classes, unused options, defensive branches for impossible states. Each of these is code someone has to maintain.

### R7. Don't loosen these rules

- **Add when:** always, if any other rule from this library is added.
- **Skip when:** the file already forbids the agent from editing its own instructions.
- **Text:**
  > Never edit this file to make it match what you just did. If a rule here is wrong or blocks the task, stop and propose the change to the user.
- **Why:** Agents have been seen breaking a rule and then rewriting the instruction file to fit what they did. One sentence prevents it.

---

## UI rules

Add only when the repo has a frontend: a `components/`, `app/`, `pages/`, or `src/ui/` directory, or a dependency on React, Vue, Svelte, Solid, Angular, SwiftUI, Jetpack Compose, or Flutter.

### U1. Fix the layout, not the copy

- **Text:**
  > Cut taglines, helper text, and secondary labels. If a screen needs them to make sense, fix the layout instead. Every visible string must be the label, the data, or the error.
- **Why:** Agent-built UIs pile up explanatory text to make up for unclear hierarchy. Banning the text forces the agent to fix the hierarchy.

### U2. Real states, not happy paths

- **Skip when:** the repo has no data fetching or async UI.
- **Text:**
  > Every view that loads data handles loading, empty, and error states. No lorem ipsum or placeholder copy in committed code.
- **Why:** Agents build the happy path and stop. The other states are where users get stuck.

---

## Repo facts (extract, never invent)

These are not rules from a library. They are facts the agent can't work out from the code, read from the repo itself. Only add a fact you confirmed by reading a file.

| Fact | Where to find it | Example line |
|---|---|---|
| Package manager | lockfile (`pnpm-lock.yaml`, `uv.lock`, `poetry.lock`, `Cargo.lock`, `bun.lockb`) | `Use pnpm, not npm or yarn.` |
| Exact commands | `package.json` scripts, `Makefile`, `justfile`, `pyproject.toml`, CI workflow steps | `Test: pnpm test -- --run` |
| Single-test command | test runner config | `One file: pnpm vitest run path/to/file.test.ts` |
| Do-not-touch paths | generated dirs, `vendor/`, migrations already applied, files with a "generated" header | `Never hand-edit src/gen/ (regenerate with pnpm codegen).` |
| Non-obvious env setup | `.env.example`, `docker-compose.yml`, README setup section | `Tests need Postgres: docker compose up -d db` |

Prefer the command CI runs over the one the README mentions. CI is the one that is actually checked.

---

## Never add

- Generic quality advice the agent already follows: "write clean code", "use descriptive names", "add comments", "follow best practices".
- Directory tours and architecture overviews the agent can get from `ls` and reading the code. Research found they don't help agents find files faster and they raise cost.
- Personality or tone instructions unrelated to code quality.
- Rules that need a tool to enforce them ("always run prettier after editing"). Suggest a hook instead.
- Anything from this library whose "Add when" signal is missing.
