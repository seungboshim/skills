# Claude Code Skills

[한국어](README.md) | [English](README.en.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

A collection of Claude Code skills by [@seungboshim](https://github.com/seungboshim).

<p align="center">
  <strong>korean-tone has moved to its own repository →
  <a href="https://github.com/fromshim/korean-tone">fromshim/korean-tone</a></strong><br>
  <code>/plugin install korean-tone@fromshim</code>
</p>

---

## Skills

### korean-tone → [fromshim/korean-tone](https://github.com/fromshim/korean-tone)

Makes Claude sound fluent in Korean without translating away the identifiers you need to
grep. Ships a writing skill plus a non-blocking `tone-linter` hook. Now maintained in its
own repository; still listed in this marketplace for convenience.

### shimmy-tone

A personal dev-blog writing voice — everyday analogies, bait-and-switch titles, memes and
emoji to teach hard concepts. Layers on top of korean-tone: the translationese ban stays,
but the "go easy on emoji" guard is deliberately lifted.

### feature-flow

Full-cycle guide for building a single screen/feature — from scope and planning through execution, review, commits, and documentation.

- 9 steps with explicit human checkpoints at each transition
- Karpathy 4-principle self-monitoring during execution (Think / Simple / Surgical / Goal-driven)
- Optional documentation step with `_inbox/{research,spec,patch,scratch}` → `research-notes/`/`feature-specs/` promotion flow
- Project-agnostic — adapts to your existing conventions

### feature-flow-superpowers

Superpowers-extended variant of feature-flow. Same step structure but each step explicitly calls matching superpowers skills.

- Requires the [superpowers](https://github.com/obra/superpowers) plugin
- TDD-first execution via `superpowers:test-driven-development`
- Evidence-based completion via `superpowers:verification-before-completion`
- Explicit resolution of 4-principle ↔ TDD overlap

### daily

Session orientation + work recommendation — reads the backlog, recent patch notes, and git state to produce a quick "where am I" map and a prioritized "what to work on" list.

- Read-only — orients and recommends, never edits files
- Discovers your backlog/patch conventions (project-agnostic)
- Pairs with feature-flow as the cycle entry point

### worklog

Post-work documentation ritual — a concise release-note patch note + feature-spec update (when behavior changed) + backlog tick, in one pass.

- Decoupled from the full cycle — call it after any chunk of work
- Project-agnostic — discovers your doc conventions
- Pairs with feature-flow as the cycle exit point

### tailwind-design-system

Design system builder and refactorer for Tailwind CSS + Next.js projects.

- Guides from initial design prompting through style audit, semantic token definition, shared component extraction, migration, and ongoing compliance review
- Supports new projects (Phase 0: design prompting) and existing projects (Phase 1: style audit)
- Ongoing audit mode for design token compliance

---

## Installation

### Via Claude Code plugin (recommended)

```bash
/plugin marketplace add seungboshim/skills
/plugin install shimmy-tone@seungboshim-skills
```

Install only what you want:

```bash
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```

### Via skills.sh (any agent)

```bash
npx skills add seungboshim/skills
```

Works outside Claude Code too.

> korean-tone lives in [fromshim/korean-tone](https://github.com/fromshim/korean-tone) —
> install it from there to get its `tone-linter` hook set up automatically.

## License

MIT
