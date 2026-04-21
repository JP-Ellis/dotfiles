# shellcheck shell=zsh

## zsh-patina syntax highlighting.
##
## MUST load last — after:
##   - zsh-autosuggestions  (loaded via sheldon defer template)
##   - fzf-tab              (loaded via sheldon defer template)
##   - compinit             (deferred in 20-completion.zsh)
##
## Using zsh-defer here ensures FIFO ordering: all sheldon-deferred items are
## already queued before this file sources, so this runs after them.
(( $+commands[zsh-patina] )) && zsh-defer eval "$(zsh-patina activate)"
