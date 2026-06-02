---
name: feature-flow
description: >
  Full-cycle guide for building a single screen/feature — from scope and planning
  through execution, review, commits, and documentation. Each step ends with a
  human checkpoint ("proceed? or still iterating?") so the user controls pace.
  Triggers on /feature-flow command (with or without args), or phrases like
  "기능 작업 시작", "화면 만들자", "이 기능 처음부터 끝까지 같이",
  "feature cycle", "develop feature end-to-end". args can be either a step
  keyword (scope/plan/execute/review/commit/document) to jump, or a natural
  language feature description to start fresh.
license: MIT
metadata:
  author: seungboshim
  locale: ko
  version: "1.1.0"
---

# Feature Flow — 화면/기능 단위 작업 사이클

한 화면 또는 한 기능을 처음 받았을 때부터 커밋·문서화까지 끌고 가는 가이드. 각 단계 끝마다 사용자에게 진행 의사를 묻고, 사용자가 페이스를 조절한다.

## 호출 형태

```
/feature-flow                       # arg 없음 → 현재 대화 컨텍스트 추정
/feature-flow scope|plan|execute|   # step 키워드 → 그 단계 진입
              review|commit|document
/feature-flow <자연어 설명>          # 새 작업 시작, Step 1 부터
                                    # 예) "/feature-flow 메인 화면 tag filter 만들자"
```

**args 해석 규칙** — **함부로 점프하지 않고 한 번 확인**:
- 첫 단어가 step 키워드와 매칭 → *"`{step}` 단계로 점프할까요? 아니면 다른 의도?"* 한 번 묻고 진행
- 그 외 모두 (자연어로 보임) → *"새 작업으로 Step 1 부터 시작할까요? 아니면 진행 중 작업이 있나요?"* 묻고 진행
- args 가 없으면 → 현재 대화 컨텍스트로 적절한 단계 추정 + 추천 (역시 점프 전 확인)

## 단계 체크포인트 양식

각 단계 끝마다 사용자에게 묻는다:

> ⛔ **다음 단계로 진행할까요? 아니면 이 단계에서 아직 다듬을 곳 있나요?**

이름이 명시적인 분기(예: step 4 → "리뷰할까요?", step 8 → "문서화 할까요?")는 그 단계 설명에 적시.

---

## Step 1 — Scope & Context

**목표**: 작업 주제 명확화 + 영향 범위 파악.

수행:
1. 작업 주제를 한 줄로 요약 (사용자 입력 정제)
2. 참조 자료 수집:
   - 프로젝트 spec / 디자인 문서 (있다면 위치 확인)
   - 프로토타입 (있다면)
   - 기존 코드베이스에서 관련 영역 grep
3. 영향 받을 파일/디렉토리 리스트

산출 (채팅): 작업 주제 한 문장 + 참조 자료 목록 + 영향 파일 표.

> ⛔ 다음 단계 (계획 수립)로 진행할까요? 또는 범위 더 좁히거나 넓힐까요?

---

## Step 2 — Plan

**목표**: 어떻게 만들지 구체화.

수행:
- Phase 분할 제안 (보통: 스펙 갱신 → 코드 → 검증)
- 컴포넌트/모듈 트리
- 데이터/state 결정 (서버 vs 클라이언트, URL vs 메모리 등)
- 신규 컨벤션이 도입되는지 (있으면 명시)
- 미해결 / 후속 항목 docking

산출 (채팅): Phase 표 + 컴포넌트 트리 + state 결정 + 미해결 목록.

> ⛔ 계획 OK 면 결정 사항 정리(Step 3)로, 아직 다듬을 곳 있으면 짚어주세요.

---

## Step 3 — Plan Confirm (티키타카)

**목표**: 결정 필요 항목을 사용자 답으로 확정.

수행:
- "결정 필요" 항목을 옵션 형태로 제시 (가능하면 `AskUserQuestion` 활용)
- 미정 영역은 "후속 결정 (Stage N / TBD)"으로 docking
- 모든 합의 사항을 한 번 더 요약

산출 (채팅): 확정 사항 정리 + 미정 docking 목록.

