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

link_submodule_dir() {
  local rel="$1" dest="$2"

  if [ ! -e "$repo_root/$rel/index.rst" ]; then
    git -C "$repo_root" submodule update --init -- "$rel" ||
      {
        echo "post_deploy: could not init submodule $rel" >&2
        return 0
      }
  fi

  link_dir "$rel" "$dest"
}

link_submodule_dir \
  "claude/skills/diataxis/diataxis-documentation-framework" \
  "$HOME/.claude/skills/diataxis/diataxis-documentation-framework"

# MARK: Neovim configuration
# Neovim writes lazy-lock.json and lazyvim.json into its own config directory, and
# new plugin files accumulate there. Dotter's per-file recursion would leave those
# writes outside the repository, so link the directory whole.

link_dir "nvim" "$HOME/.config/nvim"

# MARK: macOS gpg-agent LaunchAgent
# Registers the LaunchAgent deployed by the `gpg` package, and retires Apple's
# ssh-agent job. The latter matters because it declares its socket with
# SecureSocketWithKey, so launchd stamps SSH_AUTH_SOCK across the whole login
# session and races whatever gpg-agent publishes. Keychain-backed ssh keys go
# away with it; gpg-agent holds the keys here instead.
#
# Only `disable` is used: SIP forbids booting out a system LaunchAgent, so the
# already-running instance survives until the next login. That is harmless —
# the LaunchAgent's own `launchctl setenv` takes precedence in the meantime.

bootstrap_gpg_agent() {
  local plist domain
  plist="$HOME/Library/LaunchAgents/me.jpellis.gpg-agent.plist"
  domain="gui/$(id -u)"

  [ "$(uname -s)" = "Darwin" ] || return 0
  if [ ! -f "$plist" ]; then
    echo "post_deploy: $plist not deployed; skipping LaunchAgent bootstrap" >&2
    return 0
  fi

  launchctl disable "$domain/com.openssh.ssh-agent" 2>/dev/null || true

  # Re-bootstrap so an edited plist takes effect without a logout.
  launchctl bootout "$domain/me.jpellis.gpg-agent" 2>/dev/null || true
  launchctl bootstrap "$domain" "$plist"
}

bootstrap_gpg_agent

# MARK: macOS rustic launcher
# Builds the app the rustic LaunchAgents start, then reloads the agents so an
# edited plist takes effect without a logout. The ad-hoc signature ties macOS
# privacy grants to this exact build, so the app is rebuilt only when its
# sources change; each rebuild prompts for them again.

build_rustic_launcher() {
  local src app domain job plist
  src="$repo_root/rustic/launcher"
  app="$HOME/Applications/RusticScheduled.app"
  domain="gui/$(id -u)"

  [ "$(uname -s)" = "Darwin" ] || return 0
  [ -f "$HOME/Library/LaunchAgents/me.jpellis.rustic-backup.plist" ] || return 0

  if ! command -v rustc >/dev/null 2>&1; then
    echo "post_deploy: rustc not found; skipping $app" >&2
    return 0
  fi

  if ! cmp -s "$src/main.rs" "$app/Contents/Resources/main.rs" ||
    ! cmp -s "$src/Info.plist" "$app/Contents/Info.plist"; then
    rm -rf "$app"
    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
    cp "$src/Info.plist" "$app/Contents/Info.plist"
    cp "$src/main.rs" "$app/Contents/Resources/main.rs"
    rustc --edition 2024 -C opt-level=2 -o "$app/Contents/MacOS/rustic-scheduled" "$src/main.rs"
    codesign --force --sign - "$app"
    echo "post_deploy: rebuilt $app; approve its privacy prompts on the next run" >&2
  fi

  for job in backup check prune; do
    plist="$HOME/Library/LaunchAgents/me.jpellis.rustic-$job.plist"
    launchctl bootout "$domain/me.jpellis.rustic-$job" 2>/dev/null || true
    launchctl bootstrap "$domain" "$plist"
  done
}

build_rustic_launcher
