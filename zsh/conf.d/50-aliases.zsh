# shellcheck shell=zsh

## ls substitution
if ((${+commands[eza]})); then
  alias ls='eza --group-directories-first --git --binary'
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

## Docker/Podman — interactive shells only (not in profile)
if (( $+commands[podman] )) && ! (( $+commands[docker] )); then
  alias docker=podman
fi
if (( $+commands[podman-compose] )) && ! (( $+commands[docker-compose] )); then
  alias docker-compose=podman-compose
fi
