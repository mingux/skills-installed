# Local patches

Source: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill at `56ea9cf` (MIT), folder `.claude/skills/ui-ux-pro-max`.

Repair, 2026-10-18: the laptop copy's `data` and `scripts` were symlinks into a separate checkout
(`../../../src/ui-ux-pro-max/...`). They broke when the skill moved here, and git on Windows had
stored them as text files. The laptop SKILL.md was also older than the scripts: it used a `prompt`
domain the current scripts don't have. Replaced with upstream's self-contained, matching folder
(SKILL.md, references, data, scripts). The old SKILL.md is in git history (commit 0f4e81d).

1. Script paths: `${CLAUDE_PLUGIN_ROOT}/.claude/skills/ui-ux-pro-max/` becomes
   `$HOME/.claude/skills/ui-ux-pro-max/`, because this is a user skill (via the junction), not a plugin.

Reviewed: Python standard library only, no network calls, no subprocess calls. `--persist` writes
design-system files into the project when asked.
