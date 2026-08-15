#!/usr/bin/env bash
# prompt-dna/analyze.sh — 내가 에이전트에게 해온 말을 전부 세어 지표로 만든다.
#
# 숫자와 유형 코드는 스크립트가 확정하고, 모델은 해석만 한다. 네트워크를 쓰지 않고
# 읽기 전용이다. 원문 지시는 출력하지 않는다. 세어본 수치와 짧은 말버릇만 낸다.
#
#   ./analyze.sh                     # 전체 이력, 찾을 수 있는 도구 전부
#   ./analyze.sh --days 7            # 최근 7일
#   ./analyze.sh --today             # 오늘만 (새벽 5시에 하루를 끊는다)
#   ./analyze.sh --source claude     # 한 도구만 (all | claude | codex)
#   ./analyze.sh --out /tmp/dna.md   # 파일로 저장하고 경로만 출력
#
# 읽는 곳: ~/.claude/projects (Claude Code), ~/.codex/sessions (Codex CLI)

set -uo pipefail
export LC_ALL="${LC_ALL:-ko_KR.UTF-8}"

DAYS=""
TODAY=0
OUT=""
SOURCE="all"
PROJ="$HOME/.claude/projects"
CODEX="$HOME/.codex"

while [ $# -gt 0 ]; do
  case "$1" in
    --days) DAYS="${2:-}"; shift 2 ;;
    --today) TODAY=1; shift ;;
    --out) OUT="${2:-}"; shift 2 ;;
    --root) PROJ="${2:-}"; shift 2 ;;
    --codex-root) CODEX="${2:-}"; shift 2 ;;
    --source) SOURCE="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "모르는 옵션: $1" >&2; exit 2 ;;
  esac
done

case "$SOURCE" in
  all|claude|codex) ;;
  *) echo "--source 는 all, claude, codex 중 하나여야 한다: $SOURCE" >&2; exit 2 ;;
esac

if [ -n "$DAYS" ] && ! [[ "$DAYS" =~ ^[1-9][0-9]*$ ]]; then
  echo "--days 는 1 이상의 정수여야 한다: $DAYS" >&2
  exit 2
fi
if [ -n "$DAYS" ] && [ "$TODAY" -eq 1 ]; then
  echo "--days 와 --today 는 같이 못 쓴다" >&2
  exit 2
fi

command -v jq >/dev/null 2>&1 || { echo "jq 가 필요하다: brew install jq" >&2; exit 1; }

HAS_CLAUDE=0; HAS_CODEX=0
[ "$SOURCE" != "codex" ] && [ -d "$PROJ" ] && HAS_CLAUDE=1
[ "$SOURCE" != "claude" ] && [ -d "$CODEX/sessions" ] && HAS_CODEX=1
if [ "$HAS_CLAUDE" -eq 0 ] && [ "$HAS_CODEX" -eq 0 ]; then
  echo "읽을 세션 기록이 없다. Claude Code: $PROJ / Codex: $CODEX/sessions" >&2
  exit 1
fi

NOW=$(date +%s)
SINCE=0
WINDOW="전체 이력"
if [ -n "$DAYS" ]; then
  SINCE=$(( NOW - DAYS * 86400 ))
  WINDOW="최근 ${DAYS}일"
elif [ "$TODAY" -eq 1 ]; then
  # 하루는 새벽 5시에 끊는다. 새벽 3시 작업은 어제 것으로 본다 (truman 과 같은 규칙).
  SINCE=$(date -j -f '%Y-%m-%d %H:%M:%S' "$(date +%Y-%m-%d) 05:00:00" +%s 2>/dev/null \
          || date -d "$(date +%Y-%m-%d) 05:00:00" +%s)
  [ "$NOW" -lt "$SINCE" ] && SINCE=$(( SINCE - 86400 ))
  WINDOW="오늘 (새벽 5시 기준)"
fi

# 로컬 시간대 보정값. 연속 작업일을 세는 데 쓴다.
TZOFF=$(date +%z | awk '{ s=substr($0,1,1); h=substr($0,2,2)+0; m=substr($0,4,2)+0;
                          v=h*3600+m*60; print (s=="-" ? -v : v) }')

