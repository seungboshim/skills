# Claude Code Skills

A collection of Claude Code skills by [@seungboshim](https://github.com/seungboshim).

## Skills

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

### tailwind-design-system

Design system builder and refactorer for Tailwind CSS + Next.js projects.

- Guides from initial design prompting through style audit, semantic token definition, shared component extraction, migration, and ongoing compliance review
- Supports new projects (Phase 0: design prompting) and existing projects (Phase 1: style audit)
- Ongoing audit mode for design token compliance

## Installation

### Via skills.sh (any agent)

```bash
npx skills add seungboshim/skills
```

### Via Claude Code plugin

```bash
/plugin marketplace add seungboshim/skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```
