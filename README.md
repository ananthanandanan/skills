# ANK Skills

These are the skills I've formalised to make my own agentic workflow smoother and more efficient. Small, focused, composable — meant to slot into whatever I'm building rather than own the process. If any of them are useful to you too, take them, fork them, change them.

## Quickstart

Pick one of the two install paths:

**Claude Code plugin (native):**

```bash
# In Claude Code:
/plugin marketplace add ananthanandanan/skills
/plugin install ank@ank-skills
```

Skills then appear namespaced as `/ank:<skill>` (e.g. `/ank:review-board`, `/ank:handoff`).

**`npx skills` installer:**

```bash
npx skills@latest add ananthanandanan/skills
```

Then pick the skills you want from the interactive list.

## Skills

### Engineering

- [`/review-board`](./skills/engineering/review-board/SKILL.md) — generates a single-file HTML "story-paced walkthrough" of a finished feature for human code review. Sidebar nav, Why/Tradeoff/Deferred callouts, status pills, reviewer's checklist. Use it after finishing a feature or merging a PR, when a teammate needs to understand the *why* and the *shape* of the change, not just the diff.
- [`/handoff`](./skills/engineering/handoff/SKILL.md) — drops a Markdown handoff doc at `docs/<slug>-handoff.md` distilling the current conversation (agenda, files touched, bugs, fixes, decisions, current state, next steps) so another agent — Claude, Codex, opencode, pi, ampcode, Cursor, or a fresh session — can resume without re-deriving context. Invoke when your context window is nearly full.
- [`/visualise-plan`](./skills/engineering/visualise-plan/SKILL.md) — produces a single-file HTML implementation plan at `docs/plan/<slug>.html` (Botanical Almanac styling: milestones, data-flow SVG, mockups, files-touched list, key code). Invoke *after* the agent has grilled you with clarifying questions but *before* any code is written — then hard-stops until you reply "approved".

## Authoring a new skill

Add a directory under `skills/<category>/<name>/` with a `SKILL.md` (YAML frontmatter must include `name` and `description` — CI enforces this), then append the path to the `skills` array in `.claude-plugin/plugin.json`. The `review-board` skill is the reference layout.
