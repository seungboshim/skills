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

### handoff

Writes a handoff document once context passes 80%, then hands it to the next session after `/clear`.

- Starts the next session from a document you curated, not an auto-generated compact summary
- Rewrites the document every time you cross 85%, 90%, or 95% — a late cleanup still leaves it current
- Refreshes on demand via `/handoff`
- Ships with Stop and SessionStart hooks — automatic detection only works when installed as a Claude Code plugin

### tailwind-design-system

Design system builder and refactorer for Tailwind CSS + Next.js projects.

- Guides from initial design prompting through style audit, semantic token definition, shared component extraction, migration, and ongoing compliance review
- Supports new projects (Phase 0: design prompting) and existing projects (Phase 1: style audit)
- Ongoing audit mode for design token compliance

### truman

Turns today's development trail into a third-person observational-documentary episode.

- Collects commits, reflog, the prompts you typed in Claude sessions, and shell history, then edits them into a script
- Seasons and episode numbers accumulate; whatever you left unfinished becomes the next-episode teaser, tagged "third episode in a row" when it keeps showing up
- The closing two blocks (production notes, next-episode teaser) stick to observed signals, so they work as a real retro
- Collection is read-only and entirely local. No network calls

### date-sim

Runs one mock date from start to finish in chat, as conversation-habit training.

- Pick difficulty, venue, and who you're meeting; it runs 8–12 turns with an affinity delta and a one-line note each turn
- Your date has one landmine and one hidden need. The need stays hidden until the report
- Ends with an autopsy report: how much you talked about yourself, how many questions you asked, three turning points, and exactly one thing to practice next
- Across sessions it compares runs and flags a recurring note as a chronic habit after three appearances
- Bland answers do not score well. A date who carries the conversation for you teaches nothing

### prompt-mbti

Counts everything you have ever typed at the agent and reads your prompting habits back to you.

- Four axes — instruction length, working hours, how often you ask for verification, and how concentrated your repos are — resolve to one of 16 types
- Every claim is backed by a real number. You answer no questionnaire; it counts what you already said
- Also ranks your verbal tics, including the Korean jamo shorthand (`ㄱㄱ`, `ㅇㅋ`)
- A metric within three points of a threshold is reported as borderline rather than forced to one side
- Never prints your raw prompts, only counts and word frequencies. No network calls

### diggz-radio

Compiles your current coding task and mood into a playable indie radio session.

- Separates the work scene (`deep-focus`, `debug-loop`, or `mechanical`) from the direction you want (`push`, `hold`, or `cool-down`)
- Edits verified tracks into an `entry → lock → turn → landing` energy arc instead of ranking songs
- Uses the official YouTube IFrame Player and stays silent until you click start
- Never invents tracks, IDs, or view counts, and never reads browser cookies or unofficial Music APIs

---

## Installation

### Install as a plugin

Claude Code only. Pick skills individually and toggle them with `/plugin`.

```bash
/plugin marketplace add seungboshim/skills
/plugin install shimmy-tone@seungboshim-skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install handoff@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
/plugin install truman@seungboshim-skills
/plugin install date-sim@seungboshim-skills
/plugin install prompt-mbti@seungboshim-skills
/plugin install diggz-radio@seungboshim-skills
```

### Install via skills.sh

Installs to Codex, Cursor, Antigravity, Amp, Gemini CLI, and others besides Claude Code.
The command below pulls every skill in this repository at once.

```bash
npx skills add seungboshim/skills
```

> korean-tone lives in [fromshim/korean-tone](https://github.com/fromshim/korean-tone).

## License

MIT
