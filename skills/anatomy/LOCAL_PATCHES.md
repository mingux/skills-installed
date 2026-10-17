# Local patches

Source: https://github.com/wheresryan22/anatomy at `e948829` (MIT). Installed without `.git` and `.github`.

1. `SKILL.md` frontmatter gets `disable-model-invocation: true`, so it runs only when you type `/anatomy`. Upstream starts it for any "explanatory diagram … even if they never say isometric", and a figure is a long, expensive session by design.

Reviewed: no dependencies, and the scripts only talk to `127.0.0.1` (local Chrome checks). `scripts/publish.mjs` opens a pull request against the author's gallery through the `gh` CLI, and only when you ask. `scripts/session.mjs` reads the local session logs only to compute time and tokens for that gallery credit.
