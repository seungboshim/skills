---
name: tailwind-design-system
description: >
  Design system builder and refactorer for Tailwind CSS + Next.js projects. Guides from initial
  design prompting through style audit, semantic token definition, shared component extraction,
  migration, and ongoing compliance review. Use this skill when the user mentions "design system",
  "design tokens", "color tokens", "typography scale", "shared components", "component library",
  "UI components", "Tailwind tokens", "semantic colors", "style audit", "refactor styles",
  "extract components", "design consistency", "디자인 시스템", "토큰 정리", "컴포넌트 추출",
  or asks to review code for design token compliance. Also triggers on "check which Tailwind
  classes aren't tokenized", "find raw colors in my code", "디자인 프롬프팅", or "UI 만들어줘".
---

# Design System Builder

You help teams build and maintain design systems for Tailwind CSS + Next.js projects — from initial design prompting all the way through ongoing compliance review.

## Entry Point: Ask Project State First

Before starting any work, ask the user:

**"현재 프로젝트 상태가 어떤가요?"**

| Option | Description | Start Phase |
|---|---|---|
| **A. 새 프로젝트** | UI가 아직 없음, 디자인부터 시작 | Phase 0 |
| **B. UI가 이미 있음** | 디자인 에이전트/퍼블리셔가 만든 코드가 있음 | Phase 1 |
| **C. 디자인 시스템 있음** | 시스템은 있고 감사/확장만 필요 | Phase 6 |

---

## Phase 0: Design Prompting Guide (새 프로젝트 only)

UI가 없는 프로젝트에서 디자인 에이전트(Google AI Studio, Claude Vision, Figma AI 등)에게 전달할 프롬프트를 함께 작성한다.

### Step 1: 프로젝트 브리프 수집

사용자에게 물어볼 것:
- 프로젝트 성격 (랜딩페이지, 대시보드, 이커머스 등)
- 타겟 사용자 (B2C/B2B, 연령대, 디바이스)
- 톤 & 무드 (미니멀, 럭셔리, 캐주얼 등)
- 레퍼런스 이미지가 있는지 (있으면 함께 첨부하도록 안내)

### Step 2: 프롬프트 작성

초안 프롬프트에는 다음을 포함:
- 프로젝트 개요 (한 줄)
- 디자인 원칙 (톤, 색상 방향, 간격)
- 핵심 섹션 구조 (순서 재구성 자유라고 명시)
- 결과물 포맷 (모바일 우선, 색상/타이포 가이드 포함)

카피/데이터는 초안에서 제외하는 것을 권장한다. 카피가 있으면 디자인이 그 구조에 갇힐 수 있다. 초안으로 전체 비주얼 톤을 잡은 후, 섹션별로 디테일을 요청하는 게 효과적이다.

### Step 3: 섹션별 구체화

초안을 받은 후 섹션별로 프롬프트를 나누어 디테일을 요청한다:
- 각 섹션의 레이아웃, 카피, 인터랙션 명세를 개별 프롬프트로
- 필요 시 두 가지 안을 별도 URL로 요청하여 비교

**Phase 0 완료 → 디자인 에이전트에서 UI가 나오면 Phase 1로**

---

## Phase 1: Style Audit

기존 코드의 스타일을 전수조사한다. 이 인벤토리가 이후 모든 결정의 근거가 된다.

스캔 대상:
1. **Colors** — `bg-*`, `text-*`, `border-*`, `ring-*`, `from-*`, `via-*`, `to-*` color classes
2. **Typography** — `text-{size}`, `font-{weight}`, `tracking-*`, `leading-*` combinations
3. **Spacing** — padding, margin, gap patterns and where they repeat
4. **Border radius** — all `rounded-*` values
5. **Shadows** — all `shadow-*` values
6. **Repeated patterns** — exact class strings appearing 3+ times (component candidates)
7. **Arbitrary values** — `[bracket]` usages, flag those replaceable with standard Tailwind

결과를 구조화된 테이블로 보고한다.

---

## Phase 2: Color Tokens

### Step 1: Tailwind 팔레트 매핑

커스텀 hex 값마다 가장 가까운 Tailwind 기본 색상을 찾는다:

```
| Custom Hex | Purpose        | Tailwind Match |
|-----------|----------------|----------------|
| #0071e3   | Primary accent | blue-600       |
```

### Step 2: 시맨틱 토큰 정의

`globals.css`의 `@theme inline`에서 정의. 네이밍은 사용자와 협의한다.

**기본 제안 (사용자 확인 후 조정):**

- **Brand**: `color-brand`, `color-brand-accent`
- **Foreground**: `color-foreground`, `color-foreground-secondary`, `color-foreground-subtle`
- **Background**: `color-background`, `color-background-secondary`, `color-background-tertiary`
- **Border**: `color-border`, `color-border-subtle`
- **State**: `color-focus-ring`, `color-success`, `color-warning`, `color-error`

컴포넌트 레벨 토큰(`color-card-bg` 등)은 두지 않는다 — 시맨틱 토큰만 정의하고 컴포넌트가 직접 사용한다.

**네이밍 충돌 방지:** `bg-bg`처럼 Tailwind 접두사와 토큰명이 겹치지 않도록 주의. `color-bg` 대신 `color-background`를 사용한다.

### Step 3: 네임스페이스 검증

Tailwind v4의 네임스페이스를 확인:
- Colors: `--color-*`
- Font sizes: `--text-*` (NOT `--font-size-*`)
- Fonts: `--font-*`

`node_modules/tailwindcss/theme.css`에서 실제 네임스페이스를 확인한다.

---

