---
name: worklog
description: >
  Post-work documentation ritual. After finishing a chunk of work (a fix,
  feature, refactor, or cycle), produces a concise release-note-level patch note,
  updates the relevant feature spec if behavior changed, and ticks/updates the
  backlog. Use whenever the user wants to log, document, or wrap up work they just
  did — e.g. "/worklog", "패치노트 써줘", "이번 작업 정리하자", "방금 한 거
  문서화", "작업 기록 남겨", "release note", "log what we did", "wrap up this
  cycle", "이거 끝났는데 정리". Trigger even without the word "worklog" — any
  "write down what we just did / update the docs for this change" intent counts.
  Generalized: discovers the project's doc conventions rather than assuming one repo.
license: MIT
metadata:
  author: seungboshim
  locale: ko
  version: "1.0.0"
---

# Worklog — 작업 후 문서화 의식

한 덩어리의 작업(버그픽스 / 기능 / 리팩터 / 사이클)을 끝낸 뒤, **간결한 패치노트 + 사양 갱신 + backlog 갱신** 을 한 번에 처리하는 스킬. 전체 작업 사이클(`feature-flow`)을 돌리지 않고 자유롭게 작업했더라도, 끝에 이걸 호출하면 기록이 정착된다. 문서 위치/형식은 **발견** 한다 — 특정 레포에 묶이지 않는다.

## 호출 형태

```
/worklog            # 방금 한 작업을 파악해 문서화
/worklog <주제>      # 주제를 명시 (사이클이 여러 갈래였을 때)
```

## Step 0 — 작업 파악 (먼저)

문서를 쓰기 전에 "이번에 뭘 했나" 를 확정한다:

1. `git status --short` + `git diff` (스테이징·언스테이징) + 브랜치명
2. 이 브랜치/사이클의 커밋: `git log --oneline main..HEAD` (또는 최근 N개)
3. 현재 대화 컨텍스트(무슨 의도로 뭘 고쳤나)

→ **한 문장 사이클 요약** 을 만들고, 애매하면 사용자에게 한 번 확인. (여러 갈래면 분리할지 묻기)

## 무엇을/어디에 쓰나 (컨벤션 발견)

하드코딩 X. 프로젝트에서 다음을 찾아 그 컨벤션을 따른다:

- **결(grain) 컨벤션 문서**: `docs/README.md` / `CLAUDE.md` / `AGENTS.md` 가 문서 구조를 기술하면 **그게 우선**. (예: patch 는 `_inbox/patch/`, 사양은 `feature-specs/`, 변경이력은 patch 링크로 역참조 — 이런 규칙이 있으면 그대로)
- 없으면 아래 기본 구조를 가정하되, 사용자에게 맞는지 한 번 확인:

  ```
  docs/_inbox/patch/   # 패치노트 (영구 보관, 무갱신)
  docs/feature-specs/  # 현재 사양 (사이클마다 갱신)
  backlog.md           # 미완료 작업 목록
  ```
- 그것도 없으면: `CHANGELOG.md` 추가 + 사용자 컨벤션 질의.

## 산출물 (사용자 선택 — 셋 중 필요한 것)

먼저 무엇을 쓸지 사용자에게 제시하고 고르게 한다. "사이클이 한 게 뭐냐" 에 따라 조합이 달라진다:

| 이번 사이클이 한 게 | 추천 산출물 |
|---|---|
| 사양 변화 없는 일회성 버그픽스/리팩터 | A (패치노트) + C (backlog) |
| 사양이 바뀜 | A + B (사양 갱신) + C |
| 정착할 재사용 패턴/기술결정 발견 | + D (research note 후보) |

### A. 패치노트 (사이클 회고) — 거의 항상

"이번에 뭘 왜 했나" 를 **release-note 톤으로 간결하게**. 시점에 묶이고 이후 갱신하지 않는다.

