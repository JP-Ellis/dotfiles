# shellcheck shell=zsh

## All tool integrations deferred via zsh-defer so they don't block startup.
##
## Critically, ALL tools are batched into a SINGLE zsh-defer call.  Each
## separate zsh-defer call triggers a precmd cycle; VSCode shell integration
## walks the full environment on every precmd (~800 ms per cycle), so every
## extra batch costs ~1 s in a VSCode terminal.  Capturing the activation
## scripts synchronously is cheap (<250 ms total); the expensive eval is what
## we defer — and we do it once.
##
## direnv is evaluated last — it may override completions/aliases set by other tools.

() {
  local _deferred=''

  ## mise — runtime and tool manager
  if _tool_enabled 'mise' 'mise'; then
    if [[ -n $VSCODE_INJECTION ]]; then
      # Strip inherited mise state before capturing the activation script so
      # mise generates a fresh diff rather than embedding the stale one.
      _deferred+="$(env -u __MISE_DIFF -u __MISE_SESSION -u __MISE_ORIG_PATH mise activate zsh 2>/dev/null)"$'\n'
    else
      _deferred+="$(mise activate zsh 2>/dev/null)"$'\n'
    fi
  fi

  ## zoxide — smarter cd with frecency-based directory tracking
  if _tool_enabled 'zoxide' 'zoxide'; then
    _deferred+="$(zoxide init zsh 2>/dev/null)"$'\n'
  fi

  ## AWS completions — complete -C is bash syntax; bashcompinit provides the shim.
  if _tool_enabled 'aws' 'aws_completer'; then
    _deferred+="autoload -Uz bashcompinit && bashcompinit"$'\n'
    _deferred+="complete -C ${(q)$(whence -p aws_completer)} aws"$'\n'
  fi

  ## gcloud completions (macOS Homebrew path; no-op if BREW_PREFIX unset or file absent)
  if _tool_enabled 'gcloud' 'gcloud' && [[ -n $BREW_PREFIX ]]; then
    local _gcloud_comp="$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
    [[ -f $_gcloud_comp ]] && _deferred+="source ${(q)_gcloud_comp}"$'\n'
  fi

  ## direnv — must be last (overrides other completions/aliases)
  if _tool_enabled 'direnv' 'direnv'; then
    _deferred+="$(direnv hook zsh 2>/dev/null)"$'\n'
  fi

  if [[ -n $_deferred ]]; then
    if [[ -n $VSCODE_INJECTION ]]; then
      # VSCode inherits PATH from resolveShellEnv (which fully activated mise)
      # but strips __MISE_DIFF/__MISE_ORIG_PATH from the environment. This means
      # mise tool paths are already embedded in the inherited PATH at the wrong
      # position (after homebrew). When mise activate runs and sets
      # __MISE_ORIG_PATH=$PATH, it captures this polluted PATH and hook-env
      # considers tools "already active", producing no reordering. Strip mise
      # paths first so ORIG_PATH is clean and hook-env correctly prepends tool
      # paths before homebrew.
      local _mise_data="${XDG_DATA_HOME:-$HOME/.local/share}/mise"
      path=("${(@)path:#${_mise_data}/installs/*}")
      path=("${(@)path:#${_mise_data}/shims}")
      unset __MISE_DIFF __MISE_SESSION __MISE_ORIG_PATH

      (($+functions[_compinit_load])) && _compinit_load
      eval "$_deferred"
      (($+functions[_mise_hook_precmd])) && _mise_hook_precmd
    else
      # Promote to global so zsh-defer can access it outside this anonymous
      # scope, then eval in a single deferred batch (compdef requires compinit
      # to have run).
      typeset -g _tools_deferred_script="$_deferred"
      zsh-defer -c 'eval "$_tools_deferred_script"; unset _tools_deferred_script'
    fi
  fi
}
