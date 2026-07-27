#!/usr/bin/env bash
set -euo pipefail

# MARK: Submodule-backed skill assets
# Dotter recurses into directory entries, so a submodule mapped in global.toml
# would have its .git internals symlinked file by file. Link the directory here
# instead, and make sure the submodule is checked out first.

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

link_dir() {
  local rel="$1" dest="$2"
  local src="$repo_root/$rel"

  if [ ! -e "$src/index.rst" ]; then
    git -C "$repo_root" submodule update --init -- "$rel" ||
      {
        echo "post_deploy: could not init submodule $rel" >&2
        return 0
      }
  fi

  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$src" ] && return 0
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "post_deploy: $dest exists and is not a symlink; leaving it alone" >&2
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
}

link_dir \
  "claude/skills/diataxis/diataxis-documentation-framework" \
  "$HOME/.claude/skills/diataxis/diataxis-documentation-framework"
