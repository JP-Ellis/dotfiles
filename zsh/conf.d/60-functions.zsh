# shellcheck shell=zsh

## xdg-open shim — Linux only, only if `open` is not already provided
zstyle -s ':config:os' type _fn_os
if [[ "$_fn_os" == 'linux' ]] && \
   (( $+commands[xdg-open] )) && \
   ! (( $+commands[open] )); then
  open() {
    local arg
    for arg in "$@"; do
      xdg-open "$arg"
    done
  }
fi
unset _fn_os

## Make directory and immediately cd into it
mkcd() {
  mkdir "$1" && cd "$1"
}

## bat-enhanced help — shows --help / -h output with syntax highlighting
if (( $+commands[bat] )); then
  export MANPAGER='bat -pl man'
  alias bat-help='bat -pl help'

  help() {
    if [[ -z "$1" ]]; then
      echo "Usage: help <command>" >&2
      return 1
    fi
    case "$1" in
      --help)
        echo "Usage: help <command>" >&2
        return 0
        ;;
    esac

    if "$@" --help >/dev/null 2>&1; then
      "$@" --help | bat --plain --language=help
    elif "$@" -h >/dev/null 2>&1; then
      "$@" -h | bat --plain --language=help
    elif man "$@" >/dev/null 2>&1; then
      man "$@"
    else
      echo "No help available for $*" >&2
      return 1
    fi
  }
fi
