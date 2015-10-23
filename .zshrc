#
# Executes commands at the start of an interactive session.
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

#
# My customizations
################################################################################

#
# Autoloid a python virtual env is ./.venv is present in the directory.
#
# By default, the presence of .venv will look for `env/bin/activate` in order
# to load the python virtualenv, but this can be customized by setting either
# of these two variables:
# - `venv_activate`:  path to the activate script
# - `venv_directory`:  path to the virtualenv directory.  It is assumed that
#   the activate script is in `$venv_directory/bin/activate`.
#
# The .venv should look like:
# ```
# venv_activate=env/bin/activate
# venv_directory=env
# ```

# Disable the built-in PyEnv prompt modification
VIRTUAL_ENV_DISABLE_PROMPT=1

function check_virtualenv {
    if [[ -e .venv ]]; then
        if [[ -n "$VIRTUAL_ENV" && ( "${PWD}" != "${VIRTUAL_ENV%%/env}" || "${PWD}" != "${VIRTUAL_ENV%%$venv_subdir}" ) ]]; then
            deactivate
            unset venv_activate
            unset venv_directory
            unset venv_subdir
        fi
        source .venv

        if [[ -n "$venv_activate" ]]; then
            source "$venv_activate"
        elif [[ -n "$venv_directory" ]]; then
            source "$venv_directory/bin/activate"
        else
            source "env/bin/activate"
        fi
        venv_subdir=${VIRTUAL_ENV##$PWD}
    # If PWD stripped of VIRTUAL_ENV prefix matches PWD, then we are no longer
    # with the virtualenv and should deactive.
    elif [[ -n "$VIRTUAL_ENV" && ( "${PWD##${VIRTUAL_ENV%%$venv_subdir}}" == "${PWD}" || "${PWD##${VIRTUAL_ENV%%/env}}" == "${PWD}" ) ]]; then
        deactivate
        unset venv_activate
        unset venv_directory
        unset venv_subdir
    fi
}

add-zsh-hook chpwd check_virtualenv

#
# Extended Glob
setopt EXTENDED_GLOB

# Make cd list the directory content on arrival
alias cd=cdls

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# if (( $+commands[lesspipe.sh] )); then
#     export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
# fi
if (( $+commands[src-hilite-lesspipe.sh])); then
    export LESSOPEN="| /usr/bin/env src-hilite-lesspipe.sh %s 2>&-"
fi

#
# Miscellaneous customizations
################################################################################

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
[[ -s "$HOME/.travis/travis.sh" ]] && source "$HOME/.travis/travis.sh"
