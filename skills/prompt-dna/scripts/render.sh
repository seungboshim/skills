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

def one(pat, d=""):
    m = re.search(pat, t, re.M); return m.group(1).strip() if m else d
def num(sv, d=0):
    m = re.search(r'(\d+)', sv or ""); return int(m.group(1)) if m else d

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

habits = block(r'## 말버릇', r'^- (\S+) (\d+)회$', 6)
jamo   = block(r'## 자모 표현', r'^- (\S+) (\d+)회$', 5)
projs  = block(r'## 활동 범위', r'^- (\S+): (\d+)건', 5)
att    = dict(re.findall(r'^- (.+?): (\d+)%', t, re.M))
praise = att.get('칭찬·수락 표현', '0'); scold = att.get('질책·되돌리기 표현', '0')

NAMES = {
 "SDTF":"저격수","SDTW":"배달 기사","SDVF":"감독관","SDVW":"순회 감사관",
 "SNTF":"심야 저격수","SNTW":"심야 배달","SNVF":"불면의 감독관","SNVW":"야간 순찰대",
 "LDTF":"설계자","LDTW":"총괄 기획자","LDVF":"공동 저자","LDVW":"편집장",
 "LNTF":"새벽의 건축가","LNTW":"새벽의 총괄","LNVF":"새벽의 공동 저자","LNVW":"새벽의 편집장"}
name = NAMES.get(code, "미분류")
e = html.escape

# 성향 그래프. 축마다 왼쪽 끝과 오른쪽 끝을 두고 실제 값 위치에 표시를 찍는다.
POLES = {"말수": ("S 단문형","L 장문형",120), "시간": ("D 주행성","N 야행성",30),
         "태도": ("T 위임형","V 검증형",50), "범위": ("W 산개형","F 집중형",100)}
rows = []
for k, v, c, lab in axes:
    lo, hi, full = POLES.get(k, ("","",100))
    pos = max(4, min(96, round(num(v) / full * 100)))
    rows.append(f'''<div class="ax">
      <span class="k">{e(k)}</span>
      <span class="pole">{e(lo)}</span>
      <span class="track"><i style="left:{pos}%"></i></span>
      <span class="pole r">{e(hi)}</span>
      <span class="val">{e(v)}</span></div>''')
axis_html = "".join(rows)

tool_rows = "".join(
    f'<tr><th>{e(n)}</th><td>{e(cnt)}건</td><td>{e(med)}자</td>'
    f'<td><span class="bar"><i style="width:{min(int(q),100)}%"></i></span>{q}%</td>'
    f'<td><span class="bar"><i class="b2" style="width:{min(int(ch),100)}%"></i></span>{ch}%</td>'
    f'<td>{nt}%</td></tr>'
    for n, cnt, med, q, ch, nt in tools)

chips = lambda xs: "".join(f'<span class="chip">{e(w)}<i>{c}</i></span>' for w, c in xs)

