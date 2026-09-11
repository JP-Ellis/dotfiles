# shellcheck shell=zsh

## Completion initialisation — called deferred by sheldon (after zsh-completions
## populates fpath, before fzf-tab wraps widgets).
autoload -Uz compinit
_compinit_load() {
  local dump="${XDG_CACHE_HOME}/zsh/zcompdump"
  mkdir -p "${dump:h}"
  # Skip the slow per-directory security check when the dump is fresh (< 24 h)
  # and non-empty. Rebuild otherwise — an empty dump (e.g. from a previously
  # failed compinit run) silently loads nothing and breaks every completer.
  if [[ -s $dump && -n ${dump}(#qNmh-24) ]]; then
    compinit -C -d "$dump"
  else
    compinit -d "$dump"
    touch "$dump"  # ensure mtime is refreshed even if nothing changed
  fi
  # Byte-compile the dump for faster sourcing on the next rebuild
  [[ ! -f "${dump}.zwc" || $dump -nt "${dump}.zwc" ]] && zcompile "$dump"
}

## Completion styles
zstyle ':completion:*' completer _list _oldlist _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' glob 1
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' match-original both
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' verbose true

## deja — predictive inline suggestions; the plugin itself is loaded via sheldon.
## Its default cycle key is Tab, which would shadow fzf-tab. Cycling is bound
## to Shift+Tab below through a wrapper that also lists the candidates under
## the prompt, since deja-cycle only repaints the ghost text. Emptying the
## variable keeps deja from binding any key itself.
DEJA_CYCLE_KEY=''

## The leading underscore matters: deja wraps every widget not matching its
## ignore list (which includes `_*`) as a buffer-modifying widget, which would
## clear the ghost before the cycle runs.
_deja_cycle_list() {
  (( $+widgets[deja-cycle] )) || return
  zle deja-cycle
  local -i n=${#_DEJA_ALTERNATIVES}
  (( n < 2 )) && return
  local -i i; local out=""
  for (( i = 1; i <= n; i++ )); do
    if (( i == _DEJA_ALT_INDEX )); then
      out+="▸ ${_DEJA_ALTERNATIVES[i]}"
    else
      out+="  ${_DEJA_ALTERNATIVES[i]}"
    fi
    (( i < n )) && out+=$'\n'
  done
  zle -M "$out"
}
zle -N _deja_cycle_list
bindkey '^[[Z' _deja_cycle_list

## fzf-tab — replaces zsh's default tab completion menu with fzf.
## Only configured if fzf is available; the plugin itself is loaded via sheldon.
if _tool_enabled 'fzf-tab' 'fzf'; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview \
    'eza --tree --level 2 --color=always $realpath 2>/dev/null || ls $realpath'
  zstyle ':fzf-tab:*' switch-group '<' '>'
fi
