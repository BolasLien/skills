#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *)
      echo "unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

TARGET_BASES=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.gemini/skills"
)

if [ ! -d "$SKILLS_DIR" ]; then
  echo "error: $SKILLS_DIR not found" >&2
  exit 1
fi

for skill_path in "$SKILLS_DIR"/*/; do
  name="$(basename "$skill_path")"
  desired_target="$SKILLS_DIR/$name"

  for base in "${TARGET_BASES[@]}"; do
    [ -d "$base" ] || continue
    link_path="$base/$name"

    if [ -L "$link_path" ]; then
      current_target="$(readlink "$link_path")"
      if [ "$current_target" = "$desired_target" ]; then
        echo "ok         $link_path"
      else
        echo "conflict   $link_path -> $current_target (expected $desired_target)"
      fi
    elif [ -e "$link_path" ]; then
      echo "conflict   $link_path (existing real file/dir, not a symlink)"
    elif [ "$DRY_RUN" -eq 1 ]; then
      echo "would-link $link_path -> $desired_target"
    else
      ln -s "$desired_target" "$link_path"
      echo "linked     $link_path -> $desired_target"
    fi
  done
done
