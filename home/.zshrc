################################################################################
## Executes commands at the start of an interactive session.
################################################################################

## Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

## User and hostname are hidden if $USER and $DEFAULT_USER match
DEFAULT_USER="josh"

## Use extended glob to allow single paths abbreviations
setopt EXTENDED_GLOB

################################################################################
## Python Virtual Env
################################################################################
## Autoload a python virtual env if .pyvenv is present in the directory.
##
## By default, the presence of .venv will look for `pyvenv/bin/activate` in
## order to load the python virtualenv, but this can be customized by setting
## either of these two variables:
## - `pyvenv_activate`:  path to the activate script
## - `pyvenv_directory`:  path to the virtualenv directory.  It is assumed that
##   the activate script is in `$venv_directory/bin/activate`.
##
## The .pyvenv should look like:
## ```
## pyvenv_activate=pyvenv/bin/activate
## pyvenv_directory=pyvenv
## ```

## Disable the built-in PyEnv prompt modification
VIRTUAL_ENV_DISABLE_PROMPT=1

function check_python_virtualenv {
    if [[ -e .pyvenv ]]; then
        if [[ -n "$VIRTUAL_ENV" && ( "${PWD}" != "${VIRTUAL_ENV%%/pyvenv}" || "${PWD}" != "${VIRTUAL_ENV%%$pyvenv_subdir}" ) ]]; then
            deactivate
            unset pyvenv_activate
            unset pyvenv_directory
            unset pyvenv_subdir
        fi
        source .pyvenv

        if [[ -n "$pyvenv_activate" ]]; then
            source "$pyvenv_activate"
        elif [[ -n "$pyvenv_directory" ]]; then
            source "$pyvenv_directory/bin/activate"
        else
            source "pyvenv/bin/activate"
        fi
        pyvenv_subdir=${VIRTUAL_ENV##$PWD}
    ## If PWD stripped of VIRTUAL_ENV prefix matches PWD, then we are no longer
    ## with the virtualenv and should deactive.
    elif [[ -n "$VIRTUAL_ENV" && ( "${PWD##${VIRTUAL_ENV%%$pyvenv_subdir}}" == "${PWD}" || "${PWD##${VIRTUAL_ENV%%/pyvenv}}" == "${PWD}" ) ]]; then
        deactivate
        unset pyvenv_activate
        unset pyvenv_directory
        unset pyvenv_subdir
    fi
}

add-zsh-hook chpwd check_python_virtualenv

################################################################################
## Miscellaneous
################################################################################

## Make cd list the directory content on arrival
alias cd=cdls

## Shorten `xdg-open` to just `open`
alias open=xdg-open

## Set the default Less options.
## Mouse-wheel scrolling has been disabled by `--no-init` (disable screen clearing).
## Remove `--no-init` and `--quit-if-one-screen` to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESS=(
    --quit-if-one-screen
    --hilite-search
    --ignore-case
    --jump-target=.5
    --LONG-PROMPT
    --RAW-CONTROL-CHARS
    --squeeze-blank-lines
    --chop-long-lines
    --hilite-unread
    --no-init
    --window=-4
    --shift=.33
)
