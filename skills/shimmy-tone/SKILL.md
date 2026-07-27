---
name: shimmy-tone
description: >
  seungboshim(Shim)의 개인 저술 보이스로 글을 쓴다. 캐주얼·유머·전파용 개발 블로그
  스타일 — 일상 비유, 어그로 제목과 반전, 밈·이모지, 취소선 농담, 독자 호출로 어려운
  개념을 재밌고 쉽게 가르친다. 벨로그·개발 블로그 글을 새로 쓰거나, 기존 내용을 블로그
  글로 각색·정리할 때 쓴다. korean-tone(범용 어투 교정) 위에 얹히는 개인화 스킬.
  트리거: "/shimmy-tone", "블로그 글 써줘", "벨로그", "개발 블로그", "이거 블로그로",
  "블로그로 정리", "글감으로", "shimmy 톤", "내 블로그 말투로".
license: MIT
metadata:
  author: seungboshim
  locale: ko
  version: "1.1.0"
---

# Shimmy Tone — Shim의 개인 저술 보이스

seungboshim의 글쓰기 스타일로 쓰는 스킬. 지금은 **개발 블로그(벨로그)** 보이스 하나를
담는다. 캐주얼하고 재밌게, 어려운 개념을 비유로 풀어 전파하는 톤이다.

## korean-tone 위에 얹힌다

이 스킬은 **korean-tone을 대체하지 않고 그 위에 얹힌다.** korean-tone은 별도 저장소에 있다
— [fromshim/korean-tone](https://github.com/fromshim/korean-tone)
(`/plugin install korean-tone@fromshim`). 함께 설치해 두는 편이 좋다.

1. 먼저 **korean-tone 공통 어투 규칙**을 적용한다 — 번역투·과한 수동태·한자 과압축·상투
   반복 제거. (블로그도 번역기 돌린 문장은 안 된다.)
2. 그 위에 아래 아티팩트 보이스를 얹는다.

**중요 — 가드 완화:** korean-tone의 "이모지·유행어·구어체 자제" 가드는 블로그 보이스에서
**의도적으로 푼다.** 밈·이모지·취소선 농담이 이 톤의 핵심이기 때문. 단, 번역투 금지와
"정확성이 유머보다 우선" 원칙은 그대로다.

## 언제 쓰나

- 벨로그·개발 블로그 글을 새로 쓸 때
- 이미 만든 기능·해결 과정을 블로그 글로 각색·정리할 때
- 사용자가 "블로그 톤으로", "내 말투로 써줘" 라고 할 때

설계 기록·연구노트처럼 담백한 문어체 글은 이 스킬이 아니라 **korean-tone**의
[`references/research-note.md`](https://github.com/fromshim/korean-tone/blob/main/references/research-note.md)를 쓴다.

## 요소별 보이스

- **개발 블로그 (벨로그)** → `references/blog.md`
- (다른 개인 저술 스타일 — 사용자가 예시를 주면 여기에 추가)

---

## 이 스킬 키우는 법 (유지보수 메모)

사용자가 자기 글 예시나 "이렇게 고쳐줘" 피드백을 주면:

1. 어떤 보이스 장치(비유·밈·구조 등)를 쓰는지 뽑는다.
2. 특정 아티팩트(블로그 등)에만 통하면 → `references/<아티팩트>.md`에 반영.
3. 여러 아티팩트에 공통으로 통하는 저술 습관이면 → 이 SKILL.md에.
4. 번역투 제거처럼 매체 무관 공통 교정이면 → 여기 말고 **korean-tone**에 넣는다.
