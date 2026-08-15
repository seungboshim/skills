#!/usr/bin/env bash
# analyze.sh 자기 점검. 값을 아는 가짜 세션 기록을 만들어 지표가 그대로 나오는지 본다.
#
#   bash scripts/test-analyze.sh
#
# 실패하면 어느 단정이 깨졌는지 출력하고 1 로 끝난다.

set -uo pipefail
export TZ=Asia/Seoul   # 시간대에 따라 새벽 비중이 달라지므로 고정한다

HERE="$(cd "$(dirname "$0")" && pwd)"
TMP=$(mktemp -d -t promptmbti-test)
trap 'rm -rf "$TMP"' EXIT

FAIL=0
check() { # check <설명> <찾을 문자열>
  # -e 를 붙여야 - 로 시작하는 문자열을 옵션으로 오해하지 않는다
  if grep -qF -e "$2" "$TMP/out.md"; then echo "  ok   $1"
  else echo "  FAIL $1 — '$2' 를 못 찾았다"; FAIL=1; fi
}
absent() { # absent <설명> <없어야 하는 문자열>
  if grep -qF -e "$2" "$TMP/out.md"; then echo "  FAIL $1 — '$2' 가 출력에 새어나왔다"; FAIL=1
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

# 실제 ~/.codex 를 읽지 않도록 없는 경로를 준다. 이 구간은 Claude Code 기록만 본다.
bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/no-codex" --hermes-root "$TMP/no-hermes" \
  --out "$TMP/out.md" >/dev/null

echo "analyze.sh 자기 점검"
check "지시 5건만 센다 (typed 아닌 기록 제외)" "지시 5건 (Claude Code 5 · Codex 0 · Hermes 0)"
check "작은 표본에 주의를 붙인다"                    "표본 주의: 지시가 100건 미만"
check "세션 1개"                                "세션 1개"
check "자모 표현에 ㄱㄱ 가 잡힌다"              "ㄱㄱ 1회"
check "말버릇에 한글 낱말이 잡힌다"             "고쳐줘"
check "새벽 1건 (20%)"                          "새벽(00~05시) 1건 (20%)"
check "확인 요청 1건 (20%)"                     "확인·검증을 요청한 지시: 20%"
check "붙여넣기 판정 대상이 없다"               "2000자 초과) 0건"
check "유형 코드가 SNTF 로 확정된다"            "유형 코드: SNTF**"
absent "원문 지시가 새지 않는다"                "SECRET-TOKEN-DO-NOT-PRINT"
absent "typed 아닌 기록의 본문이 안 나온다"     "TOOL-RESULT-SHOULD-NOT-COUNT"

if bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/no-codex" --hermes-root "$TMP/no-hermes" \
     --days nope >/dev/null 2>&1; then
  echo "  FAIL 잘못된 --days 를 거부하지 않았다"; FAIL=1
else
  echo "  ok   잘못된 --days 를 거부한다"
fi

# ── Codex 기록을 심고 두 도구를 합쳐 본다
CX="$TMP/codex/sessions/2026/07/01"
mkdir -p "$CX"
CXLOG="$CX/rollout-2026-07-01T10-30-00-019fb5cf-abcd.jsonl"
{
  printf '{"timestamp":"2026-07-01T01:30:00.000Z","type":"session_meta","payload":{"id":"cx1","cwd":"/tmp/fake-codex"}}\n'
  printf '{"timestamp":"2026-07-01T01:31:00.000Z","type":"event_msg","payload":{"type":"user_message","message":"코덱스한테 시킴"}}\n'
  printf '{"timestamp":"2026-07-01T01:32:00.000Z","type":"event_msg","payload":{"type":"user_message","message":"ㅇㅋ 진행해줘"}}\n'
  printf '{"timestamp":"2026-07-01T01:33:00.000Z","type":"event_msg","payload":{"type":"agent_message","message":"AGENT-REPLY-SHOULD-NOT-COUNT"}}\n'
} > "$CXLOG"

bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/codex" --hermes-root "$TMP/no-hermes" \
  --out "$TMP/out.md" >/dev/null

echo
echo "두 도구를 합쳤을 때"
check "두 소스를 합쳐 7건"              "지시 7건 (Claude Code 5 · Codex 2 · Hermes 0)"
check "도구별 절에 Claude Code 가 있다" "- Claude Code: 지시 5건"
check "도구별 절에 Codex 가 있다"       "- Codex: 지시 2건"
check "Codex 의 cwd 를 저장소로 읽는다" "fake-codex"
check "Codex 어록도 자모로 잡힌다"      "ㅇㅋ 1회"
absent "에이전트 답변은 세지 않는다"    "AGENT-REPLY-SHOULD-NOT-COUNT"

bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/codex" --hermes-root "$TMP/no-hermes" \
  --source codex --out "$TMP/out.md" >/dev/null
check "--source codex 는 Codex 만 센다" "지시 2건 (Claude Code 0 · Codex 2 · Hermes 0)"

if bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/no-codex" --hermes-root "$TMP/no-hermes" \
     --today --days 7 >/dev/null 2>&1; then
  echo "  FAIL --today 와 --days 를 같이 받았다"; FAIL=1
else
  echo "  ok   --today 와 --days 를 같이 쓰면 거부한다"
fi

# ── Hermes 는 SQLite 하나에 넣는다. 스킬 주입과 에이전트 답변이 빠지는지 본다.
if command -v sqlite3 >/dev/null 2>&1; then
  HM="$TMP/hermes"; mkdir -p "$HM"
  sqlite3 "$HM/state.db" "
    create table messages (session_id TEXT, role TEXT, content TEXT, timestamp REAL);
    insert into messages values ('h1','user','헤르메스한테 물어봄 ㅇㅋ',1782000000);
    insert into messages values ('h1','user','[IMPORTANT: SKILL-INJECTION-SHOULD-NOT-COUNT]',1782000060);
    insert into messages values ('h1','assistant','HERMES-AGENT-SHOULD-NOT-COUNT',1782000120);" 2>/dev/null

  bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/codex" --hermes-root "$HM" \
    --out "$TMP/out.md" >/dev/null

  echo
  echo "Hermes 를 더했을 때"
  check "세 도구를 합쳐 8건"              "지시 8건 (Claude Code 5 · Codex 2 · Hermes 1)"
  check "도구별 절에 Hermes 가 있다"      "- Hermes: 지시 1건"
  check "경로 없는 기록을 따로 밝힌다"    "경로를 남기지 않는 도구의 지시 1건"
  absent "스킬 주입은 세지 않는다"        "SKILL-INJECTION-SHOULD-NOT-COUNT"
  absent "에이전트 답변은 세지 않는다"    "HERMES-AGENT-SHOULD-NOT-COUNT"
else
  echo "  건너뜀 sqlite3 이 없어 Hermes 구간을 확인하지 못했다"
fi

# ── 상한
bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/codex" --hermes-root "$TMP/no-hermes" \
  --max 3 --out "$TMP/out.md" >/dev/null
echo
echo "상한을 걸었을 때"
check "최근 3건만 남는다"        "지시 3건"
check "몇 건을 뺐는지 밝힌다"    "오래된 4건을 뺐다"

if bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/no-codex" \
     --hermes-root "$TMP/no-hermes" --max 0 >/dev/null 2>&1; then
  echo "  FAIL --max 0 을 받았다"; FAIL=1
else
  echo "  ok   --max 0 을 거부한다"
fi

# ── 코칭이 카드에 붙는가
if command -v python3 >/dev/null 2>&1; then
  bash "$HERE/analyze.sh" --root "$TMP/projects" --codex-root "$TMP/codex" \
    --hermes-root "$TMP/no-hermes" --out "$TMP/out.md" >/dev/null
  bash "$HERE/render.sh" "$TMP/out.md" --out "$TMP/card.html" >/dev/null 2>&1
  echo
  echo "카드를 만들었을 때"
  if grep -q '앞으로는 이렇게 말해보세요' "$TMP/card.html" 2>/dev/null; then
    echo "  ok   코칭 블록이 붙는다"
  else
    echo "  FAIL 코칭 블록이 없다"; FAIL=1
  fi
  # 카드 HTML 은 한 줄이라 grep -c 로는 못 센다. 줄을 쪼갠 뒤 센다.
  n=$(tr '<' '\n' < "$TMP/card.html" 2>/dev/null | grep -c 'class="tag"' || true)
  if [ "$n" -eq 2 ]; then
    echo "  ok   코칭은 축 두 개만 나온다"
  else
    echo "  FAIL 코칭 축이 ${n}개다 (2개여야 한다)"; FAIL=1
  fi
fi

if [ "$FAIL" -eq 0 ]; then echo "전부 통과"; else echo "실패 있음"; fi
exit "$FAIL"
