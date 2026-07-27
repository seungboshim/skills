# Claude Code Skills

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

A collection of Claude Code skills by [@seungboshim](https://github.com/seungboshim).

---

## ⭐ korean-tone — when Claude's Korean reads like machine translation

> **"이 함수에 대해 리팩토링을 진행하겠습니다"**
>
> This is how Claude writes Korean by default. The meaning is right, but no human talks
> like that. korean-tone strips the stiffness — **and leaves the code and the precision alone.**

### What changes

```diff
- 이 함수에 대해 리팩토링을 진행하겠습니다.   ("I will proceed with refactoring of this function")
+ 이 함수를 리팩토링할게.                      ("I'll refactor this function")

- handler 가 stub 이었다.
+ 웹훅을 받아놓고 저장을 안 했어. 껍데기만 있고 안이 비어 있던 거지.
  (jargon isn't deleted — it's interpreted: "it took the webhook and never stored it")
```

Identifiers survive. `client_id` stays `client_id` — **anything you can grep for in the
repo (functions, files, fields, commits) is a coordinate, not prose.** Translating it to
"고객 식별자" would make it unfindable.

Claude's own working vocabulary gets stripped from user-facing text:

```diff
- [충돌 A] OCR 품질 게이트를 어떻게 처리할까요?
+ AI 가 손글씨를 잘 읽는지 언제 확인할까요?
  ("How should we handle conflict A's OCR quality gate?" → "When should we check
   whether the AI reads handwriting well?")
```

### It works in two layers

Most style guides stop at "write it this way" — when the model drifts, nothing catches it.
korean-tone adds an enforcement layer on top.

| Layer | What | How |
|---|---|---|
| **Soft** — the skill | Shapes the writing | Rules apply whenever Claude speaks Korean |
| **Hard** — `tone-linter` hook | Catches the drift | Scans every Korean `.md` you save for translationese |

Patterns are sourced from National Institute of Korean Language papers, Toss's technical
writing guide, and 이오덕's *우리글 바로쓰기*. They're split into **error grade** (near-zero
false positives) and **warn grade** (judged by frequency). Code blocks, inline code, and
URLs are excluded; `<!-- tone-lint: off -->` skips a file entirely.

It never blocks a write — it just tells Claude what to fix next turn.

### Install

```bash
/plugin marketplace add seungboshim/skills
/plugin install korean-tone@seungboshim-skills
```

The hook installs with it. If you use `npx skills` instead, the hook needs
[separate registration](skills/korean-tone/hooks/README.md).

---

## Other skills

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
/plugin install korean-tone@seungboshim-skills
```

Install only what you want:

```bash
/plugin install shimmy-tone@seungboshim-skills
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

Works outside Claude Code too — but korean-tone's hook needs
[separate registration](skills/korean-tone/hooks/README.md).

## License

MIT