> ⛔ 이대로 실행 시작할까요?

---

## Step 4 — Execute

**목표**: 합의된 계획대로 코드 작성.

수행:
- 단계가 3개 이상이면 `TaskCreate` 로 트래킹
- 각 작은 단계 끝나면 typecheck/lint (프로젝트에 맞춰)
- 작업 중 4원칙 self-monitor:
  - **Think**: 가정 명시, 모호하면 묻기
  - **Simple**: 한 번 쓸 추상화는 인라인
  - **Surgical**: 무관 영역 drive-by 변경 금지
  - **Goal-driven**: 검증 없이 "완료" 선언 금지

산출 (채팅): 작업한 파일 요약 + 검증 통과 결과.

> ⛔ 작업 끝났어요. 리뷰할까요?
> (사용자가 OK 하면 Step 5 진입)

---

## Step 5 — Review (자체 + Human 가이드 통합)

**목표**: 자체 리뷰 결과를 **Human 리뷰 가이드 안에 inline 으로 끼워 넣어** 한 번에 제공.

수행:
1. **자체 리뷰** 먼저 (직접 또는 프로젝트에 review agent 있으면 그것 호출)
   - 4원칙 렌즈로 발견 사항 도출 (Think / Simple / Surgical / Goal)
   - 위반/경고 수준 구분 (위반은 별표, 경고는 일반 ⚠️)
2. **Human 가이드 작성**:
   - 코드 흐름 순서대로 파일 가이드 (의존성 위→아래, 또는 사용자 진입점 따라)
   - 각 파일/블록 안에 자체 리뷰 포인트를 **inline 마커**로 끼움
   - 검증 시나리오 마지막에 별도 섹션
3. **별도 위반/경고 표는 만들지 않음** — 가이드 본문 안에 통합

**Inline 마커 양식**:
```md
### `path/to/file.tsx`
- 역할: ...
- 보는 포인트: ...

  ⚠️ **자체 리뷰** — [발견 사항 한 줄]
     [필요 시 한 줄 설명]
     → 의견 주세요
```

산출 (채팅): 단일 가이드 문서. Layer 별 (큰그림 → 흐름 → 파일 → 검증) 또는 의존성 순서.

> (Step 6 으로 자연스럽게 이어짐 — 사용자가 가이드 따라 질문/의견 주면 응답)

---

## Step 6 — Iterate

**목표**: 가이드 따라 사용자 의견과 자체 리뷰 답변을 교환하며 수정 반복.

수행:
- 사용자가 가이드 따라 읽으며 던지는 의견/질문에 답
- 자체 리뷰 ⚠️ 마커에 대한 사용자 결정 받아 픽스
- 픽스마다 검증 (typecheck/lint)
- 추가 발견 사항 있으면 같은 양식으로 inline 추가

산출 (채팅): 라운드별 픽스 결과.

> ⛔ 더 다듬을 곳 있나요? 아니면 커밋 분리 (Step 7)로?

---

## Step 7 — Commit Plan

**목표**: 변경분을 의미 단위로 분리 + 가제목 제안.

수행:
1. `git status` + `git diff --stat` 로 변경 파일 파악
2. 의미 단위 분류 (예: docs / refactor / feat / fix / chore)
3. 의존성 토폴로지: 어떤 커밋이 어떤 커밋에 의존 — cross-cutting 위험 표시
4. 각 커밋 가제목 제안. **사용자 프로젝트의 커밋 메시지 형식을 강제하지 않음.**
   - 일반 예시만 제시: `feat: ...`, `refactor: ...`
   - 사용자가 특정 형식 (예: 이슈 번호 prefix) 선호 시 그에 맞춰 갱신

산출 (채팅): 커밋 표 (의미 단위 / 파일 목록 / 가제목 / 의존성).

> ⛔ 이 분리로 가도 OK 인가요? 메시지 형식이나 분리 단위 수정할까요?

---

## Step 8 — Commit Apply

**목표**: 합의된 분리대로 실제 커밋.

