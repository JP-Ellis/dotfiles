################################################################################
## Executes commands at the start of an interactive session.
################################################################################

## Commands
################################################################################

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
if command -v exa 2>&1 1>/dev/null ; then
    # Change ls to exa
    alias ls='exa --group-directories-first --git --binary'
    alias li='ls --git-ignore'
    alias l='ls --oneline --all'
    alias ll='ls --long --header'
    alias lr='ll --tree'
    alias la='ll --all'
    alias lx='ll --sort=extension'
    alias lb='ll --sort=size'
    alias lc='ll --sort=created --time=created'
    alias lm='ll --sort=modified --time=modified'
    alias lt='lm'
    alias sl=ls
elif command -v lsd 2>&1 1>/dev/null ; then
    # Change ls to lsd
    alias ls='lsd --group-dirs first'
    alias l='ls --oneline --almost-all'
    alias ll='ls --long'
    alias lr='ll --tree'
    alias la='ll --almost-all'
    alias lb='ll --sizesort'
    alias lt='ll --timesort'
    alias sl=ls
else
    alias ls='ls --group-directories-first --color=auto'
    alias l='ls -1 --almost-all'
    alias ll='ls -l --human-readable'
    alias lr='ll --recursive'
    alias la='ll --almost-all'
    alias lx='ll --sort=extension'
    alias lb='ll --sort=size'
    alias lc='ll --sort=time --time=created'
    alias lm='ll --sort=time --time=modified'
    alias lt='lm'
    alias sl=ls
fi

## Make cd list the directory content on arrival
cdls () {
    \cd "$@" && ls
}
alias cd=cdls

## Change feh
alias feh='\feh --scale-down'

## xclip defaults to using the clipboard
alias xclip='\xclip -selection clipboard'


## Load starship
if command -v starship 2>&1 1>/dev/null ; then
    eval "$(starship init bash)"
fi
