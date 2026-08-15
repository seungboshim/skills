#!/usr/bin/env bash
# collect.sh 자기 점검. 임시 저장소를 하나 만들어 사건을 심고, 자료에 그게 잡히는지 본다.
#
#   bash scripts/test-collect.sh
#
# 실패하면 어느 단정이 깨졌는지 출력하고 1 로 끝난다.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TMP=$(mktemp -d -t truman-test)
trap 'rm -rf "$TMP"' EXIT

FAIL=0
check() { # check <설명> <찾을 문자열>
  if grep -qF "$2" "$TMP/out.md"; then
    echo "  ok   $1"
  else
    echo "  FAIL $1 — '$2' 를 못 찾았다"
    FAIL=1
  fi
}

# ── 사건을 심는다
REPO="$TMP/repo"
mkdir -p "$REPO"
git -C "$REPO" init -q
git -C "$REPO" config user.email "test@truman.local"
git -C "$REPO" config user.name "Truman Test"

echo "hello" > "$REPO/a.txt"
git -C "$REPO" add a.txt
git -C "$REPO" commit -qm "feat: 첫 장면을 심는다"

echo "again" >> "$REPO/a.txt"          # 같은 파일을 다시 만진다
git -C "$REPO" add a.txt
git -C "$REPO" commit -qm "fix: 같은 파일을 또 고친다"

git -C "$REPO" reset -q --soft HEAD~1  # 극적인 순간
git -C "$REPO" commit -qm "fix: 되돌리고 다시 커밋"

echo "dirty" > "$REPO/b.txt"           # 미완성 (커밋 안 한 변경)

# ── 자료를 모은다. 세션 기록은 빼고 이 임시 저장소만 본다.
cd "$REPO"
bash "$HERE/collect.sh" --root "$TMP" --no-claude --hours 1 --out "$TMP/out.md" >/dev/null

echo "collect.sh 자기 점검"
check "구간 머리말이 있다"        "# 촬영 자료"
check "커밋 섹션이 있다"          "## 커밋"
check "첫 커밋이 잡힌다"          "feat: 첫 장면을 심는다"
check "되돌린 뒤 커밋이 잡힌다"   "fix: 되돌리고 다시 커밋"
check "반복 수정 파일이 잡힌다"   "repo/a.txt"
check "극적인 순간에 reset 이 있다" "reset:"
check "어록 섹션이 있다"          "## 어록"
check "미완성이 잡힌다"           "커밋 안 한 변경"
check "세션 제외가 반영된다"      "제외했다 (--no-claude)"

if [ "$FAIL" -eq 0 ]; then
  echo "전부 통과"
else
  echo "실패 있음"
fi
exit "$FAIL"
