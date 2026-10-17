# Skills Installed

The home of every Claude Code skill, agent and skill workspace I use.
Clone it to `C:\Dev\Skills Installed`. `setup.ps1` turns `~/.claude/skills`
and `~/.claude/agents` into junctions pointing here, so anything installed
later lands in this folder automatically.

**Live catalog:** https://claude.ai/artifact/CYqtest2QQ3w5pyqaYCwYm (what each skill does, what it costs, when to use it).

| Folder | Loaded |
|---|---|
| `skills/` | in every Claude Code project on this laptop (`~/.claude/skills`) |
| `agents/` | in every project (`~/.claude/agents`) |
| `project-skills/<project>/` | safekeeping copies of project-only skills; the live copy stays in that repo |
| `workspaces/` | only when Claude Code is opened inside that workspace folder |
| `catalog.json` | the source data for the live catalog |

## First-time setup (Windows)

```powershell
# extract the zip (or git clone) to C:\Dev\Skills Installed, then:
cd "C:\Dev\Skills Installed"
.\setup.ps1 -DryRun   # preview
.\setup.ps1
```

Close Claude Code first. The script backs up your current `~/.claude/skills`
and `~/.claude/agents` to `_backup\` before moving anything.

## Updating

`git pull` here picks up skills installed in cloud sessions.
