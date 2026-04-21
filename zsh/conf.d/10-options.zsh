# shellcheck shell=zsh

## History — stored in XDG_STATE_HOME (mutable runtime data, not config)
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=1000000
SAVEHIST=1000000

## Ensure history directory exists
[[ -d "${XDG_STATE_HOME}/zsh" ]] || mkdir -p "${XDG_STATE_HOME}/zsh"

## History options
setopt bang_hist
setopt extended_history
setopt hist_allow_clobber
setopt hist_expire_dups_first
setopt hist_fcntl_lock
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_lex_words
setopt hist_save_by_copy
setopt hist_save_no_dups
setopt hist_verify
setopt inc_append_history_time

## File safety
setopt no_clobber

## Completion
setopt complete_in_word
setopt glob_complete
setopt menu_complete
setopt glob_dots
setopt auto_menu
