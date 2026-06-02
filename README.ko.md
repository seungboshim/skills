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
/plugin install tailwind-design-system@seungboshim-skills
```
