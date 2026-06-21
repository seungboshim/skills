---
name: daily
description: >
  Session orientation + work recommendation. Reads the project's backlog,
  recent patch/release notes, and git state, then produces a quick "where am I"
  map and a prioritized "what should I work on" list. Use this whenever the user
  opens a session and wants to get oriented, asks what to do today, or wants a
  recommendation on what to tackle next — e.g. "/daily", "오늘 뭐하지", "오늘
  작업 추천", "어디부터 볼까", "세션 시작 정리해줘", "지금 뭐부터 보면 돼?",
  "what should I work on", "morning standup", "catch me up on this repo". Also the
  skill a scheduled morning routine should run. Trigger even when the user doesn't
  say "daily" — any "orient me / what's next here" intent counts.
license: MIT
metadata:
  author: seungboshim
  locale: ko
  version: "1.0.0"
---

# Daily — 오리엔트 + 작업 추천

세션을 막 시작했을 때 **"지금 어디고, 오늘 뭘 하면 좋은가"** 를 빠르게 잡아주는 스킬. 프로젝트의 backlog · 최근 패치노트 · git 상태를 읽어 한 화면짜리 지도 + 우선순위 추천을 만든다. 어떤 프로젝트에서도 동작하도록 문서 위치를 **발견(discover)** 한다 — 특정 레포 구조에 묶이지 않는다.

## 호출 형태

```
/daily              # 현재 레포 상태로 오리엔트 + 추천
/daily <키워드>      # 특정 영역으로 좁혀 추천 (예: "/daily 이메일", "/daily 버그")
```

자연어 트리거(예: "오늘 뭐하지", "어디부터 볼까")로 들어와도 동일하게 동작. 아침 scheduled routine 이 이 스킬을 호출하기도 한다.

## 무엇을 읽나 (컨벤션 발견)

하드코딩하지 않고 프로젝트에서 다음을 찾아 읽는다. 없으면 있는 것만으로 진행:

1. **Backlog** — 미완료 작업 목록.
   - 탐색: `backlog.md` / `BACKLOG.md` / `docs/**/backlog.md` / `TODO.md` 글롭
   - 없으면: 이슈 트래커(`gh issue list` 가능하면) 또는 git 만으로
2. **최근 패치/릴리즈 노트** — 최근에 뭘 했나 (맥락 회복).
   - 탐색: `docs/_inbox/patch/` / `docs/**/patch/` / `CHANGELOG.md` / `docs/release/`
   - mtime 또는 파일명 날짜 기준 최근 3개
3. **Git 상태** — 진행 중인 작업.
   - `git status --short` (미커밋 변경), `git log --oneline -10`, 현재 브랜치
   - 미머지 브랜치 있으면 `git branch --sort=-committerdate` 상위 몇 개
4. **(선택) 프로젝트 컨벤션 문서** — `docs/README.md` 또는 `CLAUDE.md` 가 backlog/문서 구조를 기술하면 그걸 우선 따른다. (예: backlog 가 owner/blocker 별로 분류돼 있으면 그 분류를 추천에 반영)

> 큰 레포라 탐색이 무거우면 `Explore`/`general-purpose` 서브에이전트에 위 수집을 위임하고 결과만 받아도 된다.

## 산출물

채팅에 **두 블록**으로. 길게 늘이지 말 것 — 한 화면에 들어와야 가치 있다.

### 1. 빠른 지도

```md
## 📍 지금

- 브랜치: `main` (또는 작업 브랜치) · 미커밋: 3 files
- 최근 사이클: <patch 1 한 줄> / <patch 2 한 줄> / <patch 3 한 줄>
- 진행 중(미커밋·미머지): <있으면 한 줄, 없으면 생략>
```

### 2. 오늘 추천

backlog 에서 **착수 가능 + 가치/속도** 기준으로 top 3 (필요하면 ±1). 각 항목 한 줄 근거 + 대략 범위.

```md
## 🎯 오늘 추천

1. **<작업>** — <왜 지금: 막힘 없음 / 빠른 승부 / 진행 중 이어가기> · 범위: S/M/L
2. **<작업>** — ...
3. **<작업>** — ...

⏸️ 막힌 것(외부 의존 대기): <한 줄로 묶어 표시 — 추천에선 제외>
```

### 추천 우선순위 휴리스틱 (왜 이 순서인가)

사람의 아침 의사결정 비용을 줄이는 게 목적이라, 다음 순으로 가중한다:

1. **막힘 없는 것 우선** — 외부 의존(다른 팀·API·정책 결정) 대기 항목은 시작해도 못 끝낸다. backlog 에 owner/blocker 표기가 있으면 그걸로 거른다.
2. **진행 중 이어가기** — 미커밋·미머지 작업이 있으면 컨텍스트가 따뜻할 때 마무리하는 게 싸다.
3. **빠른 승부(quick win) 가산** — 작고 독립적인 항목은 하루 시작을 가볍게 연다.
4. **사용자가 키워드를 줬으면** 그 영역을 최우선.

확신이 없으면 추천을 단정하지 말고 *"이 중 뭐 시작할까?"* 로 사용자에게 고르게 한다. 막힌 항목을 추천 1번에 올리는 건 피한다.

## 체크포인트

> 🎯 **이 중 뭐 시작할까? 정하면 `/feature-flow <작업>` 로 사이클을 열거나, 그냥 바로 작업 들어갈게.**

작업이 끝난 뒤 기록은 `/worklog` 로 (패치노트 + 사양 갱신 + backlog 체크). daily 는 사이클의 **입구**, worklog 는 **출구**다.

## Scheduled / 자동 사용

- **세션 시작 자동 오리엔트**: 프로젝트 `.claude/settings.json` 의 SessionStart hook 이 가벼운 git/backlog 다이제스트를 context 로 주입하게 두고, 본 스킬은 그 위에서 *추천* 만 얹는 식으로 분업 가능. (hook = 기계적 사실, skill = 판단)
- **아침 routine**: 매일 아침 이 스킬을 돌리는 cloud routine(또는 in-session cron)을 걸면, 출근 전 추천이 준비된다. routine 이 헤드리스로 돌 때는 산출물을 채팅 대신 스크래치 파일(예: `docs/_inbox/scratch/standup-YYYY-MM-DD.md`)로 남기고 알림만 띄우는 변형이 유용하다.

## 메모

- daily 는 **읽기 전용** — 추천만 한다. 파일을 고치거나 커밋하지 않는다.
- 지도/추천은 **짧게**. 사용자가 5초 안에 "아 오늘 이거구나" 가 되게.
- 프로젝트에 planner 류 에이전트(예: `screen-planner`)가 있으면, 사용자가 한 작업을 고른 뒤 그 에이전트로 자연스럽게 넘길 수 있다 — 단 daily 단계에서 미리 호출하지 말 것(오리엔트가 무거워진다).
