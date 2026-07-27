<!-- tone-lint: off (지양 예문을 담고 있어 자기 검출 제외) -->

# Claude Code Skills

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) 이 만든 Claude Code 스킬 모음.

---

## ⭐ korean-tone — 클로드의 한국어가 번역기 같을 때

> **"이 함수에 대해 리팩토링을 진행하겠습니다"**
>
> 클로드는 한국어로 말할 때 이런 문장을 쓴다. 뜻은 맞는데 사람이 쓴 것 같지가 않다.
> korean-tone 은 이 딱딱함만 걷어낸다 — **코드와 정확성은 그대로 두고.**

### 이렇게 바뀐다

**계획·구현 설명**

```diff
- 이 함수에 대해 리팩토링을 진행하겠습니다.
+ 이 함수를 리팩토링할게.

- 캐싱을 통해 성능 향상을 도모할 수 있습니다.
+ 캐싱을 넣으면 성능이 올라가.

- 입력값 검증이 수행되며, 수정이 이루어졌습니다.
+ 여기서 입력값을 검증해. 고쳤어.
```

**전문용어는 지우지 않고 통역한다**

```diff
- handler 가 stub 이었다.
+ 웹훅을 받아놓고 저장을 안 했어. 껍데기만 있고 안이 비어 있던 거지.

- client_id 가 틀렸다.
+ client_id 가 틀렸어 — 인스타 전용 앱 ID 를 써야 하는 자리에 메타 앱 ID 를 썼어.
```

`client_id` 는 `client_id` 로 남는다. **저장소에서 검색되는 이름(함수·파일·필드·커밋)은
좌표라서 손대지 않는다.** 억지로 "고객 식별자"로 바꾸면 사용자가 그 대상을 못 찾는다.

**내부 작업 용어는 사용자 화면에서 걷어낸다**

```diff
- [충돌 A] OCR 품질 게이트를 어떻게 처리할까요?
-   (현재: 'acceptable verbatim quality' — 측정 불가 지적)
+ AI 가 손글씨를 잘 읽는지 언제 확인할까요?

- 온톨로지를 어떻게 고칠까요? (QA: auth_provider 누락 지적)
+ 데이터 구조를 정리할까요?
```

`AC7`, `이터레이션`, `수렴 제안` 같은 말은 클로드의 작업 어휘지 당신의 어휘가 아니다.

### 두 겹으로 동작한다

대부분의 스타일 가이드는 "이렇게 써라"로 끝나서, 모델이 흘리면 잡을 방법이 없다.
korean-tone 은 그 위에 **검사 층**을 얹는다.

| 층 | 무엇 | 어떻게 |
|---|---|---|
| **소프트** — 스킬 | 어떻게 쓸지 정한다 | 한국어로 말할 때 규칙이 항상 적용됨 |
| **하드** — `tone-linter` 훅 | 흘린 걸 잡는다 | 한국어 `.md` 를 저장할 때마다 번역투를 스캔해 짚어줌 |

린터는 국립국어원 논문·토스 테크니컬 라이팅 가이드·이오덕 『우리글 바로쓰기』에서
추린 패턴을 쓴다. **오탐이 거의 없는 error 급**(`~에 의해`, 이중피동, `~에 있어서`, `그녀`)과
**빈도로 판단하는 warn 급**(`~를 통해`, `것이다`, 메타 담화)을 나눠서 본다.
코드블록·인라인 코드·URL 은 검사에서 빼고, 파일에 `<!-- tone-lint: off -->` 를 넣으면 건너뛴다.

저장을 막지 않는다 — 이미 쓴 파일에 "여기 번역투 있어"라고 알려줄 뿐이라 흐름이 끊기지 않는다.

### 어디에 쓰나

CLI 에서 계획·구현·리뷰를 설명할 때 자동으로 적용된다. 문서를 쓸 때는 종류별 규칙이 더 붙는다.

