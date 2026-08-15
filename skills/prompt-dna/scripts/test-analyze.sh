#!/usr/bin/env bash
# analyze.sh 자기 점검. 값을 아는 가짜 세션 기록을 만들어 지표가 그대로 나오는지 본다.
#
#   bash scripts/test-analyze.sh
#
# 실패하면 어느 단정이 깨졌는지 출력하고 1 로 끝난다.

set -uo pipefail
export TZ=Asia/Seoul   # 시간대에 따라 새벽 비중이 달라지므로 고정한다

HERE="$(cd "$(dirname "$0")" && pwd)"
TMP=$(mktemp -d -t promptdna-test)
trap 'rm -rf "$TMP"' EXIT

FAIL=0
check() { # check <설명> <찾을 문자열>
  if grep -qF "$2" "$TMP/out.md"; then echo "  ok   $1"
  else echo "  FAIL $1 — '$2' 를 못 찾았다"; FAIL=1; fi
}
absent() { # absent <설명> <없어야 하는 문자열>
  if grep -qF "$2" "$TMP/out.md"; then echo "  FAIL $1 — '$2' 가 출력에 새어나왔다"; FAIL=1
  else echo "  ok   $1"; fi
}

# ── 값을 아는 기록을 심는다. 시각은 UTC 로 적고 KST 로 읽힌다.
P="$TMP/projects/-tmp-fake"
mkdir -p "$P"
LOG="$P/session.jsonl"
CWD="/tmp/fake-repo"
LONG=$(printf '가%.0s' $(seq 1 200))

rec() { # rec <timestamp> <content> [promptSource]
  local ts="$1" content="$2" src="${3:-typed}"
  if [ "$src" = "none" ]; then
    printf '{"type":"user","message":{"role":"user","content":"%s"},"timestamp":"%s","cwd":"%s","sessionId":"s1"}\n' \
      "$content" "$ts" "$CWD" >> "$LOG"
  else
    printf '{"type":"user","promptSource":"%s","message":{"role":"user","content":"%s"},"timestamp":"%s","cwd":"%s","sessionId":"s1"}\n' \
      "$src" "$content" "$ts" "$CWD" >> "$LOG"
  fi
}

rec "2026-07-01T01:00:00.000Z" "ㄱㄱ 해줘"                        # 10:00 KST
rec "2026-07-01T02:00:00.000Z" "확인해줘 맞나"                    # 11:00 KST, 확인 1건
rec "2026-07-01T03:00:00.000Z" "이거 고쳐줘 지금 바로"            # 12:00 KST
rec "2026-07-01T04:00:00.000Z" "SECRET-TOKEN-DO-NOT-PRINT ${LONG}" # 13:00 KST, 장문
rec "2026-07-01T17:00:00.000Z" "새벽에 짧게"                      # 02:00 KST → 새벽 1건
rec "2026-07-01T05:00:00.000Z" "TOOL-RESULT-SHOULD-NOT-COUNT" none # typed 아님 → 제외

bash "$HERE/analyze.sh" --root "$TMP/projects" --out "$TMP/out.md" >/dev/null

echo "analyze.sh 자기 점검"
check "지시 5건만 센다 (typed 아닌 기록 제외)" "지시 5건"
check "세션 1개"                                "세션 1개"
check "자모 표현에 ㄱㄱ 가 잡힌다"              "ㄱㄱ 1회"
check "말버릇에 한글 낱말이 잡힌다"             "고쳐줘"
check "새벽 1건 (20%)"                          "새벽(00~05시) 1건 (20%)"
check "확인 요청 1건 (20%)"                     "확인·검증을 요청한 지시: 20%"
check "붙여넣기 판정 대상이 없다"               "2000자 초과) 0건"
check "유형 코드가 SNTF 로 확정된다"            "유형 코드: SNTF**"
absent "원문 지시가 새지 않는다"                "SECRET-TOKEN-DO-NOT-PRINT"
absent "typed 아닌 기록의 본문이 안 나온다"     "TOOL-RESULT-SHOULD-NOT-COUNT"

if [ "$FAIL" -eq 0 ]; then echo "전부 통과"; else echo "실패 있음"; fi
exit "$FAIL"
