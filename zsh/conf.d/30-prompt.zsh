# shellcheck shell=zsh

## Starship prompt — kept synchronous.
## Cannot defer: starship hooks into precmd and must be registered before the
## first prompt renders. Since starship is a compiled Rust binary (~5ms), the
## startup cost is acceptable.
_tool_enabled 'starship' 'starship' && eval "$(starship init zsh)"
