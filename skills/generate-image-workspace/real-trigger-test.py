"""Test whether the real installed generate-image skill triggers for each query.

Runs `claude -p <query> --max-turns 1` in an empty sandbox dir and checks the
first tool call: Skill(generate-image) or Read(...generate-image...SKILL.md)
counts as triggered.
"""
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

HERE = Path(__file__).parent
EVAL = json.loads((HERE / "trigger-eval.json").read_text(encoding="utf-8"))
SANDBOX = HERE / "sandbox"
SANDBOX.mkdir(exist_ok=True)

ENV = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}


def run_query(item):
    query = item["query"]
    cmd = [
        "claude", "-p", query,
        "--output-format", "stream-json",
        "--verbose",
        "--max-turns", "1",
        "--model", "claude-fable-5",
    ]
    try:
        proc = subprocess.run(
            cmd, capture_output=True, timeout=180, cwd=str(SANDBOX), env=ENV, shell=True
        )
        out = proc.stdout.decode("utf-8", errors="replace")
    except subprocess.TimeoutExpired:
        return {**item, "triggered": None, "note": "timeout"}

    triggered = False
    for line in out.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "assistant":
            for c in event.get("message", {}).get("content", []):
                if c.get("type") != "tool_use":
                    continue
                name = c.get("name", "")
                inp = json.dumps(c.get("input", {}))
                if name == "Skill" and "generate-image" in inp:
                    triggered = True
                elif name == "Read" and "generate-image" in inp and "SKILL.md" in inp:
                    triggered = True
                # first tool call decides; stop scanning
                return {**item, "triggered": triggered, "first_tool": name}
    return {**item, "triggered": False, "first_tool": None}


def main():
    results = []
    with ThreadPoolExecutor(max_workers=4) as ex:
        futures = {ex.submit(run_query, item): item for item in EVAL}
        for fut in as_completed(futures):
            r = fut.result()
            ok = r["triggered"] == r["should_trigger"]
            status = "PASS" if ok else "FAIL"
            print(f"[{status}] expect={r['should_trigger']} got={r['triggered']} "
                  f"tool={r.get('first_tool')} :: {r['query'][:70]}", flush=True)
            results.append({**r, "pass": ok})

    passed = sum(1 for r in results if r["pass"])
    tp = sum(1 for r in results if r["should_trigger"] and r["triggered"])
    fn = sum(1 for r in results if r["should_trigger"] and not r["triggered"])
    fp = sum(1 for r in results if not r["should_trigger"] and r["triggered"])
    print(f"\nTotal: {passed}/{len(results)} | should-trigger hit {tp}, missed {fn} | false triggers {fp}")
    (HERE / "real-trigger-results.json").write_text(
        json.dumps(results, indent=2), encoding="utf-8"
    )


if __name__ == "__main__":
    main()
