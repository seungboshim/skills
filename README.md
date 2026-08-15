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

### handoff

컨텍스트가 80%를 넘으면 핸드오프 문서를 만들고, `/clear` 뒤 새 세션에 그 문서를 건넵니다.

- 자동 요약(compact) 대신 직접 정리한 문서로 다음 세션을 시작합니다.
- 85·90·95%를 넘길 때마다 문서를 다시 씁니다. 늦게 정리해도 최신 상태가 남습니다.
- `/handoff`로 원하는 시점에 직접 갱신할 수 있습니다.
- Stop·SessionStart 훅이 함께 설치되므로, 자동 감지는 Claude Code 플러그인으로 설치할 때만 동작합니다.

### tailwind-design-system

Tailwind CSS와 Next.js 프로젝트에서 디자인 시스템을 만들거나 다듬을 때 사용합니다.

- 디자인 방향 설정, 스타일 점검, 시맨틱 토큰 정의, 공용 컴포넌트 추출, 마이그레이션을 안내합니다.
- 새 프로젝트와 기존 프로젝트를 모두 지원합니다.
- 디자인 토큰을 제대로 쓰고 있는지 계속 점검합니다.

### truman

오늘 하루 개발한 흔적을 3인칭 관찰 예능 내레이션 에피소드로 만듭니다.

- 커밋, reflog, Claude 세션에 남은 내 발언, 터미널 기록을 모아 대본으로 편집합니다.
- 시즌과 회차가 누적되고, 어제 못 끝낸 일은 다음 회 예고가 됩니다. 같은 항목이 또 나오면 "3화 연속 등장"으로 적습니다.
- 마지막 두 블록(제작진 노트·차회 예고)에는 관찰된 신호만 적어서 그대로 회고로 씁니다.
- 자료 수집은 전부 로컬 파일이고 읽기 전용입니다. 네트워크를 쓰지 않습니다.

### date-sim

채팅으로 소개팅 한 번을 처음부터 끝까지 진행하며 대화 습관을 훈련합니다.

- 난이도, 장소, 상대만 정하면 8~12턴을 진행합니다. 턴마다 호감도 변화와 한 줄 관전평이 붙습니다.
- 상대에게는 지뢰 하나와 숨은 니즈 하나가 있습니다. 니즈는 끝까지 숨겨두고 리포트에서 공개합니다.
- 끝나면 부검 리포트를 냅니다. 자기 얘기 비율, 질문 횟수, 결정적 순간 3개, 다음 훈련 과제 하나.
- 회차가 쌓이면 지난 회차와 비교하고, 같은 지적이 3회 이상 반복되면 "고질병"으로 표시합니다.
- 무난한 답변에 후한 점수를 주지 않습니다. 상대가 알아서 리드하면 훈련이 안 되니까요.

### prompt-dna

그동안 에이전트에게 해온 말을 전부 세어 지시 습관을 진단합니다.

- 지시 길이, 작업 시간대, 확인하는 습관, 저장소 편중도로 네 축을 잡고 16유형 중 하나를 냅니다.
- 근거는 전부 실제 숫자입니다. 문항에 답하는 게 아니라 이미 해온 말을 셉니다.
- 말버릇과 자모 표현 순위도 나옵니다. `ㄱㄱ` 를 몇 번 썼는지 세어줍니다.
- 임계값에 3포인트 안쪽으로 걸리면 경계형이라고 적습니다. 한쪽으로 밀지 않습니다.
- 원문 지시는 출력하지 않습니다. 수치와 낱말 빈도만 냅니다. 네트워크를 쓰지 않습니다.

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
/plugin install handoff@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
/plugin install truman@seungboshim-skills
/plugin install date-sim@seungboshim-skills
/plugin install prompt-dna@seungboshim-skills
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
