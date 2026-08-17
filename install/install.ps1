param(
  [switch]$Full,
  [switch]$SupportOnly,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$Mode = "full"
if ($SupportOnly) { $Mode = "support-only" }
if ($Full) { $Mode = "full" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$UserSkillsHome = if ($env:USER_SKILLS_HOME) { $env:USER_SKILLS_HOME } else { Join-Path $HOME ".agents\skills" }
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

function Write-Step($Message) {
  Write-Host $Message
}

function Invoke-InstallCommand {
  param([scriptblock]$Command, [string]$Display)
  if ($DryRun) {
    Write-Host "[dry-run] $Display"
  } else {
    & $Command
  }
}

function Backup-File {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path -PathType Leaf) {
    $Backup = "$Path.bak.$Timestamp"
    Write-Step "Backing up $Path -> $Backup"
    Invoke-InstallCommand { Copy-Item -LiteralPath $Path -Destination $Backup -Force } "Copy-Item '$Path' '$Backup'"
  }
}

function Copy-PlaybookFile {
  param([string]$Source, [string]$Destination)
  $Parent = Split-Path -Parent $Destination
  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"
  Backup-File $Destination
  Write-Step "Installing $Destination"
  Invoke-InstallCommand { Copy-Item -LiteralPath $Source -Destination $Destination -Force } "Copy-Item '$Source' '$Destination'"
}

function Copy-PlaybookTree {
  param([string]$SourceDir, [string]$DestinationDir)
  if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
    Write-Step "Skipping missing source directory: $SourceDir"
    return
  }

  Get-ChildItem -LiteralPath $SourceDir -Recurse -File | ForEach-Object {
    $RelativePath = $_.FullName.Substring((Resolve-Path $SourceDir).Path.Length).TrimStart('\','/')
    $Dest = Join-Path $DestinationDir $RelativePath
    Copy-PlaybookFile $_.FullName $Dest
  }
}

function AddOrReplace-PlaybookSection {
  param([string]$Target, [string]$Title, [string]$Body)

  $StartMarker = "<!-- codex-agent-playbook:start -->"
  $EndMarker = "<!-- codex-agent-playbook:end -->"
  $Parent = Split-Path -Parent $Target
  $Newline = "`n"
  $NormalizedBody = ($Body -replace "`r`n", "`n") -replace "`r", "`n"
  $Section = "$StartMarker$Newline# $Title$Newline$Newline$NormalizedBody$Newline$EndMarker"

  if (Test-Path -LiteralPath $Target -PathType Leaf) {
    $Existing = Get-Content -LiteralPath $Target -Raw
    $Newline = if ($Existing.Contains("`r`n")) { "`r`n" } else { "`n" }
    if ($Newline -eq "`r`n") {
      $NormalizedBody = $NormalizedBody -replace "`n", "`r`n"
    }
    $Section = "$StartMarker$Newline# $Title$Newline$Newline$NormalizedBody$Newline$EndMarker"
    $StartIndex = $Existing.IndexOf($StartMarker, [System.StringComparison]::Ordinal)
    $EndIndex = $Existing.IndexOf($EndMarker, [System.StringComparison]::Ordinal)
    $HasStart = $StartIndex -ge 0
    $HasEnd = $EndIndex -ge 0

    if ($HasStart -or $HasEnd) {
      $SecondStartIndex = if ($HasStart) { $Existing.IndexOf($StartMarker, $StartIndex + $StartMarker.Length, [System.StringComparison]::Ordinal) } else { -1 }
      $SecondEndIndex = if ($HasEnd) { $Existing.IndexOf($EndMarker, $EndIndex + $EndMarker.Length, [System.StringComparison]::Ordinal) } else { -1 }

      if (-not ($HasStart -and $HasEnd) -or $SecondStartIndex -ge 0 -or $SecondEndIndex -ge 0 -or $EndIndex -lt $StartIndex) {
        throw "Malformed Codex Agent Playbook markers in $Target; no changes were made."
      }

      Backup-File $Target
      if ($DryRun) {
        Write-Step "[dry-run] Would replace the Codex Agent Playbook section in $Target"
      } else {
        $Updated = $Existing.Substring(0, $StartIndex) + $Section + $Existing.Substring($EndIndex + $EndMarker.Length)
        Set-Content -LiteralPath $Target -Value $Updated -Encoding UTF8 -NoNewline
      }
      return
    }
  }

  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"
  Backup-File $Target

  if ($DryRun) {
    Write-Step "[dry-run] Would append $Title to $Target"
  } else {
    if (Test-Path -LiteralPath $Target -PathType Leaf) {
      Set-Content -LiteralPath $Target -Value ($Existing + $Newline + $Newline + $Section) -Encoding UTF8 -NoNewline
    } else {
      Add-Content -LiteralPath $Target -Value "`n`n$Section" -Encoding UTF8
    }
  }
}

$GlobalInstructions = Join-Path $RepoRoot "custom-instructions\global-coding-agent-instructions.md"
$ReferencesDir = Join-Path $RepoRoot "references"
$AgentsDir = Join-Path $RepoRoot "agents"
$SkillsDir = Join-Path $RepoRoot "skills"
$TargetAgentsMd = Join-Path $CodexHome "AGENTS.md"

Write-Step "Codex Agent Playbook installer"
Write-Step "Mode: $Mode"
Write-Step "Repository: $RepoRoot"
Write-Step "CODEX_HOME: $CodexHome"
Write-Step "USER_SKILLS_HOME: $UserSkillsHome"

if (-not (Test-Path -LiteralPath $GlobalInstructions -PathType Leaf)) {
  throw "Missing global instructions: $GlobalInstructions"
}

if (Test-Path -LiteralPath (Join-Path $CodexHome "AGENTS.override.md") -PathType Leaf) {
  Write-Step "Notice: AGENTS.override.md exists and may override AGENTS.md"
}

if ($Mode -eq "full") {
  if (Test-Path -LiteralPath $TargetAgentsMd -PathType Leaf) {
    $Body = Get-Content -LiteralPath $GlobalInstructions -Raw
    AddOrReplace-PlaybookSection $TargetAgentsMd "Codex Agent Playbook Global Instructions" $Body
  } else {
    Copy-PlaybookFile $GlobalInstructions $TargetAgentsMd
  }
} else {
  $PointerBody = @'
The primary global coding-agent behavior may be configured in Codex Personalization > Custom instructions or in this AGENTS.md file.

Supporting global reference documents live under the Codex home references directory:

- `references/README.md` — map of available global reference docs
- `references/model-routing.md` — mandatory subagent model-selection, escalation, and acceptance rules
- `references/subagents.md` — subagent delegation rules, assignment template, and acceptance checklist
- `references/worktrees.md` — root-owned task-local worktree budgeting, permits, integration, cleanup, and preservation rules
- `references/multi-session-coordination.md` — discovery, thread naming, ownership, sequencing, conflict detection, and integration guidance for independent project threads
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level architecture, testing, access-control, design-system, release, API, data-model, active-work, task-graph, and worktree-manifest docs

Reusable skills live under the user skills directory, including:

- `subagent-orchestration`
- `task-graph-orchestration`
- `worktree-lifecycle`
- `multi-session-coordination`
- `reference-doc-routing`
- `senior-code-review`

Custom Codex subagents live under the Codex home agents directory:

- `agents/planner.toml`
- `agents/engineer.toml`
- `agents/reviewer.toml`
- `agents/tester.toml`
- `agents/docs.toml`
- `agents/planner-luna.toml`, `agents/engineer-luna.toml`, `agents/reviewer-luna.toml`, `agents/tester-luna.toml`, `agents/docs-luna.toml`

Reference documents are supporting context, not automatic truth. For every repository task when subagents are available, the main agent delegates actual execution to at least one bounded subagent; it remains accountable for orchestration, final diff, validation, acceptance, and final response. Direct main-agent execution is limited to unavailable subagents, an explicit user prohibition, or a specific authority-bound action that cannot be delegated; record the exact exception.

The root records the actual user-selected main model, canonical rank, separate reasoning-effort ceiling, finite manifest, total spawned-node budget, and child-specific permits; never assume the root is Sol. Use `gpt-5.6-sol` rank 3 > `gpt-5.6-terra` rank 2 > `gpt-5.6-luna` rank 1. Every dispatched child must already be a finite-manifest member, fit the remaining total node budget, hold its required root permit, and fit runtime, safety, and ownership capacity. Its model rank and effort must be at or below the separate ceilings of its parent; equal-tier children are valid, and depth does not force a tier drop. Expand the manifest or budget only for a newly discovered dependency, invalidated gate, or changed user scope; a material expansion also needs immediate user approval. Profiles are callable only when the host supports custom-agent invocation, including an `@tag` interface if offered, and are depth 1. A root-permitted depth-1 local orchestrator may create declared depth-2 leaves. Depth 2 executes directly and cannot spawn. Descendants cannot upgrade and must stop and report if their ceilings are insufficient. When capacity is full, do not queue speculative descendants.

The auxiliary-worktree budget starts at zero and is separate from the node budget. Worktrees are not created per agent. Only root may issue a worktree permit or create, adopt, repurpose, move, or remove an auxiliary worktree. Root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Descendants use their exact assigned workspace and report isolation needs upward. Before the final response, root removes each task-created auxiliary under verified safety gates or preserves it with an exact owner, path, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation. A host-managed active workspace follows the supported host lifecycle.
'@
  AddOrReplace-PlaybookSection $TargetAgentsMd "Global Reference Documents and Subagent Support" $PointerBody
}

Copy-PlaybookTree $ReferencesDir (Join-Path $CodexHome "references")
Copy-PlaybookTree $AgentsDir (Join-Path $CodexHome "agents")
Copy-PlaybookTree $SkillsDir $UserSkillsHome

Write-Step ""
Write-Step "Validation:"
$CheckPaths = @(
  $TargetAgentsMd,
  (Join-Path $CodexHome "references\model-routing.md"),
  (Join-Path $CodexHome "references\subagents.md"),
  (Join-Path $CodexHome "references\worktrees.md"),
  (Join-Path $CodexHome "references\multi-session-coordination.md"),
  (Join-Path $CodexHome "references\reference-doc-routing.md"),
  (Join-Path $CodexHome "references\templates\active-work-record.md"),
  (Join-Path $CodexHome "references\templates\task-graph.md"),
  (Join-Path $CodexHome "references\templates\worktree-manifest.md"),
  (Join-Path $CodexHome "agents\planner.toml"),
  (Join-Path $CodexHome "agents\engineer.toml"),
  (Join-Path $CodexHome "agents\reviewer.toml"),
  (Join-Path $CodexHome "agents\tester.toml"),
  (Join-Path $CodexHome "agents\docs.toml"),
  (Join-Path $CodexHome "agents\planner-luna.toml"),
  (Join-Path $CodexHome "agents\engineer-luna.toml"),
  (Join-Path $CodexHome "agents\reviewer-luna.toml"),
  (Join-Path $CodexHome "agents\tester-luna.toml"),
  (Join-Path $CodexHome "agents\docs-luna.toml"),
  (Join-Path $UserSkillsHome "subagent-orchestration\SKILL.md"),
  (Join-Path $UserSkillsHome "task-graph-orchestration\SKILL.md"),
  (Join-Path $UserSkillsHome "worktree-lifecycle\SKILL.md"),
  (Join-Path $UserSkillsHome "multi-session-coordination\SKILL.md")
)

foreach ($Path in $CheckPaths) {
  if ($DryRun -or (Test-Path -LiteralPath $Path)) {
    Write-Step "OK: $Path"
  } else {
    Write-Warning "Missing: $Path"
  }
}

Get-ChildItem -LiteralPath $UserSkillsHome -Filter SKILL.md -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
  $Text = Get-Content -LiteralPath $_.FullName -Raw
  if ($Text -match "(?m)^name:" -and $Text -match "(?m)^description:") {
    Write-Step "OK frontmatter: $($_.FullName)"
  } else {
    Write-Warning "Check frontmatter: $($_.FullName)"
  }
}

Write-Step ""
Write-Step "Install complete. Restart Codex or start a new session if needed so new instructions, skills, and agents are loaded."