TSV=$(mktemp -t promptdna)
trap 'rm -f "$TSV" "$TSV.w" "$TSV.h" "$TSV.claude" "$TSV.codex"' EXIT

JQ_PROG='
  fromjson?
  | select(.type=="user")
  | select(.message.content | type=="string")
  | select(SELECTOR)
  | (.timestamp | sub("\\.[0-9]+Z$";"Z") | fromdateiso8601) as $t
  | select($t >= $since)
  | [ $t,
      ($t|strflocaltime("%H")),
      ($t|strflocaltime("%Y-%m-%d")),
      ((.cwd // "?") | split("/") | (if (.[-1] | test("^(app|apps|web|src|ios|android|packages|server|client|frontend|backend|api|lib)$")) and (length > 1) then .[-2:] | join("/") else .[-1] end)),
      (.sessionId // "?"),
      (.message.content | length),
      .message.content,
      "claude" ]
  | @tsv'

extract() { # $1 = jq select 조건, $2 = grep 사전 필터 (없으면 빈 문자열)
  local sel="$1" pre="${2:-}"
  if [ -n "$pre" ]; then
    find "$PROJ" -name '*.jsonl' -exec grep -h "$pre" {} + 2>/dev/null
  else
    find "$PROJ" -name '*.jsonl' -exec cat {} + 2>/dev/null
  fi | jq -rR --argjson since "$SINCE" "${JQ_PROG/SELECTOR/$sel}" 2>/dev/null \
     | sort -n -k1,1 > "$TSV.claude"
  grep -c . "$TSV.claude" 2>/dev/null || true
}

# Codex CLI 기록. cwd 는 session_meta 에, 사람이 친 말은 event_msg/user_message 에 있다.
# 파일 하나에 흩어져 있어서 grep 으로 두 줄만 뽑아 파일명으로 이어 붙인다.
extract_codex() {
  [ "$HAS_CODEX" -eq 1 ] || { : > "$TSV.codex"; echo 0; return; }
  find "$CODEX/sessions" -name '*.jsonl' -type f -print0 2>/dev/null \
    | xargs -0 grep -H -E '"type":"session_meta"|"type":"user_message"' 2>/dev/null \
    | awk '{ i = index($0, ":{"); if (i > 0) print substr($0, 1, i-1) "\t" substr($0, i+1) }' \
    | jq -rR --argjson since "$SINCE" '
        split("\t") as $p
        | $p[0] as $f
        | ($p[1:] | join("\t") | fromjson?) as $j
        | if $j == null then empty
          elif $j.type == "session_meta" then
            [$f, "meta", ($j.payload.cwd // "?")] | @tsv
          elif (($j.payload.type?) // "") == "user_message" then
            ($j.timestamp | sub("\\.[0-9]+Z$";"Z") | fromdateiso8601) as $t
            | select($t >= $since)
            | (($j.payload.message) // "") as $m
            | select(($m | length) > 0)
            | [$f, "msg", ($t|tostring), ($t|strflocaltime("%H")),
               ($t|strflocaltime("%Y-%m-%d")), ($m|length|tostring), $m] | @tsv
          else empty end' 2>/dev/null \
    | awk -F'\t' 'BEGIN { OFS="\t" }
        $2 == "meta" { cwd[$1] = $3; next }
        $2 == "msg" {
          p = ($1 in cwd) ? cwd[$1] : "?"
          n = split(p, a, "/"); base = a[n]
          if (base ~ /^(app|apps|web|src|ios|android|packages|server|client|frontend|backend|api|lib)$/ && n > 1)
            base = a[n-1] "/" base
          sid = $1; sub(/^.*\//, "", sid); sub(/\.jsonl$/, "", sid)
          print $3, $4, $5, base, sid, $6, $7, "codex"
        }' > "$TSV.codex"
  grep -c . "$TSV.codex" 2>/dev/null || true
}

# 빠른 길: 사람이 타이핑한 지시만 grep 으로 미리 걸러낸다 (931MB 를 5초에 훑는다)
BASIS="직접 타이핑한 지시만 골랐다"
if [ "$HAS_CLAUDE" -eq 1 ]; then
  NC=$(extract '.promptSource=="typed"' '"promptSource":"typed"')
  if [ "${NC:-0}" -eq 0 ]; then
    NC=$(extract '(.origin.kind=="human") or (.promptSource==null and (.message.content|startswith("<")|not) and (.isSidechain|not))' '')
    [ "${NC:-0}" -gt 0 ] && BASIS="typed 표시가 없어 완화된 기준으로 골랐다. 도구 출력이 섞일 수 있다"
  fi
else
  : > "$TSV.claude"; NC=0
fi

NX=$(extract_codex)

cat "$TSV.claude" "$TSV.codex" 2>/dev/null | sort -n -k1,1 > "$TSV"
N=$(grep -c . "$TSV" 2>/dev/null || true)

if [ "${N:-0}" -eq 0 ]; then
  echo "세어볼 지시가 없다. 세션 기록이 비어 있거나 형식이 다르다." >&2
  exit 1
fi

# 지시 본문만 따로 빼둔다 (말버릇 집계용). 도구 열이 8번이라 본문은 7번 하나다.
cut -f7 "$TSV" > "$TSV.w"

# 비율을 정수 퍼센트로
pct() { awk -v a="$1" -v b="$2" 'BEGIN { printf "%d", (b>0 ? a*100/b + 0.5 : 0) }'; }
# 정규식에 걸리는 지시 수. grep -c 는 못 찾아도 0 을 찍고 종료코드 1 로 끝난다.
# 그래서 뒤에 대체값을 또 찍어주면 0 이 두 줄이 되어 뒤의 awk 가 깨진다.
hits() { local n; n=$(grep -cE "$1" "$TSV.w" 2>/dev/null) || true; echo "${n:-0}"; }

SESSIONS=$(cut -f5 "$TSV" | sort -u | grep -c . || true)
DAYSACT=$(cut -f3 "$TSV" | sort -u | grep -c . || true)
FIRST=$(head -1 "$TSV" | cut -f3)
LAST=$(tail -1 "$TSV" | cut -f3)
PROJECTS=$(cut -f4 "$TSV" | sort -u | grep -c . || true)

# 2000자 넘는 것은 붙여넣은 로그다. 말의 길이가 아니라서 길이 계산에서 뺀다.
PASTE=$(awk -F'\t' '$6 > 2000' "$TSV" | grep -c . || true)
AVGLEN=$(awk -F'\t' '$6 <= 2000 { s+=$6; n++ } END { printf "%d", (n>0 ? s/n + 0.5 : 0) }' "$TSV")
MEDLEN=$(awk -F'\t' '$6 <= 2000 { print $6 }' "$TSV" | sort -n \
         | awk '{ a[NR]=$1 } END { print (NR>0 ? a[int(NR/2)+1] : 0) }')
MAXLEN=$(cut -f6 "$TSV" | sort -n | tail -1)
SHORT=$(awk -F'\t' '$6 <= 20' "$TSV" | grep -c . || true)

NIGHT=$(awk -F'\t' '$2 >= "00" && $2 <= "05"' "$TSV" | grep -c . || true)
QMARK=$(hits '\?|\？')
CHECK=$(hits '확인|맞아|맞나|맞지|왜 |왜안|왜 안|진짜\?|정말|검증|봐줘|보여줘')
PRAISE=$(hits '좋아|좋다|굿|굳|고마|감사|잘했|완벽|오케|ㅇㅋ|조아|최고')
SCOLD=$(hits '아니|다시|틀렸|왜 안|망했|제발|아직|또 |말했잖|하지 마|하지마')

TOPPROJ=$(cut -f4 "$TSV" | sort | uniq -c | sort -rn | head -1 | awk '{ print $2 }')
TOPPROJN=$(cut -f4 "$TSV" | sort | uniq -c | sort -rn | head -1 | awk '{ print $1 }')

PERSESS=$(awk -v n="$N" -v s="$SESSIONS" 'BEGIN { printf "%.1f", (s>0 ? n/s : 0) }')

# 연속 작업일 최장 구간
STREAK=$(cut -f1 "$TSV" | awk -v off="$TZOFF" '{ print int(($1+off)/86400) }' \
  | sort -un | awk 'NR==1 { run=1; best=1; prev=$1; next }
                    { run = ($1 == prev+1 ? run+1 : 1); if (run > best) best=run; prev=$1 }
                    END { print best+0 }')

emit() {

echo "# 프롬프트 지표"
echo
echo "- 구간: ${WINDOW} — 기록 ${FIRST} ~ ${LAST}"
echo "- 표본: ${BASIS}"
echo "- 지시 ${N}건 (Claude Code ${NC:-0} · Codex ${NX:-0}) · 세션 ${SESSIONS}개 · 활동한 날 ${DAYSACT}일 · 저장소 ${PROJECTS}개"
if [ "$N" -lt 100 ]; then
  echo "- 표본 주의: 지시가 100건 미만이라 유형은 임시 결과다. 기록이 더 쌓인 뒤 다시 잰다"
fi

echo
echo "## 말수"
echo
echo "- 중앙값 ${MEDLEN}자 · 평균 ${AVGLEN}자 · 최장 ${MAXLEN}자"
echo "- 20자 이하 단문: ${SHORT}건 ($(pct "$SHORT" "$N")%)"
echo "- 붙여넣기로 보이는 지시(2000자 초과) ${PASTE}건은 길이 계산에서 뺐다"
echo "- 세션당 평균 지시 ${PERSESS}건"

echo
echo "## 시간대"
echo
cut -f2 "$TSV" | sort | uniq -c | awk '{ printf "%s\t%s\n", $2, $1 }' > "$TSV.h"
HMAX=$(cut -f2 "$TSV.h" | sort -n | tail -1)
while IFS=$'\t' read -r h c; do
  w=$(awk -v c="$c" -v m="$HMAX" 'BEGIN { v=int(c*24/m+0.5); print (v<1 ? 1 : v) }')
  bar=$(printf '%*s' "$w" '' | tr ' ' '#')
  echo "- ${h}시 ${bar} ${c}"
done < "$TSV.h"
echo
echo "- 새벽(00~05시) ${NIGHT}건 ($(pct "$NIGHT" "$N")%)"
echo "- 연속으로 일한 최장 기간 ${STREAK}일"

echo
echo "## 태도"
echo
echo "- 물음표가 있는 지시: $(pct "$QMARK" "$N")% (${QMARK}건)"
echo "- 확인·검증을 요청한 지시: $(pct "$CHECK" "$N")% (${CHECK}건)"
echo "- 칭찬·수락 표현: $(pct "$PRAISE" "$N")% (${PRAISE}건)"
echo "- 질책·되돌리기 표현: $(pct "$SCOLD" "$N")% (${SCOLD}건)"

echo
echo "## 도구별"
echo
if [ "$(cut -f8 "$TSV" | sort -u | grep -c . || true)" -lt 2 ]; then
  echo "한 도구의 기록만 있다. 비교할 대상이 없다."
else
  echo "같은 사람이 도구마다 다르게 말하는지 본다."
  echo
  for tool in claude codex; do
    tn=$(awk -F'\t' -v t="$tool" '$8 == t' "$TSV" | grep -c . || true)
    [ "$tn" -eq 0 ] && continue
    tmed=$(awk -F'\t' -v t="$tool" '$8 == t && $6 <= 2000 { print $6 }' "$TSV" | sort -n \
           | awk '{ a[NR]=$1 } END { print (NR>0 ? a[int(NR/2)+1] : 0) }')
    tq=$(awk -F'\t' -v t="$tool" '$8 == t { print $7 }' "$TSV" | grep -cE '\?|？' || true)
    tchk=$(awk -F'\t' -v t="$tool" '$8 == t { print $7 }' "$TSV" \
           | grep -cE '확인|맞아|맞나|맞지|왜 |왜안|왜 안|진짜\?|정말|검증|봐줘|보여줘' || true)
    tnight=$(awk -F'\t' -v t="$tool" '$8 == t && $2 >= "00" && $2 <= "05"' "$TSV" | grep -c . || true)
    if [ "$tool" = "claude" ]; then label="Claude Code"; else label="Codex"; fi
    echo "- ${label}: 지시 ${tn}건 · 중앙값 ${tmed}자 · 물음표 $(pct "$tq" "$tn")% · 확인 요청 $(pct "$tchk" "$tn")% · 새벽 $(pct "$tnight" "$tn")%"
  done
  echo
  echo "차이가 크면 그 자체가 결과다. 도구마다 맡기는 일이 다르다는 뜻이다."
fi

echo
echo "## 활동 범위"
echo
cut -f4 "$TSV" | sort | uniq -c | sort -rn | head -8 \
  | while read -r c p; do echo "- ${p}: ${c}건 ($(pct "$c" "$N")%)"; done
echo
echo "- 최다 저장소 편중도: ${TOPPROJ} $(pct "$TOPPROJN" "$N")%"

echo
echo "## 말버릇"
echo
echo "두 글자 이상 여덟 글자 이하의 한글 낱말만 세었다. 조사와 접속어는 뺐다."
echo
# 낱말 쪼개기는 jq 의 scan 으로 한다. BSD grep 은 유니코드 범위를 콜레이션 순서로
# 읽어서 자모 범위에서 "invalid character range" 로 죽고, -o 로 한 줄의 여러 번을 다 세지도 못한다.
jq -Rr '[scan("[가-힣]{2,8}")] | .[]' "$TSV.w" 2>/dev/null \
  | grep -vE '^(에서|으로|이거|그거|저거|라고|라는|하고|에게|부터|까지|인데|는데|니까|어서|아서|지만|해서|하면|그럼|그게|이게|그건|이건|것도|것은|한테|보다|처럼|이라|여기|저기|거기)$' \
  | sort | uniq -c | sort -rn | head -15 \
  | while read -r c w; do echo "- ${w} ${c}회"; done

echo
echo "## 자모 표현"
echo
JAMO=$(jq -Rr '[scan("[ㄱ-ㅎㅏ-ㅣ]{2,6}")] | .[]' "$TSV.w" 2>/dev/null \
       | sort | uniq -c | sort -rn | head -8)
if [ -n "$JAMO" ]; then
  printf '%s\n' "$JAMO" | while read -r c w; do echo "- ${w} ${c}회"; done
else
  echo "- (없음)"
fi

echo
echo "## 축 판정"
echo
echo "임계값은 references/types.md 와 같다. 아래 계산은 스크립트가 확정한 값이다."
echo
awk -v med="$MEDLEN" -v night="$(pct "$NIGHT" "$N")" -v chk="$(pct "$CHECK" "$N")" \
    -v top="$(pct "$TOPPROJN" "$N")" 'BEGIN {
  a = (med < 60 ? "S" : "L");   printf "- 말수: 중앙값 %d자 → %s (%s)\n", med, a, (a=="S" ? "단문형" : "장문형")
  b = (night >= 15 ? "N" : "D"); printf "- 시간: 새벽 %d%% → %s (%s)\n", night, b, (b=="N" ? "야행성" : "주행성")
  c = (chk >= 25 ? "V" : "T");   printf "- 태도: 확인 요청 %d%% → %s (%s)\n", chk, c, (c=="V" ? "검증형" : "위임형")
  d = (top >= 50 ? "F" : "W");   printf "- 범위: 최다 저장소 %d%% → %s (%s)\n", top, d, (d=="F" ? "집중형" : "산개형")
  printf "\n**유형 코드: %s%s%s%s**\n", a, b, c, d
}'

echo
echo "---"
echo "지표 끝. 원문 지시는 여기 없다."

}

if [ -n "$OUT" ]; then
  emit > "$OUT"
  echo "$OUT"
else
  emit
fi
