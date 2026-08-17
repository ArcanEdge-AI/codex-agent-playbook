param(
  [switch]$Full,
  [switch]$SupportOnly,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if ($Full -and $SupportOnly) {
  throw "Choose either -Full or -SupportOnly, not both. Full mode is the default for installs and updates."
}

$Mode = "full"
if ($SupportOnly) { $Mode = "support-only" }
if ($Full) { $Mode = "full" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$UserSkillsHome = if ($env:USER_SKILLS_HOME) { $env:USER_SKILLS_HOME } else { Join-Path $HOME ".agents\skills" }
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
$ManifestPath = Join-Path $CodexHome ".coding-agent-playbook-codex-managed-files.tsv"
$LegacyManifestPath = Join-Path $CodexHome ".codex-agent-playbook-managed-files.tsv"

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

function Get-FileSha256 {
  param([string]$Path)
  return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
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
  if (Test-Path -LiteralPath $Destination -PathType Leaf) {
    if ((Get-FileSha256 $Source) -eq (Get-FileSha256 $Destination)) {
      Write-Step "Unchanged $Destination"
      return
    }
  }

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

function Assert-SafeManifestRelativePath {
  param([string]$RelativePath)

  if ([string]::IsNullOrWhiteSpace($RelativePath) -or
      [System.IO.Path]::IsPathRooted($RelativePath) -or
      $RelativePath.Contains("`t") -or
      $RelativePath.Contains("`r") -or
      $RelativePath.Contains("`n")) {
    throw "Unsafe managed-file manifest path: '$RelativePath'"
  }

  $Segments = $RelativePath -split '[/\\]'
  if ($Segments | Where-Object { $_ -in @('', '.', '..') }) {
    throw "Unsafe managed-file manifest path: '$RelativePath'"
  }
}

function Get-ManagedDestination {
  param([System.Collections.IDictionary]$ManagedRoots, [string]$RootName, [string]$RelativePath)

  if (-not $ManagedRoots.Contains($RootName)) {
    throw "Unknown managed-file root '$RootName'."
  }

  Assert-SafeManifestRelativePath $RelativePath
  $DestinationRoot = [System.IO.Path]::GetFullPath($ManagedRoots[$RootName].Destination)
  $NativeRelativePath = $RelativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar
  $Destination = [System.IO.Path]::GetFullPath((Join-Path $DestinationRoot $NativeRelativePath))
  $RootPrefix = $DestinationRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar

  if (-not $Destination.StartsWith($RootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Managed-file destination escapes '$DestinationRoot': '$RelativePath'"
  }

  return $Destination
}

function Get-CurrentManifestEntries {
  param([System.Collections.IDictionary]$ManagedRoots)

  $Entries = @()
  foreach ($RootName in $ManagedRoots.Keys) {
    $SourceRoot = (Resolve-Path -LiteralPath $ManagedRoots[$RootName].Source).Path
    foreach ($File in Get-ChildItem -LiteralPath $SourceRoot -Recurse -File) {
      $RelativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\', '/') -replace '\\', '/'
      Assert-SafeManifestRelativePath $RelativePath
      $Entries += [pscustomobject]@{
        Root = $RootName
        Path = $RelativePath
        Hash = Get-FileSha256 $File.FullName
      }
    }
  }

  return @($Entries | Sort-Object Root, Path)
}

function Read-InstallManifest {
  param([string]$Path, [System.Collections.IDictionary]$ManagedRoots)

  $Entries = @{}
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    Write-Step "No previous managed-file manifest found; existing unlisted files will be preserved."
    return $Entries
  }

  $LineNumber = 0
  foreach ($Line in Get-Content -LiteralPath $Path) {
    $LineNumber++
    if ([string]::IsNullOrWhiteSpace($Line) -or $Line.StartsWith('#')) {
      continue
    }

    $Parts = $Line -split "`t"
    if ($Parts.Count -ne 3) {
      throw "Malformed managed-file manifest at ${Path}:$LineNumber"
    }

    $RootName, $RelativePath, $Hash = $Parts
    if (-not $ManagedRoots.Contains($RootName)) {
      throw "Unknown managed-file root '$RootName' at ${Path}:$LineNumber"
    }
    Assert-SafeManifestRelativePath $RelativePath
    if ($Hash -notmatch '^[a-fA-F0-9]{64}$') {
      throw "Invalid SHA-256 at ${Path}:$LineNumber"
    }

    $Key = "$RootName/$RelativePath"
    if ($Entries.ContainsKey($Key)) {
      throw "Duplicate managed-file manifest entry '$Key' at ${Path}:$LineNumber"
    }

    $Entries[$Key] = [pscustomobject]@{
      Root = $RootName
      Path = $RelativePath
      Hash = $Hash.ToLowerInvariant()
    }
  }

  return $Entries
}

function Assert-ManagedFilesMatch {
  param([array]$Entries, [System.Collections.IDictionary]$ManagedRoots)

  if ($DryRun) {
    Write-Step "[dry-run] Would verify $($Entries.Count) managed files against repository SHA-256 hashes."
    return
  }

  foreach ($Entry in $Entries) {
    $Destination = Get-ManagedDestination $ManagedRoots $Entry.Root $Entry.Path
    if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
      throw "Managed file was not installed: $Destination"
    }
    if ((Get-FileSha256 $Destination) -ne $Entry.Hash) {
      throw "Managed file does not match the repository source: $Destination"
    }
  }

  Write-Step "OK managed-file content: $($Entries.Count)/$($Entries.Count) exact SHA-256 matches"
}

function Retire-StaleManagedFiles {
  param([hashtable]$PreviousEntries, [array]$CurrentEntries, [System.Collections.IDictionary]$ManagedRoots)

  $CurrentKeys = @{}
  foreach ($Entry in $CurrentEntries) {
    $CurrentKeys["$($Entry.Root)/$($Entry.Path)"] = $true
  }

  foreach ($Key in @($PreviousEntries.Keys | Sort-Object)) {
    if ($CurrentKeys.ContainsKey($Key)) {
      continue
    }

    $Entry = $PreviousEntries[$Key]
    $Destination = Get-ManagedDestination $ManagedRoots $Entry.Root $Entry.Path
    if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
      Write-Step "Formerly managed file already absent: $Destination"
      continue
    }

    if ((Get-FileSha256 $Destination) -ne $Entry.Hash) {
      Write-Warning "Preserving customized formerly managed file: $Destination"
      continue
    }

    Backup-File $Destination
    Write-Step "Retiring formerly managed file: $Destination"
    Invoke-InstallCommand { Remove-Item -LiteralPath $Destination -Force } "Remove-Item '$Destination'"
  }
}

function Write-InstallManifest {
  param([array]$Entries, [string]$Path)

  $Lines = @('# coding-agent-playbook-codex managed files v1')
  foreach ($Entry in $Entries) {
    $Lines += "$($Entry.Root)`t$($Entry.Path)`t$($Entry.Hash)"
  }
  $Content = ($Lines -join "`n") + "`n"

  if (Test-Path -LiteralPath $Path -PathType Leaf) {
    $Existing = (Get-Content -LiteralPath $Path -Raw) -replace "`r`n", "`n"
    if ($Existing -eq $Content) {
      Write-Step "Unchanged $Path"
      return
    }
  }

  $Parent = Split-Path -Parent $Path
  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"
  Backup-File $Path
  Write-Step "Writing managed-file manifest: $Path"
  if ($DryRun) {
    Write-Step "[dry-run] Would write $($Entries.Count) managed-file entries."
  } else {
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
  }
}

function Retire-LegacyManifest {
  param([string]$LegacyPath)

  if (-not (Test-Path -LiteralPath $LegacyPath -PathType Leaf)) {
    return
  }

  Backup-File $LegacyPath
  Write-Step "Retiring legacy managed-file manifest: $LegacyPath"
  Invoke-InstallCommand { Remove-Item -LiteralPath $LegacyPath -Force } "Remove-Item '$LegacyPath'"
}

function AddOrReplace-PlaybookSection {
  param([string]$Target, [string]$Title, [string]$Body)

  $StartMarker = "<!-- coding-agent-playbook-codex:start -->"
  $EndMarker = "<!-- coding-agent-playbook-codex:end -->"
  $LegacyStartMarker = "<!-- codex-agent-playbook:start -->"
  $LegacyEndMarker = "<!-- codex-agent-playbook:end -->"
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
    $CurrentStartIndex = $Existing.IndexOf($StartMarker, [System.StringComparison]::Ordinal)
    $CurrentEndIndex = $Existing.IndexOf($EndMarker, [System.StringComparison]::Ordinal)
    $LegacyStartIndex = $Existing.IndexOf($LegacyStartMarker, [System.StringComparison]::Ordinal)
    $LegacyEndIndex = $Existing.IndexOf($LegacyEndMarker, [System.StringComparison]::Ordinal)
    $HasAnyMarker = $CurrentStartIndex -ge 0 -or $CurrentEndIndex -ge 0 -or $LegacyStartIndex -ge 0 -or $LegacyEndIndex -ge 0

    if ($HasAnyMarker) {
      $CurrentPairValid = $CurrentStartIndex -ge 0 -and $CurrentEndIndex -gt $CurrentStartIndex -and
        $Existing.IndexOf($StartMarker, $CurrentStartIndex + $StartMarker.Length, [System.StringComparison]::Ordinal) -lt 0 -and
        $Existing.IndexOf($EndMarker, $CurrentEndIndex + $EndMarker.Length, [System.StringComparison]::Ordinal) -lt 0
      $LegacyPairValid = $LegacyStartIndex -ge 0 -and $LegacyEndIndex -gt $LegacyStartIndex -and
        $Existing.IndexOf($LegacyStartMarker, $LegacyStartIndex + $LegacyStartMarker.Length, [System.StringComparison]::Ordinal) -lt 0 -and
        $Existing.IndexOf($LegacyEndMarker, $LegacyEndIndex + $LegacyEndMarker.Length, [System.StringComparison]::Ordinal) -lt 0
      $CurrentPairAbsent = $CurrentStartIndex -lt 0 -and $CurrentEndIndex -lt 0
      $LegacyPairAbsent = $LegacyStartIndex -lt 0 -and $LegacyEndIndex -lt 0

      if ((-not $CurrentPairValid -and -not $CurrentPairAbsent) -or
          (-not $LegacyPairValid -and -not $LegacyPairAbsent) -or
          ($CurrentPairValid -and $LegacyPairValid)) {
        throw "Malformed Coding Agent Playbook — Codex Edition markers in $Target; no changes were made."
      }

      if ($CurrentPairValid) {
        $ActiveStartIndex = $CurrentStartIndex
        $ActiveEndIndex = $CurrentEndIndex
        $ActiveEndMarker = $EndMarker
      } else {
        $ActiveStartIndex = $LegacyStartIndex
        $ActiveEndIndex = $LegacyEndIndex
        $ActiveEndMarker = $LegacyEndMarker
        Write-Step "Migrating legacy Coding Agent Playbook markers in $Target"
      }

      $Updated = $Existing.Substring(0, $ActiveStartIndex) + $Section + $Existing.Substring($ActiveEndIndex + $ActiveEndMarker.Length)
      if ($Updated -eq $Existing) {
        Write-Step "Unchanged $Target"
        return
      }

      Backup-File $Target
      if ($DryRun) {
        Write-Step "[dry-run] Would replace the Coding Agent Playbook — Codex Edition section in $Target"
      } else {
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
      Set-Content -LiteralPath $Target -Value $Section -Encoding UTF8 -NoNewline
    }
  }
}

$GlobalInstructions = Join-Path $RepoRoot "custom-instructions\global-coding-agent-instructions.md"
$ReferencesDir = Join-Path $RepoRoot "references"
$AgentsDir = Join-Path $RepoRoot "agents"
$SkillsDir = Join-Path $RepoRoot "skills"
$TargetAgentsMd = Join-Path $CodexHome "AGENTS.md"
$ManagedRoots = [ordered]@{
  references = @{ Source = $ReferencesDir; Destination = (Join-Path $CodexHome "references") }
  agents = @{ Source = $AgentsDir; Destination = (Join-Path $CodexHome "agents") }
  skills = @{ Source = $SkillsDir; Destination = $UserSkillsHome }
}

Write-Step "Coding Agent Playbook — Codex Edition installer"
Write-Step "Mode: $Mode"
Write-Step "Repository: $RepoRoot"
Write-Step "CODEX_HOME: $CodexHome"
Write-Step "USER_SKILLS_HOME: $UserSkillsHome"
Write-Step "Managed-file manifest: $ManifestPath"

if (-not (Test-Path -LiteralPath $GlobalInstructions -PathType Leaf)) {
  throw "Missing global instructions: $GlobalInstructions"
}

$CurrentManifestEntries = Get-CurrentManifestEntries $ManagedRoots
$PreviousManifestPath = if (Test-Path -LiteralPath $ManifestPath -PathType Leaf) { $ManifestPath } elseif (Test-Path -LiteralPath $LegacyManifestPath -PathType Leaf) { $LegacyManifestPath } else { $ManifestPath }
if ($PreviousManifestPath -eq $LegacyManifestPath) {
  Write-Step "Migrating legacy managed-file manifest: $LegacyManifestPath"
}
$PreviousManifestEntries = Read-InstallManifest $PreviousManifestPath $ManagedRoots

if (Test-Path -LiteralPath (Join-Path $CodexHome "AGENTS.override.md") -PathType Leaf) {
  Write-Step "Notice: AGENTS.override.md exists and may override AGENTS.md"
}

if ($Mode -eq "full") {
  $Body = Get-Content -LiteralPath $GlobalInstructions -Raw
  AddOrReplace-PlaybookSection $TargetAgentsMd "Coding Agent Playbook — Codex Edition Global Instructions" $Body
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

Copy-PlaybookTree $ReferencesDir $ManagedRoots['references'].Destination
Copy-PlaybookTree $AgentsDir $ManagedRoots['agents'].Destination
Copy-PlaybookTree $SkillsDir $ManagedRoots['skills'].Destination
Assert-ManagedFilesMatch $CurrentManifestEntries $ManagedRoots
Retire-StaleManagedFiles $PreviousManifestEntries $CurrentManifestEntries $ManagedRoots
Write-InstallManifest $CurrentManifestEntries $ManifestPath
Retire-LegacyManifest $LegacyManifestPath

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
