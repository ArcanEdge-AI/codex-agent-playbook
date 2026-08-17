#!/usr/bin/env bash
set -euo pipefail

MODE="full"
FULL_REQUESTED="0"
SUPPORT_ONLY_REQUESTED="0"
DRY_RUN="0"

for arg in "$@"; do
  case "$arg" in
    --full)
      FULL_REQUESTED="1"
      ;;
    --support-only)
      SUPPORT_ONLY_REQUESTED="1"
      ;;
    --dry-run)
      DRY_RUN="1"
      ;;
    -h|--help)
      cat <<'HELP'
Usage: bash install/install.sh [--full|--support-only] [--dry-run]

--full          Install or update global instructions, references, skills, and custom agents. This is the default.
--support-only  Explicit pointer-only mode for users whose global instructions live in Codex Personalization.
--dry-run       Print actions without writing files.
HELP
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ "$FULL_REQUESTED" == "1" && "$SUPPORT_ONLY_REQUESTED" == "1" ]]; then
  echo "Choose either --full or --support-only, not both. Full mode is the default for installs and updates." >&2
  exit 1
fi

if [[ "$SUPPORT_ONLY_REQUESTED" == "1" ]]; then
  MODE="support-only"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
USER_SKILLS_HOME="${USER_SKILLS_HOME:-$HOME/.agents/skills}"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
MANIFEST_PATH="$CODEX_HOME/.coding-agent-playbook-codex-managed-files.tsv"
LEGACY_MANIFEST_PATH="$CODEX_HOME/.codex-agent-playbook-managed-files.tsv"

say() {
  printf '%s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

sha256_file() {
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{ print tolower($1) }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{ print tolower($1) }'
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$path" | awk '{ print tolower($NF) }'
  else
    say "No SHA-256 tool is available; install sha256sum, shasum, or openssl." >&2
    return 1
  fi
}

backup_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    local backup="$path.bak.$TIMESTAMP"
    say "Backing up $path -> $backup"
    run cp -p "$path" "$backup"
  fi
}

copy_file() {
  local src="$1"
  local dest="$2"
  run mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    say "Unchanged $dest"
    return
  fi
  backup_file "$dest"
  say "Installing $dest"
  run cp "$src" "$dest"
}

copy_tree() {
  local src_dir="$1"
  local dest_dir="$2"
  if [[ ! -d "$src_dir" ]]; then
    say "Skipping missing source directory: $src_dir"
    return
  fi

  while IFS= read -r -d '' src; do
    local rel="${src#$src_dir/}"
    local dest="$dest_dir/$rel"
    copy_file "$src" "$dest"
  done < <(find "$src_dir" -type f -print0)
}

