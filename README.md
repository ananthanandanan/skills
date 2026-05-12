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

Skills then appear namespaced as `/ank:review-board`.

**`npx skills` installer:**

```bash
npx skills@latest add ananthanandanan/skills
```

Then pick the skills you want from the interactive list.

## Skills

### Engineering

- [`/review-board`](./skills/engineering/review-board/SKILL.md) — generates a single-file HTML "story-paced walkthrough" of a finished feature for human code review. Sidebar nav, Why/Tradeoff/Deferred callouts, status pills, reviewer's checklist. Use it after finishing a feature or merging a PR, when a teammate needs to understand the *why* and the *shape* of the change, not just the diff.

## Authoring a new skill

Add a directory under `skills/<category>/<name>/` with a `SKILL.md` (YAML frontmatter must include `name` and `description` — CI enforces this), then append the path to the `skills` array in `.claude-plugin/plugin.json`. The `review-board` skill is the reference layout.