수행:
- 매 커밋 단위로 `git add <files>` → `git commit -m <message>`
- 매 커밋 후 `git status` 로 trailing 파일 없는지 확인
- 마지막 typecheck/lint 한 번 더 (회귀 방지)

산출 (채팅): 커밋 hash 목록 + 최종 `git log --oneline`.

> ⛔ 작업 완료.
>
> **문서화 할까요?** (선택)
> - 사이클 회고 (patch note)
> - 정착된 패턴 (research note)
> - 사양 변경 (feature-spec 갱신)
>
> 셋 다 / 일부 / 스킵 골라주세요. 자세한 건 Step 9.

---

## Step 9 — Document (선택)

**목표**: 작업 기록을 정착시킬 가치가 있다면 `.md` 산출물 작성.

> **이 단계 진입 시 사용자에게 명시적으로 묻는다.**
> Step 8 끝의 분기에서 사용자가 "문서화 진행" 답한 경우만 들어옴. 종류는 아래 셋 (조합 가능).

이 스킬은 다음 4 결의 인박스 + 정착 구조를 가정한다 (프로젝트에 같은 구조 있으면 사용, 없으면 사용자 컨벤션에 맞춤):

```
docs/_inbox/
├── research/      → docs/research-notes/ 로 정제 승격
├── spec/          → docs/feature-specs/{기능}.md 로 정제 승격
├── patch/         (영구 보관, 무갱신)
└── scratch/       (plan/audit/ideation 등 일회성)
```

세 결의 산출물이 있다. 사용자 의도에 맞춰 선택 / 조합:

### 9-A. Patch Note (사이클 회고)

작성 결: "이번 사이클에 뭘 왜 했나" — 시점에 묶임. 무갱신.

- 위치: `_inbox/patch/YYYY-MM-DD-<slug>.md`
- 파일명: 사이클 식별자 (예: `2026-05-21-modal-overhaul.md`, `2026-05-21-thread-list-icx-286.md`)
- 골격:

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

작성 결: "이렇게 동작한다 / 이때는 이렇게 한다" — 일반화. 블로그 가능 수준.

승격 흐름:
1. **사이클 중 발견** → `_inbox/research/YYYY-MM-DD-<slug>-tech.md` 에 draft (패치노트와 같은 사이클에서 쌍으로 작성 자주)
2. **정제 시점** → `docs/research-notes/<slug>.md` 로 옮기며 일반화·블로그 톤
   - cross-product 가치 있으면 root `../docs/research-notes/` (모노레포)
   - 원본 _inbox draft 는 삭제

후보 발굴 기준 (참고):
- 다른 상황에도 적용될 **패턴**을 발견 (예: token-inject proxy)
- 도구/플랫폼의 **비직관적 동작** 을 파헤침 (예: next/image 의 width 와 CSS 우선순위)
- 사람이 다시 마주칠 **함정 / 자주 헷갈리는 지점**

작성 시 후보 목록을 사용자에게 제시하며 의견 묻기:

```
이번 사이클에서 정착할만한 기술 포인트:

1. <포인트1 — 한 줄 요약>
2. <포인트2 — 한 줄 요약>
3. <포인트3 — 한 줄 요약>

골라주시면 작성합니다 (번호 / 통합 / 거절 / 추가).
```

### 9-C. Feature Spec 갱신 (구현 사양 정착)

작성 결: "이 기능은 지금 이렇게 동작한다" — 현재 상태. 사이클마다 갱신.

승격 흐름:
1. **사이클 중 사양 변화 발견** → `_inbox/spec/YYYY-MM-DD-<slug>.md` 에 draft (선택)
2. **사이클 종료** → `docs/feature-specs/{기능}.md` 본문 갱신:
   - 본문은 **현재 사양만** (이전 동작 X)
   - 변경 이력 섹션에 patch 링크로 역참조

변경 이력 양식:
```md
## 변경 이력

- 2026-04-29: 초안 ([oauth-flow](../_inbox/patch/oauth-flow.md))
- 2026-05-08: returnTo 도입 ([sns-account-feature](../_inbox/patch/2026-05-08-sns-account-feature.md), ICX-265)
- 2026-05-25: Gmail OAuth 분리 ([gmail-oauth-migration](../_inbox/patch/2026-05-25-gmail-oauth-migration.md), ICX-270)
```

