################################################################################
## Executes commands at the start of an interactive session.
################################################################################

## Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

## Load zplug
# if [[ -s "${ZPLUG_HOME:-$HOME/.zplug}/init.zsh" ]]; then
#     source "${ZPLUG_HOME:-$HOME/.zplug}/init.zsh"
#     source "$HOME/.zplugrc"
# fi


## Use extended glob to allow single paths abbreviations
setopt EXTENDED_GLOB

## Add a command to cd into a tmp directory
alias cdtmp='cd $(mktemp -d)'

## Shorten `xdg-open` to just `open`, and if given multiple arguments open each
## of them individually.
open() {
    for arg in "${(@)argv}"; do
        xdg-open "$arg"
    done
}


## Set the default Less options.
## Mouse-wheel scrolling has been disabled by `--no-init` (disable screen clearing).
## Remove `--no-init` and `--quit-if-one-screen` to enable it.
less_opt=(
    --chop-long-lines
    --hilite-search
    --hilite-unread
    --ignore-case
    --jump-target=.5
    --LONG-PROMPT
    --no-init
    --quit-if-one-screen
    --RAW-CONTROL-CHARS
    --shift=.33
    --squeeze-blank-lines
    --window=-4
)
export LESS="$less_opt"
export LESSOPEN='|pygmentize -g %s'

## Use exa as a replacement for ls
if (( $+commands[exa] )); then
    # Change ls to exa
    alias ls='exa --group-directories-first --git --binary'
    alias li='ls --git-ignore'
    alias l='ls --oneline --all'
    alias ll='ls --long --header'
    alias lr='ll --tree'
    alias la='ll --all'
    alias lx='ll --sort=extension'
    alias lk='ll --sort=size'
    alias lc='ll --sort=created --time=created'
    alias lm='ll --sort=modified --time=modified'
    alias lt='lm'
    if (( $+commands[lu] )); then
        unalias lu
    fi
    alias sl=ls
fi

## Make cd list the directory content on arrival
cdls () {
	  \cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}
alias cd=cdls


sshtmux() {
    ssh -t "${@:1:-1}" "${@: -1}" "tmux new-session -As sshtmux"
}


## Change feh
alias feh='\feh --scale-down'

## Print stderr in red
if [[ -f /usr/share/stderred/stderred.sh ]]; then
    source /usr/share/stderred/stderred.sh
fi
