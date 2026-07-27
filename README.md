<!-- tone-lint: off (지양 예문을 담고 있어 자기 검출 제외) -->

# Claude Code Skills

[한국어](README.md) | [English](README.en.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim)이 Claude Code에서 자주 쓰려고 만든 스킬 모음입니다.

<p align="center">
  <strong>korean-tone은 별도 저장소로 옮겼습니다 →
  <a href="https://github.com/fromshim/korean-tone">fromshim/korean-tone</a></strong><br>
  <code>/plugin install korean-tone@fromshim</code>
</p>

---

## 스킬 목록

### korean-tone → [fromshim/korean-tone](https://github.com/fromshim/korean-tone)

Claude Code가 쓰는 한국어를 자연스럽게 다듬되 `client_id` 같은 코드 좌표는 그대로 둡니다.
작성 규칙과 `tone-linter` 훅을 함께 제공합니다. 이제 별도 저장소에서 관리하며, 편의를 위해
이 마켓플레이스에도 계속 올려둡니다.

### shimmy-tone

개발 블로그나 벨로그 글을 개인적인 말투로 씁니다. 일상적인 비유, 눈길을 끄는 제목과 반전,
밈과 이모지를 활용해 어려운 개념을 쉽게 설명합니다. korean-tone의 기본 교정 규칙은
유지하면서 이모지 제한만 완화합니다.

### feature-flow

화면이나 기능 하나를 범위 정리부터 문서화까지 이어서 작업할 수 있도록 안내합니다.

- 범위 정리, 계획, 실행, 리뷰, 커밋, 문서화의 9단계로 진행합니다.
- 단계가 바뀔 때마다 사용자에게 진행 여부를 확인합니다.
- 실행 중에는 Karpathy의 4원칙(Think / Simple / Surgical / Goal-driven)을 기준으로 스스로 점검합니다.
- 프로젝트의 기존 문서 구조와 규칙을 먼저 찾아 그에 맞춥니다.

### feature-flow-superpowers

feature-flow에 [superpowers](https://github.com/obra/superpowers)를 연동한 버전입니다. 각 단계에
맞는 superpowers 스킬을 호출합니다.

- 사용하려면 superpowers 플러그인이 필요합니다.
- `superpowers:test-driven-development`로 테스트 주도 개발을 진행합니다.
- `superpowers:verification-before-completion`으로 결과를 확인한 뒤 작업을 마칩니다.
- 단순한 구현을 선호하는 원칙과 TDD가 부딪힐 때 적용할 기준도 정해 두었습니다.

### daily

백로그, 최근 패치노트, Git 상태를 읽고 현재 작업 위치와 다음 우선순위를 정리합니다.

- 파일은 수정하지 않고 작업 현황과 추천만 보여줍니다.
- 프로젝트마다 다른 백로그와 패치노트 규칙을 먼저 찾습니다.
- feature-flow를 시작하기 전에 무엇부터 할지 고를 때 유용합니다.

### worklog

작업을 마친 뒤 패치노트, 기능 명세, 백로그를 한 번에 정리합니다.

- 다른 작업 흐름에 묶이지 않아, 어떤 작업을 마친 뒤에도 단독으로 호출합니다.
- 동작이 바뀌었다면 기능 명세도 함께 갱신합니다.
- 프로젝트의 기존 문서 규칙을 찾아 그 형식에 맞춥니다.

### tailwind-design-system

Tailwind CSS와 Next.js 프로젝트에서 디자인 시스템을 만들거나 다듬을 때 사용합니다.

- 디자인 방향 설정, 스타일 점검, 시맨틱 토큰 정의, 공용 컴포넌트 추출, 마이그레이션을 안내합니다.
- 새 프로젝트와 기존 프로젝트를 모두 지원합니다.
- 디자인 토큰을 제대로 쓰고 있는지 계속 점검합니다.

---

## 설치

### 플러그인으로 설치

Claude Code에서만 동작합니다. 스킬을 하나씩 골라 설치하고, `/plugin` 명령으로 켜고 끌 수
있습니다.

```bash
/plugin marketplace add seungboshim/skills
/plugin install shimmy-tone@seungboshim-skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```

### skills.sh로 설치

Claude Code 외에 Codex, Cursor, Antigravity, Amp, Gemini CLI 등 여러 에이전트에 설치됩니다.
아래 명령은 이 저장소의 스킬을 한 번에 받습니다.

```bash
npx skills add seungboshim/skills
```

> korean-tone은 [fromshim/korean-tone](https://github.com/fromshim/korean-tone)에 있습니다.

## 라이선스

MIT
