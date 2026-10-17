# One-time setup: make C:\Dev\Skills Installed the home of all Claude Code skills.
#
#   1. Backs up %USERPROFILE%\.claude\skills and \agents into _backup\<time>\
#   2. Moves what is already there into this folder (name clashes go to _conflicts\)
#   3. Replaces both folders with junctions pointing here, so anything installed
#      into ~/.claude/skills or ~/.claude/agents from now on lands in this folder
#   4. Registers the REA MCP server (user scope) and clones OpenMontage into workspaces\
#   5. Adds the "install skills here" rule to %USERPROFILE%\.claude\CLAUDE.md
#
# Usage (close Claude Code first):
#   cd "C:\Dev\Skills Installed"
#   .\setup.ps1 -DryRun        # show what would happen
#   .\setup.ps1                # do it
#   .\setup.ps1 -SkipRea -SkipOpenMontage
param([switch]$DryRun, [switch]$SkipRea, [switch]$SkipOpenMontage)

$ErrorActionPreference = "Stop"
$Root   = $PSScriptRoot
$Claude = Join-Path $env:USERPROFILE ".claude"
$Stamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$Imported = New-Object System.Collections.Generic.List[string]

function Say($msg, $color = "Gray") { Write-Host $msg -ForegroundColor $color }
function Act($desc, [scriptblock]$block) {
    if ($DryRun) { Say "  [dry-run] $desc" "DarkCyan" } else { Say "  $desc"; & $block }
}

function Native([string]$exe, [string[]]$argv) {
    # Windows PowerShell 5.1 turns a native tool's stderr into a terminating
    # error under ErrorActionPreference=Stop. Run native tools with Continue
    # and judge success by the exit code only.
    $old = $ErrorActionPreference; $ErrorActionPreference = "Continue"
    try { & $exe @argv 2>&1 | ForEach-Object { "    $_" } | Out-Host; return $LASTEXITCODE }
    finally { $ErrorActionPreference = $old }
}

if (Get-Process -Name "claude" -ErrorAction SilentlyContinue) {
    Say "Claude is running. Close Claude Code and the Claude desktop app, then run this again." "Red"
    exit 1
}
if (-not (Test-Path $Claude)) { Act "create $Claude" { New-Item -ItemType Directory -Path $Claude | Out-Null } }

function Link-Folder([string]$Name) {
    $target = Join-Path $Root $Name
    $link   = Join-Path $Claude $Name
    Say "`n== $link -> $target" "Cyan"

    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.LinkType -in @("Junction", "SymbolicLink")) {
            if (@($item.Target) -contains $target) { Say "  already linked, nothing to do" "Green"; return }
            Say "  $link is already a link to $($item.Target). Remove it yourself, then rerun." "Red"; exit 1
        }
        $backup = Join-Path $Root "_backup\$Stamp\$Name"
        Act "back up $link to $backup" {
            New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
            Copy-Item $link $backup -Recurse -Force
        }
        foreach ($child in Get-ChildItem $link -Force) {
            $dest = Join-Path $target $child.Name
            if (Test-Path $dest) {
                $conflict = Join-Path $Root "_conflicts\$Stamp\$Name\$($child.Name)"
                Act "CLASH: $($child.Name) already exists here; laptop copy kept at $conflict (not loaded)" {
                    New-Item -ItemType Directory -Path (Split-Path $conflict) -Force | Out-Null
                    Move-Item $child.FullName $conflict
                }
            } else {
                Act "move $($child.Name) into $Name\" { Move-Item $child.FullName $dest }
                $Imported.Add("$Name\$($child.Name)")
            }
        }
        Act "remove the now-empty $link" { Remove-Item $link -Force -Recurse }
    }
    Act "create junction $link -> $target" { New-Item -ItemType Junction -Path $link -Target $target | Out-Null }
}

Link-Folder "skills"
Link-Folder "agents"

# REA MCP server (user scope). On native Windows, npx needs the cmd /c wrapper.
if (-not $SkipRea) {
    Say "`n== REA MCP server" "Cyan"
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Say "  'claude' not on PATH - skipped. Run later: claude mcp add --scope user rea -- cmd /c npx -y rea-agents@6.5.0 mcp" "Yellow" }
    elseif (-not (Get-Command npx -ErrorAction SilentlyContinue)) { Say "  Node.js/npx not found - install Node 22 LTS, then rerun with -SkipOpenMontage" "Yellow" }
    else {
        $old = $ErrorActionPreference; $ErrorActionPreference = "Continue"
        & claude mcp get rea *> $null; $found = ($LASTEXITCODE -eq 0)
        $ErrorActionPreference = $old
        if ($found) { Say "  already registered" "Green" }
        else { Act "claude mcp add --scope user rea -- cmd /c npx -y rea-agents@6.5.0 mcp" {
            if ((Native "claude" @("mcp","add","--scope","user","rea","--","cmd","/c","npx","-y","rea-agents@6.5.0","mcp")) -ne 0) { Say "  registration failed - see the message above" "Red" } } }
    }
}

# OpenMontage workspace, pinned to the reviewed commit.
if (-not $SkipOpenMontage) {
    Say "`n== OpenMontage workspace" "Cyan"
    $om = Join-Path $Root "workspaces\OpenMontage"
    if (Test-Path $om) { Say "  already present" "Green" }
    elseif (-not (Get-Command git -ErrorAction SilentlyContinue)) { Say "  git not found - skipped" "Yellow" }
    else {
        Act "git clone OpenMontage (pinned c806645) into workspaces\OpenMontage" {
            if ((Native "git" @("clone","https://github.com/calesthio/OpenMontage",$om)) -ne 0) { Say "  clone failed" "Red"; return }
            [void](Native "git" @("-C",$om,"checkout","-q","c806645"))
        }
    }
}

# Global rule so every future local session installs skills here.
$rules = Join-Path $Claude "CLAUDE.md"
$marker = "<!-- skills-installed-rule -->"
if (-not ((Test-Path $rules) -and (Select-String -Path $rules -SimpleMatch $marker -Quiet))) {
    $rule = @"

$marker
## Where skills are installed
All Claude Code skills, agents and skill workspaces live in ``C:\Dev\Skills Installed`` (a git repo).
``~/.claude/skills`` and ``~/.claude/agents`` are junctions to its ``skills\`` and ``agents\`` folders.
When installing anything new: review it first, then follow ``C:\Dev\Skills Installed\CLAUDE.md``
(install location, catalog.json entry, live catalog update, commit).
"@
    Act "append the skills rule to $rules" { Add-Content -Path $rules -Value $rule -Encoding UTF8 }
}

# Keep imported laptop skills safe in git.
if ($Imported.Count -gt 0 -and -not $DryRun -and (Test-Path (Join-Path $Root ".git"))) {
    Say "`n== Committing imported laptop skills" "Cyan"
    [void](Native "git" @("-C",$Root,"add","skills","agents"))
    [void](Native "git" @("-C",$Root,"commit","-q","-m","Import existing laptop skills ($Stamp)"))
    $Imported | Out-File (Join-Path $Root "_imported-$Stamp.txt") -Encoding UTF8
}

Say "`nDone." "Green"
if ($Imported.Count -gt 0) { Say "Imported from the laptop (ask Claude to add them to the catalog): $($Imported -join ', ')" "Yellow" }
Say "Start Claude Code again - skills now load from $Root\skills."
