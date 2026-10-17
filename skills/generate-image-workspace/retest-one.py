import json, os, subprocess
from pathlib import Path

SANDBOX = Path(__file__).parent / "sandbox"
ENV = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
q = "remove the background from photo.png in my downloads folder"
proc = subprocess.run(
    ["claude", "-p", q, "--output-format", "stream-json", "--verbose",
     "--max-turns", "1", "--model", "claude-fable-5"],
    capture_output=True, timeout=180, cwd=str(SANDBOX), env=ENV, shell=True,
)
for line in proc.stdout.decode("utf-8", errors="replace").splitlines():
    try:
        event = json.loads(line.strip())
    except json.JSONDecodeError:
        continue
    if event.get("type") == "assistant":
        for c in event.get("message", {}).get("content", []):
            if c.get("type") == "tool_use":
                print("FIRST TOOL:", c.get("name"), json.dumps(c.get("input", {}))[:200])
                raise SystemExit
print("no tool call")
