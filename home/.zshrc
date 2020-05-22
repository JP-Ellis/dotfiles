################################################################################
## Executes commands at the start of an interactive session.
################################################################################

## Source ZSH options
if [[ -s "$HOME/.zoptions" ]]; then
    source "$HOME/.zoptions"
fi

## Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

## Source zplugin
# if [[ -s "$HOME/.zplugin" ]]; then
#     source "$HOME/.zplugin/bin/zplugin.zsh"
#     source "$HOME/.zpluginrc"
# fi


## Commands
################################################################################

## Various navigation/directory shortcuts and convenience
cdls () {
    \cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}
alias cd=cdls
alias mkcd='\mkdir $1 && cd $1'
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
    --mouse
    --no-init
    --quit-if-one-screen
    --RAW-CONTROL-CHARS
    --shift=.33
    --squeeze-blank-lines
    --window=-4
)
export LESS="$less_opt"

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
    alias sl=ls
elif (( $+commands[lsd] )); then
    # Change ls to lsd
    alias ls='lsd --group-dirs first'
    alias l='ls --oneline --almost-all'
    alias ll='ls --long'
    alias lr='ll --tree'
    alias la='ll --almost-all'
    alias lk='ll --sizesort'
    alias lt='ll --timesort'
    alias sl=ls
# else
#     alias ls='ls --group-directories-first --git --binary'
#     alias li='ls --git-ignore'
#     alias l='ls --oneline --all'
#     alias ll='ls --long --header'
#     alias lr='ll --tree'
#     alias la='ll --all'
#     alias lx='ll --sort=extension'
#     alias lk='ll --sort=size'
#     alias lc='ll --sort=created --time=created'
#     alias lm='ll --sort=modified --time=modified'
#     alias lt='lm'
#     alias sl=ls
fi

## Combine SSH and tmux
sshtmux() {
    ssh -t "${@:1:-1}" "${@: -1}" "tmux new-session -As sshtmux"
}

## Change feh
alias feh='\feh --scale-down'

## xclip defaults to using the clipboard
alias xclip='\xclip -selection clipboard'

## Use to format man page
if (( $+commands[bat] )); then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

## Filter out ANSI colours
alias remove-ansi="sed 's/\x1b\[[0-9;]*m//g'"

## Load starship
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi
