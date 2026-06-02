---
name: feature-flow-superpowers
description: >
  Superpowers-extended variant of feature-flow. Same step structure (scope →
  plan → execute → review → commit → document) but each step explicitly calls
  matching superpowers skills (brainstorming, writing-plans, executing-plans,
  test-driven-development, requesting-code-review, finishing-a-development-branch,
  etc.). Requires the superpowers plugin to be installed. Triggers on
  /feature-flow-superpowers command or phrases like "기능 작업 with superpowers",
  "superpowers 기능 사이클". args same as feature-flow.
license: MIT
metadata:
  author: seungboshim
  locale: ko
  version: "1.0.0"
  requires: superpowers
---

# Feature Flow (Superpowers) — superpowers 통합 사이클

`feature-flow` 의 superpowers 통합 버전. 각 step 에서 superpowers 스킬을 명시적으로 호출해 일관된 방법론을 적용한다. **superpowers 플러그인이 설치돼 있어야 한다.**

순수 feature-flow 와의 차이:
- 각 step 안에 `Skill: superpowers:<name>` 호출이 박혀있음
- TDD-first 결을 따른다 (4원칙은 보조)
- "검증 = 실행 증거" 룰을 superpowers 의 `verification-before-completion` 으로 강제

## superpowers 설치 확인

작업 시작 전에 다음을 확인:
- `superpowers:using-superpowers` 스킬이 가용한지
- 없다면 사용자에게 superpowers 설치 안내 또는 순수 `feature-flow` 사용 권장

## 4원칙 ↔ TDD 결 충돌 (명시적 해결)

순수 feature-flow 는 **Karpathy 4원칙 (Think / Simple / Surgical / Goal)** 기반 — *simplicity-first*.
superpowers 의 `test-driven-development` 는 *test-first*.

둘은 적용 영역이 다르다:

| 결정 영역 | 결 | 기준 스킬 |
|---|---|---|
| 디자인 / 구조 결정 | simplicity-first | 4원칙 (Karpathy) |
| 코드 작성 (구현) | test-first | `superpowers:test-driven-development` |
| 검증 | evidence-first | `superpowers:verification-before-completion` |

즉 *"어떻게 만들지"* 는 4원칙으로 결정하고, *"실제 작성"* 은 TDD 룰을 따른다. 충돌 시 본 스킬은 위 표를 따른다.

---

## 호출 형태

```
/feature-flow-superpowers                   # arg 없음
/feature-flow-superpowers scope|plan|...    # step 점프
/feature-flow-superpowers <자연어>          # 새 작업 시작
```

args 해석 규칙은 feature-flow 와 동일.

## 단계 체크포인트

각 단계 끝마다:
> ⛔ **다음 단계로 진행할까요? 아니면 이 단계에서 아직 다듬을 곳 있나요?**

---

## Step 1 — Scope & Context

**목표**: 작업 주제 명확화 + 영향 범위 파악.

> **Skill: `superpowers:brainstorming`** — 사용자 의도, 요구사항, 디자인 공간을 탐색.

수행:
1. brainstorming 스킬 호출 → 작업 주제·제약·디자인 옵션 탐색
2. 참조 자료 수집 (spec / 디자인 / 기존 코드 grep)
3. 영향 받을 파일/디렉토리 리스트

산출 (채팅): 작업 주제 한 문장 + 디자인 옵션 / 결정 / 참조 자료 + 영향 파일 표.

> ⛔ 계획 수립으로 진행할까요?

---

## Step 2 — Plan

**목표**: 어떻게 만들지 구체화.

> **Skill: `superpowers:writing-plans`** — multi-step 작업의 plan 작성 가이드.

수행:
- writing-plans 스킬 따라 phase 분할 + verifiable checkpoint
- 컴포넌트/모듈 트리
- 데이터/state 결정
- 신규 컨벤션 명시
- 미해결 / 후속 docking

산출 (채팅): plan 문서 (writing-plans 양식). Phase 별로 verifiable checkpoint 박힘.

> ⛔ 계획 OK 면 Step 3 (Confirm) 으로.

---

## Step 3 — Plan Confirm

**목표**: 결정 필요 항목 확정 + plan 마무리.

수행:
- "결정 필요" 항목 옵션 형태 (`AskUserQuestion`)
- 미정은 "후속 결정" docking
- 합의 사항 요약

산출: 확정 사항 + 미정 docking.

> ⛔ 이대로 실행 시작할까요?

---

## Step 4 — Execute

**목표**: plan 대로 코드 작성.

> **Skills**:
> - **`superpowers:executing-plans`** — plan 을 review checkpoint 와 함께 실행
> - **`superpowers:test-driven-development`** — 구현 전 테스트 작성
> - **`superpowers:subagent-driven-development`** — 독립 task 가 있으면 현 세션 내 subagent
> - **`superpowers:dispatching-parallel-agents`** — 2+ 독립 task 병렬
> - **`superpowers:using-git-worktrees`** — isolation 필요 시
> - **`superpowers:systematic-debugging`** — 버그/실패 발견 시

수행:
1. plan 의 phase 순서대로 진입, executing-plans 룰 따라 phase 마다 checkpoint
2. 각 phase 의 첫 작업 = **테스트 먼저** (TDD). 실패 확인 후 구현
3. 독립 task 가 보이면 subagent / parallel dispatch
4. 버그/실패 → systematic-debugging 으로 root cause 파악, hack 우회 X
5. Karpathy 4원칙 self-monitor (디자인 결정에서):
   - **Think** / **Simple** / **Surgical** / **Goal-driven**

산출: phase 별 완료 보고 + 테스트 통과 결과 + 변경 파일 요약.

> ⛔ 작업 끝났어요. 리뷰할까요?

---

## Step 5 — Review

**목표**: 자체 + Human 가이드 통합 리뷰.

> **Skills**:
> - **`superpowers:requesting-code-review`** — 작업 완료 시 self-review 양식
> - **`superpowers:verification-before-completion`** — "완료" 주장 전 실행 증거 확인

수행:
1. **verification-before-completion** 먼저 — typecheck / test / 실제 동작 검증. 증거 없으면 "완료" 주장 금지.
2. **requesting-code-review** — self-review 양식 따라 발견 사항 도출:
   - 4원칙 렌즈 (디자인 결정)
   - TDD 렌즈 (테스트 커버리지)
   - 위반 / 경고 구분
3. **Human 가이드 작성** (feature-flow 의 inline 마커 양식 동일):
   - 코드 흐름 순서대로 파일 가이드
   - 자체 리뷰 포인트를 inline 마커로 끼움
   - 검증 시나리오 별도 섹션

**Inline 마커 양식**:
```md
### `path/to/file.tsx`
- 역할: ...
- 보는 포인트: ...

  ⚠️ **자체 리뷰** — [발견 사항 한 줄]
     [필요 시 한 줄 설명]
     → 의견 주세요
```

산출: 단일 가이드 문서 + 검증 증거.

> (Step 6 으로 자연스럽게 이어짐)

---

## Step 6 — Iterate

**목표**: 가이드 따라 의견 교환 + 픽스 반복.

> **Skill: `superpowers:receiving-code-review`** — review 피드백 받을 때 기술적 검증 (blind agreement X).

수행:
- receiving-code-review 룰 따라 사용자 피드백 처리:
  - 불명확하면 묻기
  - 기술적 의문 있으면 reasoning 제시 후 확인
  - blind 적용 X
- 픽스마다 verification-before-completion 다시 실행
- 추가 발견 사항 inline 추가

산출: 라운드별 픽스 + 검증 결과.

> ⛔ 더 다듬을 곳 있나요? 아니면 커밋 분리 (Step 7)로?

---

## Step 7 — Commit Plan

**목표**: 변경분 의미 단위 분리 + 가제목 제안.

수행:
1. `git status` + `git diff --stat`
2. 의미 단위 분류
3. 의존성 토폴로지
4. 가제목 (프로젝트 컨벤션 따름)

산출: 커밋 표.

> ⛔ 이 분리로 가도 OK 인가요?

---

## Step 8 — Commit Apply

**목표**: 합의된 분리대로 실제 커밋.

> **Skill: `superpowers:finishing-a-development-branch`** — 구현 완료 + tests pass 시 통합 결정 (merge / PR / cleanup)

수행:
- 매 커밋 단위 `git add` → `git commit`
- 매 커밋 후 `git status` 확인
- 마지막 typecheck/lint (회귀 방지)
- 작업이 branch 단위면 finishing-a-development-branch 로 통합 결정

산출: 커밋 hash + `git log --oneline`.

> ⛔ 작업 완료.
>
> **문서화 할까요?** (선택)
> - 사이클 회고 (patch note)
> - 정착된 패턴 (research note)
> - 사양 변경 (feature-spec 갱신)
>
> 셋 다 / 일부 / 스킵 골라주세요.

---

## Step 9 — Document (선택)

> **Skill: `superpowers:writing-skills`** — 새 스킬 작성 / 기존 편집 시 (research 정착 시 본문이 스킬화 가치 있으면)

> **이 단계 진입은 사용자 명시적 OK 후만.** Step 8 끝의 분기 답이 진입 트리거.

이 스킬은 다음 4 결의 인박스 + 정착 구조를 가정한다:

```
docs/_inbox/
├── research/      → docs/research-notes/ 로 정제 승격
├── spec/          → docs/feature-specs/{기능}.md 로 정제 승격
├── patch/         (영구 보관, 무갱신)
└── scratch/       (plan/audit/ideation 등 일회성)
```

(프로젝트에 같은 구조 있으면 사용, 없으면 사용자 컨벤션에 맞춤)

### 9-A. Patch Note (사이클 회고)

결: "이번 사이클에 뭘 왜 했나". 시점 묶임, 무갱신.

위치: `_inbox/patch/YYYY-MM-DD-<slug>.md` (사이클 식별자, 예: ICX-xxx)

골격:
```md
---
date: YYYY-MM-DD
tags: [관련 키워드, ICX-xxx]
status: draft
---

# <작업 제목>

## 0. 문서 위치 (cross-ref)

## 1. 핵심 흐름

## 2. 주요 의사결정

## 3. 미해결 / 후속

## 4. 관련 커밋
```

### 9-B. Research Note (정착된 기술 패턴)

결: "이렇게 동작한다 / 이때는 이렇게 한다". 일반화·블로그 톤.

승격 흐름:
1. 사이클 중 → `_inbox/research/YYYY-MM-DD-<slug>-tech.md` (패치노트와 쌍으로)
2. 정제 → `docs/research-notes/<slug>.md`, 원본 _inbox 삭제

후보 발굴 기준:
- 다른 상황에도 적용될 **패턴** 발견
- 도구/플랫폼의 **비직관적 동작**
- 사람이 다시 마주칠 **함정**

작성 시 후보 목록 제시 → 사용자 의견 받기:
```
이번 사이클에서 정착할만한 기술 포인트:
1. <포인트1>
2. <포인트2>
3. <포인트3>
번호 / 통합 / 거절 / 추가 골라주세요.
```

### 9-C. Feature Spec 갱신 (구현 사양 정착)

결: "이 기능은 지금 이렇게 동작한다". 현재 상태, 사이클마다 갱신.

승격 흐름:
1. 사이클 중 사양 변화 → `_inbox/spec/YYYY-MM-DD-<slug>.md` (선택)
2. 사이클 종료 → `docs/feature-specs/{기능}.md` 본문 갱신:
   - 본문은 **현재 사양만**
   - 변경 이력은 patch 링크 역참조

변경 이력 양식:
```md
## 변경 이력

- 2026-04-29: 초안 ([oauth-flow](../_inbox/patch/oauth-flow.md))
- 2026-05-25: Gmail OAuth 분리 ([gmail-oauth-migration](../_inbox/patch/2026-05-25-gmail-oauth-migration.md), ICX-270)
```

이 패턴으로 PM 원문 (`open-specs/`) 과 실제 구현 (`feature-specs/`) 정합성 점검.

### 결 조합 가이드

| 사이클이 한 게 | 추천 산출물 |
|---|---|
| 사양 변화 없음, 일회성 버그픽스 | 9-A 만 |
| 사양 변화 + 정착할 패턴 | 9-A + 9-B + 9-C |
| 사양 변화만 | 9-A + 9-C |
| 패턴은 있는데 사양 그대로 | 9-A + 9-B |

> ⛔ 작업 사이클 완료.

---

## 안티 패턴 (회피)

- 검증 (typecheck/lint 통과) = 완료 선언 — 실제 행동 검증 필요
- 큰 결정 (컨벤션 / 라이브러리) 사용자 합의 없이 강행
- TDD 룰 무시하고 구현 먼저 작성 후 테스트 끼워맞추기
- review 피드백 blind 적용 (receiving-code-review 위반)
- `superpowers:systematic-debugging` 없이 hack 우회로 버그 봉합

---

## 에이전트 / 스킬 협업

| Step | 호출 |
|---|---|
| 1 | `superpowers:brainstorming` |
| 2 | `superpowers:writing-plans` |
| 4 | `superpowers:executing-plans`, `:test-driven-development`, `:subagent-driven-development`, `:dispatching-parallel-agents`, `:using-git-worktrees`, `:systematic-debugging` |
| 5 | `superpowers:requesting-code-review`, `:verification-before-completion` |
| 6 | `superpowers:receiving-code-review` |
| 8 | `superpowers:finishing-a-development-branch` |
| 9 | `superpowers:writing-skills` (research → 스킬 정착 시) |

프로젝트별 implementation/review agent 가 있으면 함께 호출 가능 (feature-flow 와 동일).

---

## 메모

- 이 스킬은 superpowers 의 모든 스킬을 **사이클 흐름 안에 배치**해 누락 없이 활용하기 위한 orchestrator.
- 각 step 의 superpowers 호출은 강제가 아닌 권장 — 단계 특성상 안 맞으면 skip 가능 (skip 시 이유 명시).
- 4원칙 ↔ TDD 결 충돌은 본문 §"4원칙 ↔ TDD" 표 따른다.
- `_inbox/{research,spec,patch,scratch}` 구조는 권장 — 프로젝트 컨벤션 있으면 그에 맞춤.
