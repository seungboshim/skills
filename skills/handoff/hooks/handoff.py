#!/usr/bin/env python3
"""컨텍스트가 차면 핸드오프 문서를 쓰게 하고, clear/compact 뒤 새 세션에 건넨다.

  handoff.py stop           Stop hook. 임계를 넘으면 exit 2 로 문서 작성을 지시한다
  handoff.py session-start  SessionStart hook. source 가 clear/compact 이면 문서를 주입한다
  handoff.py selftest       판정 로직 자체 점검
"""

import json
import os
import sys

THRESHOLD = 0.80      # 이 비율을 넘으면 핸드오프 문서를 만든다
REWRITE_STEP = 0.05   # 지난 갱신 후 이만큼 더 차면 다시 쓴다
TAIL_BYTES = 1 << 20  # transcript 끝에서 이만큼만 읽는다. 마지막 usage 만 필요하다
DEFAULT_LIMIT = 200_000
WIDE_LIMIT = 1_000_000

INTRO = {
    "clear": "# 이전 세션 핸드오프\n\n앞 세션을 /clear 로 비우기 직전에 정리한 내용이다."
             " 여기서 이어서 작업한다.\n",
    "compact": "# 압축 전 핸드오프\n\n자동 요약이 놓친 부분은 아래 문서로 보강한다.\n",
}


def paths(cwd):
    base = os.path.join(cwd, ".claude")
    return os.path.join(base, "handoff.md"), os.path.join(base, "handoff.tok")


def limit_for(used):
    """컨텍스트 한계.

    transcript 의 message.model 은 `claude-opus-5` 처럼만 남고 1M 모드 여부가 붙지 않는다.
    그래서 모델 이름으로는 한계를 알 수 없다. env 로 받은 값을 먼저 쓰고, 없으면 관측된
    크기로 추정한다. 200k 를 넘겼다면 1M 세션이다.
    """
    try:
        override = int(os.environ.get("HANDOFF_CONTEXT_LIMIT", "0"))
    except ValueError:
        override = 0
    if override > 0:
        return override
    return WIDE_LIMIT if used > DEFAULT_LIMIT else DEFAULT_LIMIT


def context_size(transcript):
    """마지막 assistant usage 에서 (현재 컨텍스트 크기, 한계) 를 읽는다."""
    try:
        with open(transcript, "rb") as f:
            f.seek(0, os.SEEK_END)
            start = max(0, f.tell() - TAIL_BYTES)
            f.seek(start)
            chunk = f.read()
    except OSError:
        return None

    lines = chunk.split(b"\n")
    if start:
        lines = lines[1:]  # 중간에서 잘린 첫 줄은 버린다
    for line in reversed(lines):
        try:
            message = json.loads(line).get("message") or {}
            usage = message.get("usage")
        except (ValueError, AttributeError):
            continue
        if not usage:
            continue
        used = (usage.get("input_tokens", 0)
                + usage.get("cache_creation_input_tokens", 0)
                + usage.get("cache_read_input_tokens", 0))
        return used, limit_for(used)
    return None


def read_stamp(path):
    """지난번 문서를 쓴 시점의 컨텍스트 크기."""
    try:
        with open(path) as f:
            return int(f.read().strip())
    except (OSError, ValueError):
        return 0


def due(used, limit, stamp):
    """지금 핸드오프 문서를 (다시) 써야 하나."""
    if used < limit * THRESHOLD:
        return False
    if stamp > used:
        stamp = 0  # compact/clear 로 컨텍스트가 줄었다. 낡은 기준을 버린다
    return used - stamp >= limit * REWRITE_STEP


def stop(data):
    if data.get("stop_hook_active"):
        return 0  # 이미 이 훅 때문에 한 번 더 돌고 있다
    size = context_size(data.get("transcript_path") or "")
    if not size:
        return 0
    used, limit = size
    doc, tok = paths(data.get("cwd") or os.getcwd())
    if not due(used, limit, read_stamp(tok)):
        return 0

    os.makedirs(os.path.dirname(tok), exist_ok=True)
    with open(tok, "w") as f:
        f.write(str(used))

    verb = "갱신" if os.path.exists(doc) else "작성"
    print(
        f"컨텍스트가 {used * 100 // limit}% 찼다. handoff 스킬을 읽고 {doc} 를"
        f" 지금 상태로 {verb}해라. 다 쓰면 사용자에게 /clear 를 안내하고 답을 마쳐라.",
        file=sys.stderr,
    )
    return 2


def session_start(data):
    source = data.get("source")
    intro = INTRO.get(source)
    if not intro:
        return 0  # startup, resume, fork 는 넘길 게 없다
    doc, tok = paths(data.get("cwd") or os.getcwd())
    try:
        with open(doc, encoding="utf-8") as f:
            body = f.read()
    except OSError:
        return 0

    print(intro)
    print(body)
    if source == "clear":
        os.replace(doc, doc + ".done")  # 한 번만 건넨다
        if os.path.exists(tok):
            os.remove(tok)
    return 0


def selftest():
    import tempfile

    os.environ.pop("HANDOFF_CONTEXT_LIMIT", None)
    assert limit_for(120_000) == DEFAULT_LIMIT
    assert limit_for(300_000) == WIDE_LIMIT      # 200k 를 넘겼으니 1M 세션이다
    os.environ["HANDOFF_CONTEXT_LIMIT"] = "500000"
    assert limit_for(120_000) == 500_000         # 명시한 값이 추정을 이긴다
    os.environ.pop("HANDOFF_CONTEXT_LIMIT")

    wide = ('{"message":{"model":"claude-opus-5","usage":{"input_tokens":10,'
            '"cache_creation_input_tokens":40,"cache_read_input_tokens":850000}}}')
    plain = '{"message":{"usage":{"input_tokens":5,"cache_read_input_tokens":100}}}'

    with tempfile.TemporaryDirectory() as d:
        wide_path = os.path.join(d, "wide.jsonl")
        with open(wide_path, "w") as f:
            f.write('{"type":"user"}\n' + wide + "\n")
        assert context_size(wide_path) == (850050, WIDE_LIMIT), context_size(wide_path)

        plain_path = os.path.join(d, "plain.jsonl")
        with open(plain_path, "w") as f:
            f.write(plain + "\n")
        assert context_size(plain_path) == (105, DEFAULT_LIMIT), context_size(plain_path)

        assert context_size(os.path.join(d, "missing.jsonl")) is None

    limit = 1_000_000
    assert not due(700_000, limit, 0)        # 임계 미달
    assert due(850_000, limit, 0)            # 처음 80% 를 넘겼다
    assert not due(860_000, limit, 850_000)  # 갱신 직후. 1% 만 늘었다
    assert due(900_000, limit, 850_000)      # 5% 더 찼다
    assert due(820_000, limit, 950_000)      # compact 으로 줄었다. 기준을 버린다
    print("ok")
    return 0


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    if mode == "selftest":
        sys.exit(selftest())
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        sys.exit(0)
    if mode == "stop":
        sys.exit(stop(payload))
    if mode == "session-start":
        sys.exit(session_start(payload))
    sys.exit(0)
