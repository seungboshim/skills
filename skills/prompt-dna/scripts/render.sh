#!/usr/bin/env bash
# prompt-dna/render.sh — analyze.sh 가 낸 지표를 결과지 카드 한 장으로 만든다.
#
#   ./render.sh /tmp/dna.md                      # HTML 만 만든다
#   ./render.sh /tmp/dna.md --png                # PNG 까지 찍는다 (헤드리스 크롬 필요)
#   ./render.sh /tmp/dna.md --out ~/card.html
#
# 숫자를 새로 계산하지 않는다. 지표 파일에 있는 값만 옮긴다.

set -uo pipefail

IN="${1:-}"
OUT=""
PNG=0
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --out) OUT="${2:-}"; shift 2 ;;
    --png) PNG=1; shift ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "모르는 옵션: $1" >&2; exit 2 ;;
  esac
done

[ -n "$IN" ] && [ -f "$IN" ] || { echo "지표 파일을 주세요: ./render.sh <지표.md>" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "python3 가 필요하다" >&2; exit 1; }
[ -n "$OUT" ] || OUT="${IN%.md}.html"

python3 - "$IN" "$OUT" <<'PY'
import re, sys, html
src, dst = sys.argv[1], sys.argv[2]
t = open(src, encoding="utf-8").read()

def one(pat, default=""):
    m = re.search(pat, t, re.M)
    return m.group(1).strip() if m else default

code   = one(r'\*\*유형 코드: ([A-Z]{4})\*\*', "----")
window = one(r'^- 구간: (.+)$')
sample = one(r'^- 지시 (.+)$')
warn   = one(r'^- (표본 주의: .+)$')

axes = re.findall(r'^- (말수|시간|태도|범위): (.+?) → ([A-Z]) \((.+?)\)$', t, re.M)
tools = re.findall(r'^- (Claude Code|Codex|Hermes): 지시 (\d+)건 · 중앙값 (\d+)자 · '
                   r'물음표 (\d+)% · 확인 요청 (\d+)% · 새벽 (\d+)%$', t, re.M)

def block(head, pat, n):
    seg = re.search(head + r'(.*?)(?=\n## |\Z)', t, re.S)
    return re.findall(pat, seg.group(1), re.M)[:n] if seg else []

habits = block(r'## 말버릇', r'^- (\S+) (\d+)회$', 5)
jamo   = block(r'## 자모 표현', r'^- (\S+) (\d+)회$', 5)
att    = dict((k, v) for k, v in re.findall(r'^- (.+?): (\d+)%', t, re.M))

praise = att.get('칭찬·수락 표현', '0')
scold  = att.get('질책·되돌리기 표현', '0')

NAMES = {
 "SDTF":"저격수","SDTW":"배달 기사","SDVF":"감독관","SDVW":"순회 감사관",
 "SNTF":"심야 저격수","SNTW":"심야 배달","SNVF":"불면의 감독관","SNVW":"야간 순찰대",
 "LDTF":"설계자","LDTW":"총괄 기획자","LDVF":"공동 저자","LDVW":"편집장",
 "LNTF":"새벽의 건축가","LNTW":"새벽의 총괄","LNVF":"새벽의 공동 저자","LNVW":"새벽의 편집장",
}
name = NAMES.get(code, "미분류")
e = html.escape

def bar(pct, cls="mz"):
    return f'<span class="bar"><i class="{cls}" style="width:{min(int(pct),100)}%"></i></span>'

axis_rows = "".join(
    f'<tr><th>{e(k)}</th><td class="v">{e(v)}</td>'
    f'<td class="code">{e(c)}</td><td class="lab">{e(l)}</td></tr>'
    for k, v, c, l in axes)

tool_rows = "".join(
    f'<tr><th>{e(n)}</th><td class="n">{e(cnt)}건</td><td class="n">{e(med)}자</td>'
    f'<td>{bar(q)}<em>{q}%</em></td><td>{bar(chk,"cy")}<em>{chk}%</em></td>'
    f'<td class="n">{nt}%</td></tr>'
    for n, cnt, med, q, chk, nt in tools)

chips = lambda xs: "".join(f'<span class="chip">{e(w)}<i>{c}</i></span>' for w, c in xs)

