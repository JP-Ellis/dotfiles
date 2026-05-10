# shellcheck shell=zsh

## Completion initialisation — called deferred by sheldon (after zsh-completions
## populates fpath, before fzf-tab wraps widgets).
_compinit_load() {
  local dump="${XDG_CACHE_HOME}/zsh/zcompdump"
  mkdir -p "${dump:h}"
  # Skip the slow per-directory security check when the dump is < 24 h old.
  # Use full compinit (with security checks) to rebuild when stale or missing.
  if [[ -f $dump && -n ${dump}(#qNmh-24) ]]; then
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

## zsh-autosuggestions — strategy: try history first, fall back to completion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

## fzf-tab — replaces zsh's default tab completion menu with fzf.
## Only configured if fzf is available; the plugin itself is loaded via sheldon.
if _tool_enabled 'fzf-tab' 'fzf'; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview \
    'eza --tree --level 2 --color=always $realpath 2>/dev/null || ls $realpath'
  zstyle ':fzf-tab:*' switch-group '<' '>'
fi