validate_manifest_relative_path() {
  local rel="$1"
  if [[ -z "$rel" || "$rel" == /* || "$rel" == *$'\t'* || "$rel" == *$'\r'* || "$rel" == *$'\n'* ]]; then
    say "Unsafe managed-file manifest path: '$rel'" >&2
    return 1
  fi

  case "/$rel/" in
    *'/../'*|*'/./'*|*'//'*)
      say "Unsafe managed-file manifest path: '$rel'" >&2
      return 1
      ;;
  esac
}

destination_for_manifest_entry() {
  local root="$1"
  local rel="$2"
  validate_manifest_relative_path "$rel"

  case "$root" in
    references) printf '%s\n' "$CODEX_HOME/references/$rel" ;;
    agents) printf '%s\n' "$CODEX_HOME/agents/$rel" ;;
    skills) printf '%s\n' "$USER_SKILLS_HOME/$rel" ;;
    *)
      say "Unknown managed-file root '$root'." >&2
      return 1
      ;;
  esac
}

build_current_manifest() {
  local output="$1"
  local root src_dir src rel hash

  printf '# coding-agent-playbook-codex managed files v1\n' > "$output"
  for root in references agents skills; do
    case "$root" in
      references) src_dir="$REFERENCES_DIR" ;;
      agents) src_dir="$AGENTS_DIR" ;;
      skills) src_dir="$SKILLS_DIR" ;;
    esac

    while IFS= read -r src; do
      rel="${src#$src_dir/}"
      validate_manifest_relative_path "$rel"
      hash="$(sha256_file "$src")"
      printf '%s\t%s\t%s\n' "$root" "$rel" "$hash" >> "$output"
    done < <(find "$src_dir" -type f -print | LC_ALL=C sort)
  done
}

validate_install_manifest() {
  local path="$1"
  [[ -f "$path" ]] || {
    say "No previous managed-file manifest found; existing unlisted files will be preserved."
    return
  }

  local duplicates
  duplicates="$(awk -F '\t' '!/^#/ && NF == 3 { print $1 "\t" $2 }' "$path" | LC_ALL=C sort | uniq -d)"
  if [[ -n "$duplicates" ]]; then
    say "Duplicate entries in managed-file manifest $path:" >&2
    say "$duplicates" >&2
    return 1
  fi

  local line_number=0 root rel hash extra
  while IFS=$'\t' read -r root rel hash extra || [[ -n "$root$rel$hash$extra" ]]; do
    line_number=$((line_number + 1))
    [[ -z "$root" || "$root" == \#* ]] && continue

    if [[ -n "$extra" || -z "$rel" || -z "$hash" ]]; then
      say "Malformed managed-file manifest at $path:$line_number" >&2
      return 1
    fi
    case "$root" in
      references|agents|skills) ;;
      *)
        say "Unknown managed-file root '$root' at $path:$line_number" >&2
        return 1
        ;;
    esac
    validate_manifest_relative_path "$rel"
    if [[ ! "$hash" =~ ^[a-fA-F0-9]{64}$ ]]; then
      say "Invalid SHA-256 at $path:$line_number" >&2
      return 1
    fi
  done < "$path"
}

manifest_contains_key() {
  local path="$1"
  local root="$2"
  local rel="$3"
  awk -F '\t' -v root="$root" -v rel="$rel" '
    $1 == root && $2 == rel { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$path"
}

verify_managed_files() {
  local current_manifest="$1"
  local count
  count="$(awk -F '\t' '!/^#/ && NF == 3 { count++ } END { print count + 0 }' "$current_manifest")"

  if [[ "$DRY_RUN" == "1" ]]; then
    say "[dry-run] Would verify $count managed files against repository SHA-256 hashes."
    return
  fi

  local root rel expected_hash extra destination actual_hash
  while IFS=$'\t' read -r root rel expected_hash extra || [[ -n "$root$rel$expected_hash$extra" ]]; do
    [[ -z "$root" || "$root" == \#* ]] && continue
    destination="$(destination_for_manifest_entry "$root" "$rel")"
    if [[ ! -f "$destination" ]]; then
      say "Managed file was not installed: $destination" >&2
      return 1
    fi
    actual_hash="$(sha256_file "$destination")"
    if [[ "$actual_hash" != "$expected_hash" ]]; then
      say "Managed file does not match the repository source: $destination" >&2
      return 1
    fi
  done < "$current_manifest"

  say "OK managed-file content: $count/$count exact SHA-256 matches"
}

retire_stale_managed_files() {
  local previous_manifest="$1"
  local current_manifest="$2"
  [[ -f "$previous_manifest" ]] || return 0

  local root rel expected_hash extra destination actual_hash
  while IFS=$'\t' read -r root rel expected_hash extra || [[ -n "$root$rel$expected_hash$extra" ]]; do
    [[ -z "$root" || "$root" == \#* ]] && continue
    if manifest_contains_key "$current_manifest" "$root" "$rel"; then
      continue
    fi

    destination="$(destination_for_manifest_entry "$root" "$rel")"
    if [[ ! -f "$destination" ]]; then
      say "Formerly managed file already absent: $destination"
      continue
    fi

    actual_hash="$(sha256_file "$destination")"
    expected_hash="$(printf '%s' "$expected_hash" | tr '[:upper:]' '[:lower:]')"
    if [[ "$actual_hash" != "$expected_hash" ]]; then
      say "Preserving customized formerly managed file: $destination" >&2
      continue
    fi

    backup_file "$destination"
    say "Retiring formerly managed file: $destination"
    run rm -f -- "$destination"
  done < "$previous_manifest"
}

write_install_manifest() {
  local current_manifest="$1"
  local destination="$2"

  if [[ -f "$destination" ]] && cmp -s "$current_manifest" "$destination"; then
    say "Unchanged $destination"
    return
  fi

  run mkdir -p "$(dirname "$destination")"
  backup_file "$destination"
  say "Writing managed-file manifest: $destination"
  run cp "$current_manifest" "$destination"
}

retire_legacy_manifest() {
  local legacy_path="$1"
  [[ -f "$legacy_path" ]] || return 0

  backup_file "$legacy_path"
  say "Retiring legacy managed-file manifest: $legacy_path"
  run rm -f -- "$legacy_path"
}

add_or_replace_playbook_section() {
  local target="$1"
  local title="$2"
  local body="$3"
  local start_marker='<!-- coding-agent-playbook-codex:start -->'
  local end_marker='<!-- coding-agent-playbook-codex:end -->'
  local legacy_start_marker='<!-- codex-agent-playbook:start -->'
  local legacy_end_marker='<!-- codex-agent-playbook:end -->'

  if [[ -f "$target" ]]; then
    local current_start_count current_end_count current_start_line current_end_line current_line_ending
    local legacy_start_count legacy_end_count legacy_start_line legacy_end_line legacy_line_ending
    local current_pair_valid=0 legacy_pair_valid=0
    local active_start_marker active_end_marker marker_line_ending newline section temp
    read -r current_start_count current_end_count current_start_line current_end_line current_line_ending legacy_start_count legacy_end_count legacy_start_line legacy_end_line legacy_line_ending < <(
      awk -v start="$start_marker" -v end="$end_marker" -v legacy_start="$legacy_start_marker" -v legacy_end="$legacy_end_marker" '
        BEGIN {
          current_line_ending = "none"
          legacy_line_ending = "none"
        }
        {
          line = $0
          has_cr = sub(/\r$/, "", line)
          if (line == start) {
            current_start_count++
            if (current_start_line == 0) {
              current_start_line = NR
              current_line_ending = has_cr ? "crlf" : "lf"
            }
          }
          if (line == end) {
            current_end_count++
            if (current_end_line == 0) {
              current_end_line = NR
            }
          }
          if (line == legacy_start) {
            legacy_start_count++
            if (legacy_start_line == 0) {
              legacy_start_line = NR
              legacy_line_ending = has_cr ? "crlf" : "lf"
            }
          }
          if (line == legacy_end) {
            legacy_end_count++
            if (legacy_end_line == 0) {
              legacy_end_line = NR
            }
          }
        }
        END {
          print current_start_count + 0, current_end_count + 0, current_start_line + 0, current_end_line + 0, current_line_ending, \
            legacy_start_count + 0, legacy_end_count + 0, legacy_start_line + 0, legacy_end_line + 0, legacy_line_ending
        }
      ' "$target"
    )

    if (( current_start_count != 0 || current_end_count != 0 || legacy_start_count != 0 || legacy_end_count != 0 )); then
      if (( current_start_count != 0 || current_end_count != 0 )); then
        if (( current_start_count != 1 || current_end_count != 1 || current_end_line <= current_start_line )); then
          say "Malformed Coding Agent Playbook — Codex Edition markers in $target; no changes were made." >&2
          return 1
        fi
        current_pair_valid=1
      fi

      if (( legacy_start_count != 0 || legacy_end_count != 0 )); then
        if (( legacy_start_count != 1 || legacy_end_count != 1 || legacy_end_line <= legacy_start_line )); then
          say "Malformed Coding Agent Playbook — Codex Edition markers in $target; no changes were made." >&2
          return 1
        fi
        legacy_pair_valid=1
      fi

      if (( current_pair_valid == 1 && legacy_pair_valid == 1 )); then
        say "Malformed Coding Agent Playbook — Codex Edition markers in $target; no changes were made." >&2
        return 1
      fi

      if (( current_pair_valid == 1 )); then
        active_start_marker="$start_marker"
        active_end_marker="$end_marker"
        marker_line_ending="$current_line_ending"
      else
        active_start_marker="$legacy_start_marker"
        active_end_marker="$legacy_end_marker"
        marker_line_ending="$legacy_line_ending"
        say "Migrating legacy Coding Agent Playbook markers in $target"
      fi

      newline=$'\n'
      if [[ "$marker_line_ending" == "crlf" ]]; then
        newline=$'\r\n'
        body="${body//$'\r\n'/$'\n'}"
        body="${body//$'\n'/$'\r\n'}"
      fi
      section="$start_marker$newline# $title$newline$newline$body$newline$end_marker$newline"
      temp="$(mktemp "${target}.coding-agent-playbook-codex.XXXXXX")"
      awk -v start="$active_start_marker" -v end="$active_end_marker" -v section="$section" -v newline="$newline" '
        {
          line = $0
          sub(/\r$/, "", line)
        }
        line == start { printf "%s", section; in_section = 1; next }
        line == end { in_section = 0; next }
        !in_section { printf "%s%s", line, newline }
      ' "$target" > "$temp"

      if cmp -s "$temp" "$target"; then
        rm -f "$temp"
        say "Unchanged $target"
        return
      fi

      backup_file "$target"
      if [[ "$DRY_RUN" == "1" ]]; then
        rm -f "$temp"
        say "[dry-run] Would replace the Coding Agent Playbook — Codex Edition section in $target"
        return
      fi

      cat "$temp" > "$target"
      rm -f "$temp"
      return
    fi
  fi

  run mkdir -p "$(dirname "$target")"
  backup_file "$target"

  if [[ "$DRY_RUN" == "1" ]]; then
    say "[dry-run] Would append $title to $target"
    return
  fi

  newline=$'\n'
  if [[ -f "$target" ]] && awk '
    NR == 1 {
      line = $0
      exit sub(/\r$/, "", line) ? 0 : 1
    }
    END { if (NR == 0) exit 1 }
  ' "$target"; then
    newline=$'\r\n'
    body="${body//$'\r\n'/$'\n'}"
    body="${body//$'\n'/$'\r\n'}"
  fi

  {
    if [[ -f "$target" ]]; then
      printf '%s%s' "$newline" "$newline"
    fi
    printf '%s%s' "$start_marker" "$newline"
    printf '# %s%s%s' "$title" "$newline" "$newline"
    printf '%s%s' "$body" "$newline"
    printf '%s%s' "$end_marker" "$newline"
  } >> "$target"
}

GLOBAL_INSTRUCTIONS="$REPO_ROOT/custom-instructions/global-coding-agent-instructions.md"
REFERENCES_DIR="$REPO_ROOT/references"
AGENTS_DIR="$REPO_ROOT/agents"
SKILLS_DIR="$REPO_ROOT/skills"
TARGET_AGENTS_MD="$CODEX_HOME/AGENTS.md"

say "Coding Agent Playbook — Codex Edition installer"
say "Mode: $MODE"
say "Repository: $REPO_ROOT"
say "CODEX_HOME: $CODEX_HOME"
say "USER_SKILLS_HOME: $USER_SKILLS_HOME"
say "Managed-file manifest: $MANIFEST_PATH"

if [[ ! -f "$GLOBAL_INSTRUCTIONS" ]]; then
  say "Missing global instructions: $GLOBAL_INSTRUCTIONS" >&2
  exit 1
fi

CURRENT_MANIFEST="$(mktemp "${TMPDIR:-/tmp}/coding-agent-playbook-codex-manifest.XXXXXX")"
trap 'rm -f "$CURRENT_MANIFEST"' EXIT
build_current_manifest "$CURRENT_MANIFEST"
PREVIOUS_MANIFEST_PATH="$MANIFEST_PATH"
if [[ ! -f "$MANIFEST_PATH" && -f "$LEGACY_MANIFEST_PATH" ]]; then
  PREVIOUS_MANIFEST_PATH="$LEGACY_MANIFEST_PATH"
  say "Migrating legacy managed-file manifest: $LEGACY_MANIFEST_PATH"
fi
validate_install_manifest "$PREVIOUS_MANIFEST_PATH"

if [[ "$MODE" == "full" ]]; then
  BODY="$(cat "$GLOBAL_INSTRUCTIONS")"
  add_or_replace_playbook_section "$TARGET_AGENTS_MD" "Coding Agent Playbook — Codex Edition Global Instructions" "$BODY"
else
  POINTER_BODY='The primary global coding-agent behavior may be configured in Codex Personalization > Custom instructions or in this AGENTS.md file.

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

The auxiliary-worktree budget starts at zero and is separate from the node budget. Worktrees are not created per agent. Only root may issue a worktree permit or create, adopt, repurpose, move, or remove an auxiliary worktree. Root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Descendants use their exact assigned workspace and report isolation needs upward. Before the final response, root removes each task-created auxiliary under verified safety gates or preserves it with an exact owner, path, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation. A host-managed active workspace follows the supported host lifecycle.'
  add_or_replace_playbook_section "$TARGET_AGENTS_MD" "Global Reference Documents and Subagent Support" "$POINTER_BODY"
fi

copy_tree "$REFERENCES_DIR" "$CODEX_HOME/references"
copy_tree "$AGENTS_DIR" "$CODEX_HOME/agents"
copy_tree "$SKILLS_DIR" "$USER_SKILLS_HOME"
verify_managed_files "$CURRENT_MANIFEST"
retire_stale_managed_files "$PREVIOUS_MANIFEST_PATH" "$CURRENT_MANIFEST"
write_install_manifest "$CURRENT_MANIFEST" "$MANIFEST_PATH"
retire_legacy_manifest "$LEGACY_MANIFEST_PATH"

say ""
say "Validation:"
[[ "$DRY_RUN" == "1" ]] && say "Dry run only; validation checks are informational."

for path in \
  "$TARGET_AGENTS_MD" \
  "$CODEX_HOME/references/model-routing.md" \
  "$CODEX_HOME/references/subagents.md" \
  "$CODEX_HOME/references/worktrees.md" \
  "$CODEX_HOME/references/multi-session-coordination.md" \
  "$CODEX_HOME/references/reference-doc-routing.md" \
  "$CODEX_HOME/references/templates/active-work-record.md" \
  "$CODEX_HOME/references/templates/task-graph.md" \
  "$CODEX_HOME/references/templates/worktree-manifest.md" \
  "$CODEX_HOME/agents/planner.toml" \
  "$CODEX_HOME/agents/engineer.toml" \
  "$CODEX_HOME/agents/reviewer.toml" \
  "$CODEX_HOME/agents/tester.toml" \
  "$CODEX_HOME/agents/docs.toml" \
  "$CODEX_HOME/agents/planner-luna.toml" \
  "$CODEX_HOME/agents/engineer-luna.toml" \
  "$CODEX_HOME/agents/reviewer-luna.toml" \
  "$CODEX_HOME/agents/tester-luna.toml" \
  "$CODEX_HOME/agents/docs-luna.toml" \
  "$USER_SKILLS_HOME/subagent-orchestration/SKILL.md" \
  "$USER_SKILLS_HOME/task-graph-orchestration/SKILL.md" \
  "$USER_SKILLS_HOME/worktree-lifecycle/SKILL.md" \
  "$USER_SKILLS_HOME/multi-session-coordination/SKILL.md"; do
  if [[ -e "$path" || "$DRY_RUN" == "1" ]]; then
    say "OK: $path"
  else
    say "Missing: $path" >&2
  fi
done

for skill in "$USER_SKILLS_HOME"/*/SKILL.md; do
  [[ -f "$skill" ]] || continue
  if grep -q '^name:' "$skill" && grep -q '^description:' "$skill"; then
    say "OK frontmatter: $skill"
  else
    say "Check frontmatter: $skill" >&2
  fi
done

say ""
say "Install complete. Restart Codex or start a new session if needed so new instructions, skills, and agents are loaded."
