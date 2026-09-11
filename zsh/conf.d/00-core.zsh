# shellcheck shell=zsh

## Vi key bindings
bindkey -v

## Up/down search history for lines sharing the current prefix, leaving the
## cursor at the end of the recalled line.  Bound for both cursor-key encodings:
## terminals send ^[[A in normal mode and ^[OA in application mode.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for _core_keymap in viins vicmd; do
  bindkey -M "$_core_keymap" '^[[A' up-line-or-beginning-search
  bindkey -M "$_core_keymap" '^[OA' up-line-or-beginning-search
  bindkey -M "$_core_keymap" '^[[B' down-line-or-beginning-search
  bindkey -M "$_core_keymap" '^[OB' down-line-or-beginning-search
done
unset _core_keymap

## Colours
autoload -Uz colors && colors

## _has / _has_widget — external command and ZLE widget lookups.
## Both take the name as a word: shfmt parses a subscript as arithmetic and
## rewrites a hyphen in it into a subtraction, so literal names must not
## appear inside `commands[...]` or `widgets[...]`.
_has() { (($+commands[$1])); }
_has_widget() { (($+widgets[$1])); }

## _tool_enabled — three-state feature flag helper.
## Usage: _tool_enabled <feature-key> <command-name>
## Returns 0 (load), 1 (skip). Warns if explicitly enabled but command not found.
_tool_enabled() {
  local feature="$1" cmd="$2" state
  zstyle -s ":config:tools:${feature}" enabled state
  case "$state" in
  no) return 1 ;;
  yes)
    _has "$cmd" || {
      print -u2 "zsh: '${feature}' is enabled but '${cmd}' was not found"
      return 1
    }
    return 0
    ;;
  *) _has "$cmd" ;; # unset: auto-detect silently
  esac
}

## BREW_PREFIX cache — avoids repeated slow subprocess calls.
## Cache lives in $XDG_CACHE_HOME (set by profile/environment.d).
## Manual invalidation: rm "$XDG_CACHE_HOME/brew_prefix"
zstyle -s ':config:os' type _core_os
if [[ "$_core_os" == 'macos' ]] && _has brew; then
  _brew_cache="${XDG_CACHE_HOME}/brew_prefix"
  if [[ ! -f "$_brew_cache" ]]; then
    brew --prefix >|"$_brew_cache"
  fi
  BREW_PREFIX="$(<$_brew_cache)"
  unset _brew_cache
fi
unset _core_os

## fpath — completion function paths
if [[ -n "$BREW_PREFIX" ]]; then
  fpath+=("$BREW_PREFIX/share/zsh/site-functions")
  # Fix world-writable Homebrew dirs that cause compinit security warnings.
  chmod go-w "$BREW_PREFIX/share" "$BREW_PREFIX/share/zsh"
  chmod -R go-w "$BREW_PREFIX/share/zsh/site-functions"
fi
[[ -d "${XDG_DATA_HOME}/zsh/site-functions" ]] &&
  fpath+=("${XDG_DATA_HOME}/zsh/site-functions")
