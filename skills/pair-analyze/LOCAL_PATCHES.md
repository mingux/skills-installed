# Local patches

Source: https://github.com/mahmoud20138/tradecraft (plugins/tradecraft/skills, sha df6141f, installed with skillfish).

1. `disable-model-invocation: true` (2026-10-18, owner request): tradecraft is available on demand (`/pair-analyze`) but no longer loads its description into every session.
2. Added "Loading the step skills (this install)": read each step's SKILL.md by path, because manual-only skills can't be started with the Skill tool. Missing upstream steps (fetch-quotes, trading-fundamentals) fall back to user-supplied data or web search.
