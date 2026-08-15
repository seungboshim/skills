#!/usr/bin/env bash
# truman/collect.sh — 하루치 개발 흔적을 에피소드 대본용 자료로 모은다.
#
# 내레이션은 모델이 쓴다. 이 스크립트는 사실만 모은다.
# 네트워크를 쓰지 않고 아무것도 고치지 않는다. 읽기 전용.
#
#   ./collect.sh                       # 이번 방송일 (직전 새벽 5시부터 지금까지)
#   ./collect.sh --hours 6             # 최근 6시간
#   ./collect.sh --day 2026-08-14      # 특정 방송일 (그날 05:00 ~ 다음날 05:00)
#   ./collect.sh --root ~/work         # 저장소를 찾을 경로 (기본 ~/Projects)
#   ./collect.sh --no-claude           # Claude 세션 기록 제외
#   ./collect.sh --out /tmp/today.md   # 파일로 저장하고 경로만 출력
#
# 방송일은 새벽 5시에 끊는다. 새벽 3시 작업은 전날 에피소드에 들어간다.

set -uo pipefail

ROOT="${HOME}/Projects"
HOURS=""
DAY=""
INCLUDE_CLAUDE=1
OUT=""
CUTOFF_HOUR=5

while [ $# -gt 0 ]; do
  case "$1" in
    --hours) HOURS="${2:-}"; shift 2 ;;
    --day) DAY="${2:-}"; shift 2 ;;
    --root) ROOT="${2:-}"; shift 2 ;;
    --no-claude) INCLUDE_CLAUDE=0; shift ;;
    --out) OUT="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
    *) echo "모르는 옵션: $1" >&2; exit 2 ;;
  esac
done

# epoch → 표시용 문자열. BSD 는 -r, GNU 는 -d @
fmt_epoch() {
  date -r "$1" +"${2:-%H:%M}" 2>/dev/null || date -d "@$1" +"${2:-%H:%M}"
}
# YYYY-MM-DD → 그날 05:00 의 epoch
day_to_epoch() {
  date -j -f '%Y-%m-%d %H:%M:%S' "$1 0${CUTOFF_HOUR}:00:00" +%s 2>/dev/null \
    || date -d "$1 0${CUTOFF_HOUR}:00:00" +%s
}

NOW=$(date +%s)
if [ -n "$HOURS" ]; then
  SINCE_EPOCH=$(( NOW - HOURS * 3600 ))
  UNTIL_EPOCH=$NOW
  WINDOW="최근 ${HOURS}시간"
elif [ -n "$DAY" ]; then
  SINCE_EPOCH=$(day_to_epoch "$DAY")
  UNTIL_EPOCH=$(( SINCE_EPOCH + 86400 ))
  WINDOW="방송일 ${DAY}"
else
  SINCE_EPOCH=$(day_to_epoch "$(date +%Y-%m-%d)")
  # 아직 새벽 5시 전이면 어제 방송일이 이어지는 중이다.
  [ "$NOW" -lt "$SINCE_EPOCH" ] && SINCE_EPOCH=$(( SINCE_EPOCH - 86400 ))
  UNTIL_EPOCH=$NOW
  WINDOW="방송일 $(fmt_epoch "$SINCE_EPOCH" '%Y-%m-%d')"
fi
SINCE_ISO=$(fmt_epoch "$SINCE_EPOCH" '%Y-%m-%dT%H:%M:%S')

# ── Claude 세션 자료를 먼저 뽑는다. 타임라인·어록·활동 저장소의 원천이다.
SESS=$(mktemp -t truman)
trap 'rm -f "$SESS"' EXIT
CLAUDE_STATUS="제외했다 (--no-claude)"
PROJ="$HOME/.claude/projects"

