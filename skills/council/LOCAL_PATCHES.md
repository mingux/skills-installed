# Local patches

Source: https://github.com/0xNyk/council-of-high-intelligence at `bb42b4b` (v1.2.0, MIT).
Installed: SKILL.md, scripts/detect-providers.sh, two configs, and the 18
persona agents in `.claude/agents/council-*.md`. Not installed: the
Codex/Gemini/opencode variants, the assets, the demos, and the dev scripts.

Re-apply these patches after any update from upstream:

1. `SKILL.md` frontmatter gets `disable-model-invocation: true`, so the
   council runs only when you type `/council`. Without it, Claude can start
   15–75 subagents by itself whenever a problem looks "complex".
2. The Codex seat uses `codex exec --sandbox read-only` instead of
   `-c auto_approve=true`. Council members only reason. A seat whose prompt
   contains repo or web text must not be able to run commands without asking.
3. Persona agents get `tools: [Read, Grep, Glob, WebSearch, WebFetch]`, with
   no `Bash`. If a member needs to run code to test a claim, do that outside
   the council.
4. "Asset Resolution" gets a project layout step (`.claude/...` relative to
   the repo root), tried before `~/.claude/...`.