- 위치: `<patch dir>/YYYY-MM-DD-<slug>.md` (slug = 사이클 식별자, 티켓번호 있으면 포함)
- 골격:

  ```md
  ---
  date: YYYY-MM-DD
  tags: [관련 키워드, TICKET-NNN]
  status: draft
  ---

  # <작업 제목>

  ## 0. 문서 위치 (cross-ref)   — 관련 설계/사양/이전 사이클 링크
  ## 1. 핵심 흐름                — 무엇이 어떻게 바뀌었나 (2~4줄)
  ## 2. 주요 의사결정             — 왜 이렇게 (선택지·근거)
  ## 3. 미해결 / 후속            — 다음으로 넘기는 것 (→ backlog 와 연동)
  ## 4. 관련 커밋
  ```

  **간결 우선**: 변경이 작으면 0·4 는 생략 가능. release note 처럼 "읽는 사람이 5분 안에 파악" 수준.

### B. Feature Spec 갱신 (사양이 바뀐 경우만)

"이 기능은 **지금** 이렇게 동작한다" — 현재 상태만. 이전 동작은 본문에 남기지 않는다.

1. 해당 `<feature-specs>/{기능}.md` 본문을 현재 사양으로 갱신
2. 변경 이력 섹션에 이번 패치노트를 링크로 역참조:

   ```md
   ## 변경 이력

   - YYYY-MM-DD: <한 줄 요약> ([<patch-slug>](상대경로, TICKET-NNN))
   ```

이 패턴 덕분에 PM 원문(있다면 `open-specs/`)과 실제 구현(`feature-specs/`)의 정합성 + 사이클별 변천사를 추적할 수 있다. **사양 변화가 없으면 이 단계는 건너뛴다** — 억지로 만들지 말 것.

### C. Backlog 갱신 — 거의 항상

작업이 backlog 항목을 소화했거나 새 후속을 낳았으면 반영한다 (이게 worklog 의 핵심 차별점):

1. 끝낸 항목 `- [ ]` → `- [x]` 체크 (또는 "완료" 섹션으로 이동 — 프로젝트 컨벤션 따라)
2. 이번에 새로 드러난 미해결/후속을 적절한 섹션에 추가. backlog 가 owner/blocker 별로 분류돼 있으면 (예: FE단독 / BE대기 / 정책결정) 그 분류에 맞춰 넣는다.
3. 패치노트 3절(미해결/후속)과 backlog 신규 항목이 **일치** 하게 — 한쪽에만 적히는 일 없게.

### D. Research Note 후보 (정착할 패턴이 있을 때만)

"이런 패턴/함정이 있더라" — 일반화·재사용 가능한 기술 메모. 후보를 한 줄씩 제시하고 사용자가 고르면 작성:

```
이번 사이클에서 정착할 만한 기술 포인트:
1. <포인트 — 한 줄>
2. <포인트 — 한 줄>
골라주면 작성 (번호 / 통합 / 거절).
```

발굴 기준: 다른 상황에도 적용될 **패턴**, 도구/플랫폼의 **비직관적 동작**, 다시 마주칠 **함정**. (위치는 프로젝트의 research-notes 디렉토리, 없으면 사용자 컨벤션)

## 체크포인트

- 산출물 작성 **전** 에 무엇을 쓸지 사용자에게 확인 (위 표로 제안).
- 커밋 메시지 형식은 **강제하지 않음** — 프로젝트에 형식(예: 티켓 prefix, commit-message 스킬)이 있으면 그걸 따른다.
- 작성 후 한 번 더 사용자와 톤·범위 맞추기.

> ✅ 문서화 완료. 정제 승격(예: `_inbox/spec/` → `feature-specs/`)이 별도 컨벤션이면 그 흐름도 안내.

## 메모

- worklog 는 사이클의 **출구**, `daily` 는 **입구**.
- 이 스킬은 `feature-flow` 의 문서화 단계(Step 8–9)를 독립 호출 가능하게 떼어낸 것이다. feature-flow 안에서 문서화 단계에 도달했다면 같은 절차를 여기서 참조해 수행한다.
- 프로젝트에 research/spec writer 에이전트가 있으면 작성 시 협업; 없으면 직접 수행.