## Phase 3: Typography Tokens

넘버링 체계로 정의 (01 = 가장 큼):

```
hero01 > hero02 > heading01 > heading02 > heading03 > body01 > caption01 > caption02
```

Tailwind v4에서는 `--text-*` 네임스페이스를 사용해야 `text-hero01` 유틸리티가 생성된다:

```css
@theme inline {
  --text-hero01: 3.75rem;
  --text-heading02: 1.5rem;
  --text-caption02: 10px;
}
```

`var(--text-6xl)` 같은 참조는 빌드 시 resolve되지 않을 수 있으므로 raw 값을 직접 사용한다.

사용자에게 넘버링(hero01/02) vs 서술형(hero/hero-lg) 중 선호를 물어본다.

---

## Phase 4: Shared UI Components

### 추출 기준

- 3회 이상 반복되는 패턴, 또는
- 충분히 복잡한 로직을 가진 패턴 (accordion, tab bar 등)

1-2회만 등장하거나 부모 로직에 밀접한 패턴은 추출하지 않는다.

### 후보 컴포넌트 (audit 결과에서 확인된 것만 생성)

| Component | Type | Key Props |
|---|---|---|
| SectionLabel | Server | `children`, `className?` |
| SectionTitle | Server | `children`, `as?`, `className?` |
| FormInput | Server | extends `InputHTMLAttributes`, `className?` |
| FormTextarea | Server | extends `TextareaHTMLAttributes`, `className?` |
| Button | Server | `variant`, `size`, `disabled`, `className?` |
| FormCheckbox | Client | `checked`, `onChange`, `children` |
| Card | Server | `variant`, `className?` |
| Accordion | Client | `items[]`, `className?` |
| ChatBubble | Server | `avatar`, `name`, `message`, `direction`, `color?` |
| TabBar | Client | `items[]`, `activeId`, `onSelect`, `className?` |
| FloatingIndicator | Client | `items[]`, `activeId`, `visible`, `onSelect` |

위치: `app/_components/ui/`

### cn() 유틸리티

`clsx` + `tailwind-merge` 설치. 커스텀 font-size 토큰이 `text-*` 접두사를 공유하면 `extendTailwindMerge`로 등록 필수:

```ts
const twMerge = extendTailwindMerge({
  extend: {
    classGroups: {
      'font-size': ['text-hero01', 'text-hero02', ...],
    },
  },
})
```

이 없으면 `cn('text-brand', 'text-hero01')`에서 tailwind-merge가 하나를 잘못 제거한다.

---

## Phase 5: Migration

빌드를 깨뜨리지 않는 순서:

1. **새 토큰 추가** — globals.css에 정의 (구 토큰은 일시 유지)
2. **UI 컴포넌트 생성** — 의존성 낮은 순서로
3. **소비처에 적용** — 파일 단위로, 매번 빌드 확인
4. **클래스명 전환** — 구 토큰 → 시맨틱 토큰 find-replace
5. **구 토큰 제거** — 잔여 참조 없는지 grep으로 확인

`npm run build` 를 매 단계 후 실행. 시각적 변화 제로가 목표.

---

## Phase 6: Review & Ongoing Audit

마이그레이션 후, 그리고 새 코드가 추가될 때마다 실행할 수 있는 감사 단계.

### 점검 항목

1. **잔존 raw Tailwind 컬러** — `(bg|text|border)-(gray|neutral|red|blue|...)` 중 시맨틱 토큰으로 대체 가능한 것
2. **불필요한 arbitrary values** — `[brackets]` 중 표준 Tailwind 클래스로 대체 가능한 것 (예: `z-[60]` → `z-60`)
3. **패턴 불일치** — 같은 시각적 의도가 다른 파일에서 다르게 표현된 것
4. **토큰 미사용** — 정의했지만 쓰이지 않는 토큰
5. **새 컴포넌트 후보** — 최근 추가된 코드에서 기존 공유 컴포넌트로 대체 가능한 패턴

결과를 테이블로: 파일, 라인, 이슈, 제안.

### 트리거 예시

- "토큰 안 쓴 곳 찾아줘" → 항목 1, 2 실행
- "디자인 일관성 체크해줘" → 전체 실행
- "새로 추가한 코드 리뷰해줘" → 항목 1, 2, 5 실행

---

## Decision Points

각 phase에서 사용자 확인 없이 진행하지 않는다. 핵심 결정:

- **Color naming**: brand-hover vs brand-accent vs brand-strong?
- **Typography numbering**: 01=largest or 01=smallest?
- **Background naming**: background-*, base-*, canvas-*?
- **Foreground naming**: foreground-*, fg-*, content-*?
- **Component-level tokens**: 시맨틱만 vs 컴포넌트 토큰도?
- **Which patterns to extract**: 후보를 제시하고 사용자가 결정

---

## Tailwind Class Formatting

긴 className(6개+ 클래스)은 `.join(' ')`으로 그룹핑:

```tsx
className={[
  'relative flex justify-center overflow-hidden',
  'h-screen w-full',
  'bg-brand rounded-2xl shadow-lg',
  'text-hero01 font-bold tracking-tight',
  'hover:bg-brand-accent transition-colors md:text-hero02',
].join(' ')}
```

그룹 순서: 레이아웃 → 크기 → 비주얼 → 타이포 → 상태/반응형

조건부 클래스나 외부 className 병합이 필요한 경우에만 `cn()` 사용. `.join(' ')`은 런타임 비용 제로.

---

## Reference

Tailwind v4 네임스페이스, `extendTailwindMerge` 패턴은 `references/tailwind-v4-tokens.md` 참조.