open(dst, "w", encoding="utf-8").write(f"""<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<title>프롬프트 DNA — {e(code)}</title>
<style>
:root{{--bg:#0f172a;--fg:#f8fafc;--dim:#94a3b8;--line:#33435e;--mz:#f0abfc;--cy:#67e8f9;--rd:#ff7b8a;--gr:#6ee7a5}}
*{{box-sizing:border-box}}
body{{margin:0;width:960px;background:var(--bg);color:var(--fg);
font-family:"SF Pro Display",Pretendard,"Apple SD Gothic Neo",Inter,sans-serif;padding:44px 48px}}
h1{{margin:0;font-size:64px;letter-spacing:.06em}}
h1 small{{display:block;font-size:22px;color:var(--mz);letter-spacing:0;margin-top:6px;font-weight:600}}
.meta{{color:var(--dim);font-size:13px;margin-top:14px;line-height:1.7}}
.warn{{color:var(--rd);font-size:13px;margin-top:6px}}
h2{{font-size:13px;color:var(--dim);letter-spacing:.14em;margin:30px 0 10px;font-weight:600}}
table{{width:100%;border-collapse:collapse;font-size:14px}}
th{{text-align:left;font-weight:600;color:var(--dim);padding:7px 0;width:96px}}
td{{padding:7px 0}}
td.v{{color:var(--fg)}} td.n{{color:var(--dim);width:74px}}
td.code{{color:var(--mz);font-weight:700;width:26px}}
td.lab{{color:var(--dim);width:78px}}
.bar{{display:inline-block;width:120px;height:7px;background:#1e293b;border-radius:4px;
overflow:hidden;vertical-align:middle;margin-right:9px}}
.bar i{{display:block;height:100%}} .bar .mz{{background:var(--mz)}} .bar .cy{{background:var(--cy)}}
em{{font-style:normal;color:var(--dim);font-size:12px}}
.chip{{display:inline-block;border:1px solid var(--line);border-radius:999px;
padding:5px 12px;margin:0 7px 7px 0;font-size:13px}}
.chip i{{font-style:normal;color:var(--mz);margin-left:7px;font-size:12px}}
.split{{display:flex;gap:36px}} .split>div{{flex:1}}
.tone{{display:flex;gap:10px;align-items:center;font-size:14px;margin-top:4px}}
.tone b{{color:var(--rd)}} .tone u{{color:var(--gr);text-decoration:none}}
footer{{margin-top:32px;border-top:1px solid var(--line);padding-top:12px;
color:var(--dim);font-size:12px;display:flex;justify-content:space-between}}
</style></head><body>
<h1>{e(code)}<small>{e(name)}</small></h1>
<div class="meta">{e(window)}<br>지시 {e(sample)}</div>
{f'<div class="warn">{e(warn)}</div>' if warn else ''}

<h2>네 축</h2>
<table>{axis_rows}</table>

{f'<h2>도구별 · 같은 사람이 도구마다 다르게 말한다</h2><table><tr><th></th><td class="n">지시</td><td class="n">중앙값</td><td>물음표</td><td>확인 요청</td><td class="n">새벽</td></tr>{tool_rows}</table>' if len(tools) > 1 else ''}

<div class="split">
  <div><h2>말버릇</h2>{chips(habits)}</div>
  <div><h2>자모</h2>{chips(jamo)}
  <h2 style="margin-top:22px">말의 온도</h2>
  <div class="tone"><b>질책 {e(scold)}%</b><span style="color:var(--dim)">vs</span><u>칭찬 {e(praise)}%</u></div></div>
</div>

<footer><span>prompt-dna</span><span>원문 지시는 이 카드에 없다</span></footer>
</body></html>""")
print(dst)
PY

if [ "$PNG" -eq 1 ]; then
  CHROME=""
  for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
           "/Applications/Chromium.app/Contents/MacOS/Chromium" \
           chromium chromium-browser google-chrome google-chrome-stable; do
    command -v "$c" >/dev/null 2>&1 && { CHROME="$c"; break; }
    [ -x "$c" ] && { CHROME="$c"; break; }
  done
  if [ -z "$CHROME" ]; then
    echo "크롬을 못 찾아 PNG 는 건너뛴다. HTML 은 만들었다." >&2
  else
    PNGOUT="${OUT%.html}.png"
    "$CHROME" --headless --disable-gpu --hide-scrollbars \
      --force-device-scale-factor=2 --window-size=960,790 \
      --screenshot="$PNGOUT" "file://$OUT" >/dev/null 2>&1
    [ -f "$PNGOUT" ] && echo "$PNGOUT" || echo "PNG 렌더에 실패했다" >&2
  fi
fi
