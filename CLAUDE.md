# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of Claude Code skills (branded **ANK Skills**). Plugin name: **`ank`**. The first and currently only skill is `/review-board`, which generates a single-file HTML "story-paced walkthrough" of a finished feature for human code review.

There was an original `build_plan.md` that scaffolded the repo; it has been removed. This file is now the source of truth for layout, constraints, and decisions.

## Install paths (both supported)

1. **Claude Code plugin** — `.claude-plugin/marketplace.json` is the catalog (marketplace name: `ank-skills`); `.claude-plugin/plugin.json` describes the plugin itself (plugin name: `ank`) and explicitly lists each skill's path. Install: `/plugin marketplace add ananthanandanan/skills` then `/plugin install ank@ank-skills`. Skills end up namespaced as `/ank:<skill>`.
2. **Vercel Labs installer** — `npx skills@latest add ananthanandanan/skills` reads the `skills/<category>/<name>/SKILL.md` layout directly and ignores both JSON files.

When adding a new skill, update `.claude-plugin/plugin.json`'s `skills` array so the plugin install path picks it up. Skills must be listed explicitly because they're nested under `skills/<category>/<name>/` rather than directly under `skills/<name>/`, and Claude Code's auto-discovery only walks one level.

## Repo layout (load-bearing)

```
.claude-plugin/
  ├── marketplace.json                     # marketplace catalog (what `/plugin marketplace add` reads)
  └── plugin.json                          # plugin manifest (name, version, explicit skills array)
skills/<category>/<name>/
  ├── SKILL.md                             # YAML frontmatter + body
  ├── examples/                            # concrete reference outputs the model pattern-matches against
  └── scripts/                             # helper shell scripts the SKILL.md invokes
```

Categories use buckets like `engineering/`, `productivity/`, etc. `/review-board` lives at `skills/engineering/review-board/`.

The `skills/<category>/<name>/` convention is required for `npx skills` compatibility. Don't flatten it.

## Reference artifact

The visual + structural target for `/review-board` output lives in-repo at:

```
skills/engineering/review-board/examples/walkthrough-example.html
```

This file is the gold standard (originally Reigner T-05). The model opens it at runtime, copies the `<style>` block and scroll-spy `<script>` **verbatim** into new walkthroughs, and pattern-matches the structure, callout density, and section arc. The example's *content* is T-05-specific — only the *shape* carries over. There is no separate template; the example *is* the template.

The CSS classes are load-bearing: callout types (`why` / `tradeoff` / `deferred`), status pills (`good` / `warn` / `bad` / `accent`), sticky sidebar, scroll-spy. Don't rename them.

## Hard constraints for `/review-board` output

- Single-file HTML; no external CSS, JS, fonts, or images.
- Every Why/Tradeoff/Deferred callout must have a real cause — no padding.
- Every status pill must reflect actual code state (no aspirational `live` pills for stubs).
- Don't invent file paths, line numbers, or test counts — grep first.
- The doc is a finished-feature artifact, not CI output. Don't regenerate per commit.
- Don't paste the full diff into the HTML; the reviewer has GitHub for line-by-line.

## SKILL.md authoring rules

- Frontmatter must include `name` and `description` (CI fails otherwise — see `.github/workflows/validate.yml`).
- `description` must be specific enough for the model to decide when to invoke the skill on its own. Say *what it produces and when* — not "helps with reviews".
- `allowed-tools` should be the minimum set the skill actually needs.

## Common commands

Validate all `SKILL.md` frontmatter locally (same check CI runs):

```bash
python - <<'PY'
import pathlib, yaml, sys
required = {"name", "description"}
fail = False
for p in pathlib.Path("skills").rglob("SKILL.md"):
    text = p.read_text()
    if not text.startswith("---"):
        print(f"missing frontmatter: {p}"); fail = True; continue
    data = yaml.safe_load(text.split("---", 2)[1]) or {}
    missing = required - data.keys()
    if missing:
        print(f"{p}: missing {missing}"); fail = True
sys.exit(1 if fail else 0)
PY
```

Smoke-test a skill end-to-end: from another repo with a finished feature, run `/review-board` and confirm `docs/review/<slug>.html` resembles the reference.

Test the install path:

```bash
npx skills@latest add <gh-handle>/<repo>
# confirm ~/.claude/skills/review-board/ (or .claude/skills/review-board/) appears
```

## Deliberately out of scope

No second skill until there's a real use case. No theming options. No own npm package. No docs site. No telemetry. Resist scope creep.
