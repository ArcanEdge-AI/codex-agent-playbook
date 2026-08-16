#!/usr/bin/env bash
set -euo pipefail

MODE="full"
DRY_RUN="0"

for arg in "$@"; do
  case "$arg" in
    --full)
      MODE="full"
      ;;
    --support-only)
      MODE="support-only"
      ;;
    --dry-run)
      DRY_RUN="1"
      ;;
    -h|--help)
      cat <<'HELP'
Usage: bash install/install.sh [--full|--support-only] [--dry-run]

--full          Install global instructions plus references, skills, and custom agents.
--support-only  Install references, skills, and custom agents; add only a pointer to AGENTS.md.
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
USER_SKILLS_HOME="${USER_SKILLS_HOME:-$HOME/.agents/skills}"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

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

add_or_replace_playbook_section() {
  local target="$1"
  local title="$2"
  local body="$3"
  local start_marker='<!-- codex-agent-playbook:start -->'
  local end_marker='<!-- codex-agent-playbook:end -->'

  if [[ -f "$target" ]]; then
    local start_count end_count start_line end_line marker_line_ending newline section temp
    read -r start_count end_count start_line end_line marker_line_ending < <(
      awk -v start="$start_marker" -v end="$end_marker" '
        {
          line = $0
          has_cr = sub(/\r$/, "", line)
          if (line == start) {
            start_count++
            if (start_line == 0) {
              start_line = NR
              marker_line_ending = has_cr ? "crlf" : "lf"
            }
          }
          if (line == end) {
            end_count++
            if (end_line == 0) {
              end_line = NR
            }
          }
        }
        END { print start_count + 0, end_count + 0, start_line + 0, end_line + 0, marker_line_ending }
      ' "$target"
    )

    if [[ "$start_count" != "0" || "$end_count" != "0" ]]; then
      if [[ "$start_count" != "1" || "$end_count" != "1" ]]; then
        say "Malformed Codex Agent Playbook markers in $target; no changes were made." >&2
        return 1
      fi

      if (( end_line <= start_line )); then
        say "Malformed Codex Agent Playbook markers in $target; no changes were made." >&2
        return 1
      fi

      backup_file "$target"
      if [[ "$DRY_RUN" == "1" ]]; then
        say "[dry-run] Would replace the Codex Agent Playbook section in $target"
        return
      fi

      newline=$'\n'
      if [[ "$marker_line_ending" == "crlf" ]]; then
        newline=$'\r\n'
        body="${body//$'\r\n'/$'\n'}"
        body="${body//$'\n'/$'\r\n'}"
      fi
      section="$start_marker$newline# $title$newline$newline$body$newline$end_marker$newline"
      temp="$(mktemp "${target}.codex-agent-playbook.XXXXXX")"
      awk -v start="$start_marker" -v end="$end_marker" -v section="$section" '
        {
          line = $0
          sub(/\r$/, "", line)
        }
        line == start { printf "%s", section; in_section = 1; next }
        line == end { in_section = 0; next }
        !in_section { print }
      ' "$target" > "$temp"
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

say "Codex Agent Playbook installer"
say "Mode: $MODE"
say "Repository: $REPO_ROOT"
say "CODEX_HOME: $CODEX_HOME"
say "USER_SKILLS_HOME: $USER_SKILLS_HOME"

if [[ ! -f "$GLOBAL_INSTRUCTIONS" ]]; then
  say "Missing global instructions: $GLOBAL_INSTRUCTIONS" >&2
  exit 1
fi

if [[ "$MODE" == "full" ]]; then
  if [[ -f "$TARGET_AGENTS_MD" ]]; then
    BODY="$(cat "$GLOBAL_INSTRUCTIONS")"
    add_or_replace_playbook_section "$TARGET_AGENTS_MD" "Codex Agent Playbook Global Instructions" "$BODY"
  else
    copy_file "$GLOBAL_INSTRUCTIONS" "$TARGET_AGENTS_MD"
  fi
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

Reference documents are supporting context, not automatic truth. For every repository task when subagents are available, the main agent delegates actual execution to at least one bounded subagent; it remains accountable for orchestration, final diff, validation, acceptance, and final response. Direct main-agent execution is limited to unavailable subagents, an explicit user prohibition, or a specific authority-bound action that cannot be delegated; record the exact exception.

The root owns a finite manifest, total spawned-node budget, and child-specific permits. Every dispatched child must already be a finite-manifest member, fit the remaining total node budget, hold its required root permit, and fit runtime, safety, and ownership capacity. Expand the manifest or budget only for a newly discovered dependency, invalidated gate, or changed user scope; a material expansion also needs immediate user approval. Profiles are callable only when the host supports custom-agent invocation, including an `@tag` interface if offered, and are depth 1. A root-permitted depth-1 local orchestrator may create declared depth-2 leaves. Depth 2 executes directly and cannot spawn. For each child, model and reasoning effort must be at or below the explicit ceiling of its parent; descendants cannot upgrade and must stop and report if insufficient. When capacity is full, do not queue speculative descendants.

The auxiliary-worktree budget starts at zero and is separate from the node budget. Worktrees are not created per agent. Only root may issue a worktree permit or create, adopt, repurpose, move, or remove an auxiliary worktree. Root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Descendants use their exact assigned workspace and report isolation needs upward. Before the final response, root removes each task-created auxiliary under verified safety gates or preserves it with an exact owner, path, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation. A host-managed active workspace follows the supported host lifecycle.'
  add_or_replace_playbook_section "$TARGET_AGENTS_MD" "Global Reference Documents and Subagent Support" "$POINTER_BODY"
fi

copy_tree "$REFERENCES_DIR" "$CODEX_HOME/references"
copy_tree "$AGENTS_DIR" "$CODEX_HOME/agents"
copy_tree "$SKILLS_DIR" "$USER_SKILLS_HOME"

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