이 패턴으로 PM 원문 (`open-specs/`) 과 실제 구현 (`feature-specs/`) 정합성 점검 + 사이클별 변천사 추적 가능.

### 어떤 결을 쓸지 가이드

| 사이클이 한 게 | 추천 산출물 |
|---|---|
| 사양 변화 없음, 일회성 버그픽스 / 리팩터 | 9-A (patch) 만 |
| 사양 변화 + 정착할 패턴 발견 | 9-A + 9-B + 9-C |
| 사양 변화만 (재사용 패턴 없음) | 9-A + 9-C |
| 정착할 패턴은 있는데 사양은 그대로 | 9-A + 9-B |

작성 시 필요하면 프로젝트 reviewer/research agent 와 주고받으며 다듬는다. 사용자와도 사이클 한두 번 더 돌아 톤·범위 맞추기.

> ⛔ 작업 사이클 완료. 후속 작업 있으면 알려주세요.

---

## 4원칙 짧은 인용 (Step 4/5 self-monitor 용)

- **Think Before Coding** — 모호하면 가정 명시, 추측 X
- **Simplicity First** — 요청된 최소 코드만. 한 번 쓸 추상화 X
- **Surgical Changes** — 변경된 모든 줄이 사용자 요청과 직접 연결돼야
- **Goal-Driven** — 검증 없이 완료 선언 X

(출처: Karpathy 의 CLAUDE.md gist — 더 자세한 인용은 프로젝트 CLAUDE.md 또는 AGENTS.md 참조)

---

## 안티 패턴 (회피 체크리스트)

작업 중 다음 신호가 보이면 멈추고 단순화 가능한지 자문:

- 단일 사용 const 또는 헬퍼 함수 — 인라인 가능?
- 한 PR 안에 **무관 영역** 변경 (예: 핵심 피처 + 무관 prettier 통일)
- RSC prop 을 `useState` 로 미러링 — 동기화 깨짐 위험
- `useEffect` 로 prop → state 동기화 — 보통 derived state 또는 `key` 패턴이 idiomatic
- "검증 (typecheck/lint) 통과 = 완료" 라고 선언 (실제 행동 검증 X)
- 큰 결정 (컨벤션 변경, 라이브러리 도입) 을 사용자 합의 없이 강행
- agent/스킬 호출이 중첩되거나 동일 작업 중복 수행
- TODO 주석을 동시에 5개 이상 흩뿌림 — 그 자리에서 처리 또는 별도 이슈로

---

## 에이전트 / 스킬 협업 (있을 때만)

각 단계에서 도움이 되는 자산이 프로젝트에 있다면 호출:

| Step | 후보 자산 (있을 때만) |
|---|---|
| 1, 2 | 화면/기획 planner agent (예: screen-planner) |
| 4 | implementation / publisher agent (예: frontend-developer, publisher) |
| 5 | review agent (예: frontend-reviewer, code-reviewer) |
| 9 | research-note / spec writer agent (있다면) |

**없으면 그냥 직접 수행**. 스킬 자체가 워크플로우를 갖고 있으므로 외부 자산 의존 X.

> superpowers 플러그인을 함께 쓰는 환경이면 `feature-flow-superpowers` 변형 스킬 권장 — 각 step 에 superpowers 스킬 (brainstorming, writing-plans, executing-plans, TDD 등) 명시 호출이 박혀있음.

---

## 메모

- 이 스킬은 **사이클을 끌고 가는 가이드**이지, 단계 자동 실행기가 아님.
- 각 step 종료의 체크포인트가 핵심 — 사용자가 페이스를 잡아야 다음으로.
- args 가 자연어로 들어오면 **새 작업의 주제 명시**로 받아 Step 1 부터 시작.
- 단계 키워드 args 는 **현재 진행 중 작업이 있을 때** 점프용.
- `_inbox/{research,spec,patch,scratch}` 구조는 권장 — 프로젝트에 다른 컨벤션이 있으면 그에 맞춤.
