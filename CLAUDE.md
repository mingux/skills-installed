# Skills Installed: rules for Claude

This repo is the single home of the owner's Claude Code skills (`C:\Dev\Skills Installed`).

## Installing a new skill
1. **Review it first.** Clone it to a scratch folder and read SKILL.md, scripts and installers. Look for network calls, auto-approve flags, broad tool grants, licence, and size. Tell the owner what you found before installing. If it's unsafe or not worth it, say so.
2. **Pick its home:**
   - General-purpose skill: `skills/<name>/` (loads in every project).
   - Subagents: `agents/<name>.md`.
   - A skill pack that depends on its own repo tooling: clone it to `workspaces/<Name>/` pinned to the reviewed commit (add the clone to `setup.ps1` and `workspaces/README.md`). Never copy its skills into `skills/`.
   - Project-only skill: keep it in that project's `.claude/skills/` and put a safekeeping copy in `project-skills/<project>/`.
   - MCP servers: register with `claude mcp add --scope user …`, pinned to a version, using `cmd /c npx` on Windows. Add the command to `setup.ps1`.
3. **Avoid name clashes.** Check `skills/*/SKILL.md` names first and rename if needed.
4. **Record local changes.** Any patch goes in `skills/<name>/LOCAL_PATCHES.md` with the upstream commit.
5. **Catalog it.** Add an entry to `catalog.json` (same fields as the others; measure idle and per-use token cost from file sizes) **and** write the same record to the live catalog artifact database: `Artifact` / `ArtifactData` on `https://claude.ai/artifact/CYqtest2QQ3w5pyqaYCwYm`, collection `skills`, doc id = the skill id. The page updates live.
6. **Commit and push** (`main`). On the laptop, the owner runs `git pull`.

## Cloud sessions
Cloud containers can't see `C:\`. Push here and the owner pulls. To use these skills in a cloud
session, attach this repo and copy `skills/<name>` into `~/.claude/skills/`.
