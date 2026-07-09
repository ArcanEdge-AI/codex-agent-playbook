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

append_section_if_missing() {
  local target="$1"
  local title="$2"
  local body="$3"
  local marker="codex-agent-playbook"

  run mkdir -p "$(dirname "$target")"

  if [[ -f "$target" ]] && grep -q "$marker" "$target"; then
    say "Codex Agent Playbook section already present in $target; leaving it unchanged."
    return
  fi

  backup_file "$target"

  if [[ "$DRY_RUN" == "1" ]]; then
    say "[dry-run] Would append $title to $target"
    return
  fi

  {
    if [[ -f "$target" ]]; then
      printf '\n\n'
    fi
    printf '<!-- codex-agent-playbook:start -->\n'
    printf '# %s\n\n' "$title"
    printf '%s\n' "$body"
    printf '<!-- codex-agent-playbook:end -->\n'
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
    append_section_if_missing "$TARGET_AGENTS_MD" "Codex Agent Playbook Global Instructions" "$BODY"
  else
    copy_file "$GLOBAL_INSTRUCTIONS" "$TARGET_AGENTS_MD"
  fi
else
  POINTER_BODY='The primary global coding-agent behavior may be configured in Codex Personalization > Custom instructions or in this AGENTS.md file.

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

Reference documents are supporting context, not automatic truth. The main agent remains accountable for the final plan, final diff, validation, and final response.'
  append_section_if_missing "$TARGET_AGENTS_MD" "Global Reference Documents and Subagent Support" "$POINTER_BODY"
fi

copy_tree "$REFERENCES_DIR" "$CODEX_HOME/references"
copy_tree "$AGENTS_DIR" "$CODEX_HOME/agents"
copy_tree "$SKILLS_DIR" "$USER_SKILLS_HOME"

say ""
say "Validation:"
[[ "$DRY_RUN" == "1" ]] && say "Dry run only; validation checks are informational."

for path in \
  "$TARGET_AGENTS_MD" \
  "$CODEX_HOME/references/subagents.md" \
  "$CODEX_HOME/references/reference-doc-routing.md" \
  "$CODEX_HOME/agents/planner.toml" \
  "$CODEX_HOME/agents/engineer.toml" \
  "$CODEX_HOME/agents/reviewer.toml" \
  "$CODEX_HOME/agents/tester.toml" \
  "$CODEX_HOME/agents/docs.toml" \
  "$USER_SKILLS_HOME/subagent-orchestration/SKILL.md"; do
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