if [ "$INCLUDE_CLAUDE" -eq 1 ]; then
  if ! command -v jq >/dev/null 2>&1; then
    CLAUDE_STATUS="jq 가 없어서 건너뛴다. \`brew install jq\` 하면 이 구간이 살아난다."
  elif [ ! -d "$PROJ" ]; then
    CLAUDE_STATUS="세션 기록 디렉터리가 없다."
  else
    # 사람이 직접 타이핑한 발언만 골라낸다. 도구 결과와 훅 주입은 빼야 어록이 산다.
    extract_sess() { # $1 = 사람 발언을 가리는 jq 조건
      find "$PROJ" -name '*.jsonl' -newermt "$SINCE_ISO" -exec cat {} + 2>/dev/null \
        | jq -rR --argjson since "$SINCE_EPOCH" --argjson until "$UNTIL_EPOCH" "
            fromjson?
            | select(.type==\"user\")
            | select(.message.content | type==\"string\")
            | select($1)
            | (.timestamp | sub(\"\\\\.[0-9]+Z\$\";\"Z\") | fromdateiso8601) as \$t
            | select(\$t >= \$since and \$t <= \$until)
            | [\$t, (\$t|strflocaltime(\"%H:%M\")), (.cwd // \"?\"), .message.content]
            | @tsv" 2>/dev/null \
        | sort -n -k1,1 > "$SESS"
      grep -c . "$SESS" 2>/dev/null || true
    }
    n=$(extract_sess '.promptSource=="typed"')
    CLAUDE_STATUS="발언 ${n}건"
    if [ "${n:-0}" -eq 0 ]; then
      # 이 필드가 없는 버전의 기록이면 사람 발언을 다른 근거로 가린다.
      n=$(extract_sess '(.origin.kind=="human") or (.promptSource==null and (.message.content|startswith("<")|not) and (.isSidechain|not))')
      CLAUDE_STATUS="발언 ${n}건 (typed 표시가 없어 완화된 기준으로 골랐다. 도구 출력이 섞일 수 있다)"
    fi
  fi
fi

# ── 저장소 목록. 세션이 머문 곳을 먼저 쓰고, 없으면 경로를 훑는다.
active_repos() {
  cut -f3 "$SESS" 2>/dev/null | sort -u | while read -r d; do
    [ -d "$d" ] && git -C "$d" rev-parse --show-toplevel 2>/dev/null
  done
  git rev-parse --show-toplevel 2>/dev/null
}
all_repos() {
  {
    active_repos
    if [ -d "$ROOT" ]; then
      find "$ROOT" -maxdepth 4 -name .git -type d \
        -not -path "*/node_modules/*" -not -path "*/.venv/*" 2>/dev/null \
        | sed 's|/\.git$||'
    fi
  } | sort -u
}

ACTIVE=$(active_repos | sort -u)
REPOS=$(all_repos)

# 그 저장소에서 내가 이 구간에 만든 커밋 (author 필터. 정규식이라 . 은 전부 통과)
my_log() {
  local repo="$1"; shift
  local me
  me=$(git -C "$repo" config user.email 2>/dev/null || true)
  [ -z "$me" ] && me="."
  git -C "$repo" log --since="$SINCE_ISO" --until="$(fmt_epoch "$UNTIL_EPOCH" '%Y-%m-%dT%H:%M:%S')" \
    --author="$me" "$@" 2>/dev/null
}

emit() {

echo "# 촬영 자료"
echo
echo "- 구간: ${WINDOW} — $(fmt_epoch "$SINCE_EPOCH" '%m/%d %H:%M') ~ $(fmt_epoch "$UNTIL_EPOCH" '%m/%d %H:%M')"
echo "- 활동 저장소: $(printf '%s\n' "$ACTIVE" | grep -c . || true)개 / 탐색 대상 $(printf '%s\n' "$REPOS" | grep -c . || true)개"
echo "- 세션 기록: ${CLAUDE_STATUS}"

# ── 1. 하루의 흐름 ────────────────────────────────────────
echo
echo "## 하루의 흐름"
echo
if [ -s "$SESS" ]; then
  echo "시간대별 발언 수:"
  echo
  cut -f2 "$SESS" | cut -d: -f1 | sort | uniq -c \
    | awk -v cut="$CUTOFF_HOUR" '{ printf "%02d\t%s\t%s\n", ($2+24-cut)%24, $2, $1 }' \
    | sort -n | cut -f2- \
    | while read -r h c; do
        w=$(( c > 24 ? 24 : c ))
        bar=$(printf '%*s' "$w" '' | tr ' ' '#')
        echo "- ${h}시 ${bar} ${c}"
      done
  echo
  echo "장면 (한자리에 머문 구간):"
  echo
  awk -F'\t' '
    function label(path,  n, p, base) {
      n = split(path, p, "/"); base = p[n]
      if (base ~ /^(app|apps|web|src|ios|android|packages|server|client|frontend|backend|api|lib)$/ && n > 1)
        return p[n-1] "/" base
      return base
    }
    { cur = label($3)
      if (cur != scene) {
        if (scene != "" && (cnt >= 2 || last - start >= 180))
          printf "- %s ~ %s  %s (발언 %d건)\n", st, lt, scene, cnt
        scene = cur; start = $1; st = $2; cnt = 0
      }
      cnt++; last = $1; lt = $2 }
    END { if (scene != "") printf "- %s ~ %s  %s (발언 %d건)\n", st, lt, scene, cnt }' "$SESS"
  echo
  echo "머문 시간 비중:"
  echo
  awk -F'\t' '
    function label(path,  n, p, base) {
      n = split(path, p, "/"); base = p[n]
      if (base ~ /^(app|apps|web|src|ios|android|packages|server|client|frontend|backend|api|lib)$/ && n > 1)
        return p[n-1] "/" base
      return base
    }
    { print label($3) }' "$SESS" | sort | uniq -c | sort -rn | head -6 \
    | while read -r c p; do echo "- ${p}: 발언 ${c}건"; done
  echo
  awk -F'\t' '
    NR==1 { firstt=$2 }
    { if (prev && $1-prev > gap) { gap=$1-prev; gt=prevt; ga=$2 } prev=$1; prevt=$2 }
    END {
      printf "- 첫 발언 %s, 마지막 발언 %s\n", firstt, prevt
      if (gap > 1800) printf "- 가장 긴 침묵: %s ~ %s (%d분)\n", gt, ga, gap/60
    }' "$SESS"
else
  echo "(세션 발언 자료가 없다. 커밋 시각과 터미널 기록으로 흐름을 잡아야 한다.)"
fi

# ── 2. 커밋 ──────────────────────────────────────────────
echo
echo "## 커밋"
echo
COMMITS=0
for repo in $REPOS; do
  [ -d "$repo/.git" ] || continue
  log=$(my_log "$repo" --date=format:'%m/%d %H:%M' --pretty=format:'%ad|%s')
  [ -z "$log" ] && continue
  n=$(printf '%s\n' "$log" | grep -c . || true)
  COMMITS=$(( COMMITS + n ))
  echo "### $(basename "$repo") (${n}건)"
  printf '%s\n' "$log" | while IFS='|' read -r t subject; do
    echo "- ${t} — ${subject}"
  done
  echo
done
[ "$COMMITS" -eq 0 ] && echo "(구간 안에 커밋이 없다. 커밋 없이 흐른 하루도 서사가 된다.)"

# ── 3. 같은 파일을 몇 번이나 다시 만졌나 ───────────────────
echo
echo "## 반복 수정 파일"
echo
echo "커밋 하나에 한 번씩 센다. 숫자가 크면 그 파일에서 헤맸다는 뜻이다."
echo
touched=$(for repo in $REPOS; do
  [ -d "$repo/.git" ] || continue
  my_log "$repo" --name-only --pretty=format: | grep -v '^$' \
    | sed "s|^|$(basename "$repo")/|"
done | sort | uniq -c | sort -rn | head -8)
if [ -n "$touched" ]; then
  printf '%s\n' "$touched" | while read -r c f; do echo "- ${c}회 — ${f}"; done
else
  echo "(없음)"
fi

# ── 4. reflog 에 남은 극적인 순간 ──────────────────────────
echo
echo "## 극적인 순간"
echo
echo "되돌리고 다시 시작한 흔적이다. 에피소드의 갈등 구간으로 쓴다."
echo
DRAMA=0
for repo in $REPOS; do
  [ -d "$repo/.git" ] || continue
  d=$(git -C "$repo" reflog --date=format:'%s' --pretty=format:'%ad|%gs' 2>/dev/null \
      | awk -F'|' -v s="$SINCE_EPOCH" -v u="$UNTIL_EPOCH" '$1 >= s && $1 <= u' \
      | grep -Ei 'reset|rebase|revert|amend|merge|stash|cherry-pick|checkout: moving' \
      | head -6)
  [ -z "$d" ] && continue
  DRAMA=1
  echo "### $(basename "$repo")"
  printf '%s\n' "$d" | while IFS='|' read -r ts what; do
    echo "- $(fmt_epoch "$ts") — ${what}"
  done
  echo
done
[ "$DRAMA" -eq 0 ] && echo "(평온한 하루였다.)"

# ── 5. 어록 ──────────────────────────────────────────────
echo
echo "## 어록"
echo
if [ -s "$SESS" ]; then
  echo "직접 타이핑한 발언 중 짧은 것만 골랐다. 감정이 묻은 쪽이 자막감이다."
  echo
  awk -F'\t' 'length($4) > 1 && length($4) <= 55 && $4 !~ /^\// && $4 != prev { print "- " $2 " [" $4 "]"; prev=$4 }' "$SESS" | head -30
else
  echo "(자료 없음)"
fi

# ── 6. 터미널 ────────────────────────────────────────────
echo
echo "## 터미널"
echo
HIST="${HISTFILE:-$HOME/.zsh_history}"
[ -f "$HIST" ] || HIST="$HOME/.bash_history"
if [ ! -f "$HIST" ]; then
  echo "(히스토리 파일을 찾지 못했다: ${HIST})"
else
  # zsh 확장 형식: `: <epoch>:<duration>;<command>`
  cmds=$(LC_ALL=C sed -n 's/^: \([0-9]*\):[0-9]*;\(.*\)$/\1|\2/p' "$HIST" 2>/dev/null \
         | awk -F'|' -v s="$SINCE_EPOCH" -v u="$UNTIL_EPOCH" '$1 >= s && $1 <= u')
  if [ -z "$cmds" ]; then
    last=$(LC_ALL=C sed -n 's/^: \([0-9]*\):[0-9]*;.*$/\1/p' "$HIST" 2>/dev/null | tail -1)
    if [ -n "$last" ]; then
      echo "히스토리에 이 구간 기록이 없다. 마지막 기록은 $(fmt_epoch "$last" '%Y-%m-%d %H:%M') 이다."
      echo "(터미널을 IDE 안에서 쓰면 이 파일에 안 쌓인다. 세션 기록으로 대체한다.)"
    else
      echo "히스토리에 타임스탬프가 없다. \`setopt EXTENDED_HISTORY\` 를 켜면 다음부터 이 구간이 살아난다."
    fi
  else
    echo "구간 내 명령 $(printf '%s\n' "$cmds" | grep -c . || true)개."
    echo
    echo "많이 쓴 명령:"
    printf '%s\n' "$cmds" | cut -d'|' -f2- | awk '{print $1, $2}' \
      | sort | uniq -c | sort -rn | head -6 \
      | while read -r c cmd; do echo "- ${c}회 — ${cmd}"; done
    echo
    echo "연달아 반복한 명령 (재시도 흔적):"
    retry=$(printf '%s\n' "$cmds" | cut -d'|' -f2- | uniq -c | awk '$1 >= 3' | sort -rn | head -5)
    if [ -n "$retry" ]; then
      printf '%s\n' "$retry" | while read -r c cmd; do echo "- ${c}번 연속 — ${cmd}"; done
    else
      echo "- (없음)"
    fi
  fi
fi

# ── 7. 아직 안 끝난 것 = 차회 예고 ────────────────────────
echo
echo "## 미완성"
echo
echo "차회 예고에 쓴다. 오늘 만진 저장소만 본다. 오래 방치된 것일수록 좋은 떡밥이다."
echo
LEFT=0
for repo in $ACTIVE; do
  [ -d "$repo/.git" ] || continue
  dirty=$(git -C "$repo" status --porcelain 2>/dev/null | grep -c . || true)
  ahead=$(git -C "$repo" log '@{u}..' --oneline 2>/dev/null | grep -c . || true)
  stash=$(git -C "$repo" stash list 2>/dev/null | grep -c . || true)
  branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  [ "$dirty" -eq 0 ] && [ "$ahead" -eq 0 ] && [ "$stash" -eq 0 ] && continue
  LEFT=1
  line="- $(basename "$repo") [${branch}]:"
  [ "$dirty" -gt 0 ] && line="${line} 커밋 안 한 변경 ${dirty}개"
  [ "$ahead" -gt 0 ] && line="${line} · push 안 한 커밋 ${ahead}개"
  [ "$stash" -gt 0 ] && line="${line} · stash ${stash}개"
  echo "$line"
  [ "$stash" -gt 0 ] && git -C "$repo" stash list --date=format:'%m/%d' \
    --pretty=format:'    · %gs (%ad)' 2>/dev/null | head -2 && echo
done
[ "$LEFT" -eq 0 ] && echo "(깔끔하게 마감했다.)"

echo
echo "---"
echo "자료 끝. 여기 없는 사실은 에피소드에 쓰지 않는다."

}

if [ -n "$OUT" ]; then
  emit > "$OUT"
  echo "$OUT"
else
  emit
fi