open(dst, "w", encoding="utf-8").write(f"""<!doctype html>
<html lang="ko"><head><meta charset="utf-8"><title>프롬프트 DNA — {e(code)}</title><style>
:root{{--bg:#f4ece0;--pa:#ece0cd;--fg:#4a3728;--dim:#9b8straight;--dim:#9a8straight}}
:root{{--dim:#9a8булlace}}
</style><style>
:root{{--bg:#f4ece0;--fg:#43301f;--dim:#95795c;--line:#d8c7ac;--ac:#a2542a;--ac2:#7d6a4f}}
*{{box-sizing:border-box}}
body{{margin:0;width:960px;background:var(--bg);color:var(--fg);padding:52px 56px;
font-family:"SF Pro Display",Pretendard,"Apple SD Gothic Neo",Inter,sans-serif;position:relative}}
body::before,body::after{{content:"";position:absolute;width:34px;height:34px;border:2px solid var(--ac);opacity:.5}}
body::before{{top:18px;left:20px;border-right:0;border-bottom:0}}
body::after{{bottom:18px;right:20px;border-left:0;border-top:0}}
.hd{{display:flex;align-items:flex-end;justify-content:space-between}}
h1{{margin:0;font-size:78px;letter-spacing:.1em;line-height:1;color:var(--fg)}}
h1 small{{display:block;font-size:21px;letter-spacing:0;color:var(--ac);margin-top:10px;font-weight:600}}
.meta{{text-align:right;color:var(--dim);font-size:12.5px;line-height:1.8}}
.warn{{color:var(--ac);font-size:12.5px;margin-top:8px}}
hr{{border:0;border-top:1px solid var(--line);margin:26px 0 0;position:relative}}
hr::after{{content:"";position:absolute;right:0;top:-3px;width:5px;height:5px;
background:var(--ac);transform:rotate(45deg)}}
hr::before{{content:"";position:absolute;left:0;top:-3px;width:5px;height:5px;
background:var(--ac);transform:rotate(45deg)}}
h2{{font-size:11.5px;color:var(--dim);letter-spacing:.2em;margin:16px 0 14px;font-weight:700}}
.ax{{display:flex;align-items:center;gap:12px;margin:11px 0;font-size:13px}}
.ax .k{{width:38px;color:var(--dim);font-weight:600}}
.ax .pole{{width:76px;color:var(--ac2);font-size:12px;text-align:right}}
.ax .pole.r{{text-align:left}}
.ax .track{{flex:1;height:3px;background:var(--line);position:relative;border-radius:2px}}
.ax .track i{{position:absolute;top:-5px;width:13px;height:13px;background:var(--ac);
border-radius:50%;transform:translateX(-50%);box-shadow:0 0 0 4px var(--bg)}}
.ax .val{{width:120px;text-align:right;color:var(--fg);font-size:12.5px}}
table{{width:100%;border-collapse:collapse;font-size:13px}}
th{{text-align:left;font-weight:600;padding:6px 0;width:120px}}
td{{padding:6px 0;color:var(--ac2)}}
.bar{{display:inline-block;width:96px;height:6px;background:var(--line);border-radius:3px;
overflow:hidden;vertical-align:middle;margin-right:8px}}
.bar i{{display:block;height:100%;background:var(--ac)}} .bar .b2{{background:var(--ac2)}}
.chip{{display:inline-block;border:1px solid var(--line);border-radius:2px;background:#0000000a;
padding:5px 11px;margin:0 7px 8px 0;font-size:12.5px}}
.chip i{{font-style:normal;color:var(--ac);margin-left:8px;font-size:11.5px}}
.cols{{display:flex;gap:44px}} .cols>div{{flex:1}}
.tone{{font-size:14px;color:var(--ac2)}} .tone b{{color:var(--ac);font-size:16px}}
footer{{margin-top:14px;color:var(--dim);font-size:11.5px;display:flex;justify-content:space-between}}
</style></head><body>
<div class="hd"><h1>{e(code)}<small>{e(name)}</small></h1>
<div class="meta">{e(window)}<br>{e(sample)}{f'<div class="warn">{e(warn)}</div>' if warn else ''}</div></div>
<hr><h2>성향</h2>
{axis_html}
{f'<hr><h2>도구별 · 같은 사람이 도구마다 다르게 말한다</h2><table><tr><th></th><td>지시</td><td>중앙값</td><td>물음표</td><td>확인 요청</td><td>새벽</td></tr>{tool_rows}</table>' if len(tools) > 1 else ''}
<hr><div class="cols">
<div><h2>자주 쓴 말</h2>{chips(habits)}</div>
<div><h2>자모</h2>{chips(jamo)}
<h2 style="margin-top:20px">말의 온도</h2>
<div class="tone"><b>질책 {e(scold)}%</b> &nbsp;대&nbsp; <b>칭찬 {e(praise)}%</b></div></div></div>
<hr><h2>어디서 말했나</h2>{chips(projs)}
<hr><footer><span>prompt-dna</span><span>원문 지시는 이 카드에 없다</span></footer>
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
      --force-device-scale-factor=2 --window-size=960,880 \
      --screenshot="$PNGOUT" "file://$OUT" >/dev/null 2>&1
    [ -f "$PNGOUT" ] && echo "$PNGOUT" || echo "PNG 렌더에 실패했다" >&2
  fi
fi