- **체크리스트·백로그** — 한 줄에 압축하지 말고 개념 단위로 줄바꿈
- **설계 결정 기록(ADR)·연구노트** — 담백한 `~다` 문어체 + 표준 ADR 구조(상태·검토한 대안·트레이드오프)
- **선택지 제시** — 질문엔 결정만, 설명엔 사용자가 겪을 결과만

### 설치

```bash
/plugin marketplace add seungboshim/skills
/plugin install korean-tone@seungboshim-skills
```

훅까지 자동으로 걸린다. `npx skills` 로 설치했다면 훅은
[별도 등록](skills/korean-tone/hooks/README.md)이 필요하다.

---

## 나머지 스킬

### shimmy-tone

개발 블로그(벨로그) 저술 보이스 — 일상 비유, 어그로 제목과 반전, 밈·이모지로 어려운 개념을
재밌게 가르친다. korean-tone 위에 얹히는 개인화 스킬이라, 번역투 금지는 유지하되
"이모지 자제" 가드만 의도적으로 푼다.

### feature-flow

화면/기능 하나를 처음부터 끝까지 끌고 가는 사이클 가이드 — scope → plan → execute → review → commit → document.

- 9 단계, 각 전환마다 사용자 체크포인트
- 실행 중 Karpathy 4원칙 self-monitoring (Think / Simple / Surgical / Goal-driven)
- 선택적 문서화 단계 — `_inbox/{research,spec,patch,scratch}` → `research-notes/` / `feature-specs/` 승격 흐름
- 프로젝트 독립적 — 기존 컨벤션에 맞춰짐

### feature-flow-superpowers

feature-flow 의 superpowers 통합 버전. 각 step 에서 매칭되는 superpowers 스킬을 명시적으로 호출.

- [superpowers](https://github.com/obra/superpowers) 플러그인 필요
- `superpowers:test-driven-development` 로 TDD-first 실행
- `superpowers:verification-before-completion` 으로 evidence-based 완료
- 4원칙 ↔ TDD 결 충돌 명시적 해결

### daily

세션 오리엔트 + 작업 추천 — backlog·최근 패치노트·git 상태를 읽어 "지금 어디" 지도와 우선순위 "오늘 뭐" 목록을 만든다.

- 읽기 전용 — 오리엔트·추천만, 파일 수정 X
- backlog/patch 컨벤션 발견 (프로젝트 독립적)
- feature-flow 의 사이클 입구로 짝

### worklog

작업 후 문서화 의식 — 간결한 release-note 패치노트 + (동작 변화 시) feature-spec 갱신 + backlog 체크를 한 번에.

- 전체 사이클과 분리 — 어떤 작업 후에도 단독 호출
- 프로젝트 독립적 — 문서 컨벤션 발견
- feature-flow 의 사이클 출구로 짝

### tailwind-design-system

Tailwind CSS + Next.js 프로젝트용 디자인 시스템 빌더·리팩터링 가이드.

- 디자인 프롬프팅부터 style audit, semantic token 정의, 공유 컴포넌트 추출, 마이그레이션, 지속 compliance 리뷰까지
- 신규 프로젝트 (Phase 0: 디자인 프롬프팅) + 기존 프로젝트 (Phase 1: style audit) 모두 지원
- 디자인 토큰 준수를 위한 ongoing audit 모드

---

## 설치

### Claude Code 플러그인 경유 (권장)

```bash
/plugin marketplace add seungboshim/skills
/plugin install korean-tone@seungboshim-skills
```

원하는 것만 골라 설치한다:

```bash
/plugin install shimmy-tone@seungboshim-skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```

### skills.sh 경유 (모든 agent 대상)

```bash
npx skills add seungboshim/skills
```

Claude Code 외 다른 에이전트에서도 쓸 수 있다. 다만 korean-tone 의 훅은 따로 등록해야 한다
([안내](skills/korean-tone/hooks/README.md)).

## 라이선스

MIT
