# shellcheck shell=zsh

## All tool integrations are deferred via zsh-defer so they don't block startup.
## direnv is last — it may override completions/aliases set by other tools.

## mise — runtime and tool manager
## Activating mise sets up PATH hooks for per-directory tool switching.
## (mise shims are already in PATH from the profile; this adds dynamic behaviour.)
_tool_enabled 'mise' 'mise' && zsh-defer eval "$(mise activate zsh)"

## zoxide — smarter cd with frecency-based directory tracking
_tool_enabled 'zoxide' 'zoxide' && zsh-defer eval "$(zoxide init zsh)"

## AWS completions
_tool_enabled 'aws' 'aws_completer' && \
  zsh-defer complete -C "$(which aws_completer)" aws

## gcloud completions (macOS Homebrew path; no-op if BREW_PREFIX unset or file absent)
if _tool_enabled 'gcloud' 'gcloud' && [[ -n "$BREW_PREFIX" ]]; then
  _tools_gcloud_comp="$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
  [[ -f "$_tools_gcloud_comp" ]] && zsh-defer source "$_tools_gcloud_comp"
  unset _tools_gcloud_comp
fi

## direnv — must be last (overrides other completions/aliases)
_tool_enabled 'direnv' 'direnv' && zsh-defer eval "$(direnv hook zsh)"
