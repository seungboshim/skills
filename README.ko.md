# Claude Code Skills

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) 이 만든 Claude Code 스킬 모음.

## 스킬 목록

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

## 설치

### skills.sh 경유 (모든 agent 대상)

```bash
npx skills add seungboshim/skills
```

### Claude Code 플러그인 경유

```bash
/plugin marketplace add seungboshim/skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```
