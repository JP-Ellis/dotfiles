# shellcheck shell=zsh

## Completion system — deferred to avoid blocking startup.
## compinit must run after fpath is fully populated (done in 00-core.zsh).
autoload -Uz compinit
zsh-defer compinit

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
