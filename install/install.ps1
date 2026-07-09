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

function Append-SectionIfMissing {
  param([string]$Target, [string]$Title, [string]$Body)

  $Marker = "codex-agent-playbook"
  $Parent = Split-Path -Parent $Target
  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"

  if ((Test-Path -LiteralPath $Target -PathType Leaf) -and ((Get-Content -LiteralPath $Target -Raw) -match $Marker)) {
    Write-Step "Codex Agent Playbook section already present in $Target; leaving it unchanged."
    return
  }

  Backup-File $Target

  $Section = @"

<!-- codex-agent-playbook:start -->
# $Title

$Body
<!-- codex-agent-playbook:end -->
"@

  if ($DryRun) {
    Write-Step "[dry-run] Would append $Title to $Target"
  } else {
    Add-Content -LiteralPath $Target -Value $Section -Encoding UTF8
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
    Append-SectionIfMissing $TargetAgentsMd "Codex Agent Playbook Global Instructions" $Body
  } else {
    Copy-PlaybookFile $GlobalInstructions $TargetAgentsMd
  }
} else {
  $PointerBody = @"
The primary global coding-agent behavior may be configured in Codex Personalization > Custom instructions or in this AGENTS.md file.

Supporting global reference documents live under the Codex home references directory:

- `references/README.md` — map of available global reference docs
- `references/subagents.md` — subagent delegation rules, model selection guidance, assignment template, and acceptance checklist
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level architecture, testing, access-control, design-system, release, API, and data-model docs

Custom Codex subagents live under the Codex home agents directory:

- `agents/planner.toml`
- `agents/engineer.toml`
- `agents/reviewer.toml`
- `agents/tester.toml`
- `agents/docs.toml`

Reference documents are supporting context, not automatic truth. The main agent remains accountable for the final plan, final diff, validation, and final response.
"@
  Append-SectionIfMissing $TargetAgentsMd "Global Reference Documents and Subagent Support" $PointerBody
}

Copy-PlaybookTree $ReferencesDir (Join-Path $CodexHome "references")
Copy-PlaybookTree $AgentsDir (Join-Path $CodexHome "agents")
Copy-PlaybookTree $SkillsDir $UserSkillsHome

Write-Step ""
Write-Step "Validation:"
$CheckPaths = @(
  $TargetAgentsMd,
  (Join-Path $CodexHome "references\subagents.md"),
  (Join-Path $CodexHome "references\reference-doc-routing.md"),
  (Join-Path $CodexHome "agents\planner.toml"),
  (Join-Path $CodexHome "agents\engineer.toml"),
  (Join-Path $CodexHome "agents\reviewer.toml"),
  (Join-Path $CodexHome "agents\tester.toml"),
  (Join-Path $CodexHome "agents\docs.toml"),
  (Join-Path $UserSkillsHome "subagent-orchestration\SKILL.md")
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
