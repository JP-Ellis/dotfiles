#!/bin/sh


## User name
################################################################################
## If $USER is some long@username.institution.edu, define $SUSER to be the part
## before the '@' (or leave it unchanged if there is no '@').
export SUSER="${USER%@*}"


## Temporary directory
################################################################################
## Remove trailing slash from $TMPDIR if present
export TMPDIR="${TMPDIR%/}"

## If $TMPDIR is unset, set it to /tmp/$SUSER
if [ -z "$TMPDIR" ] ; then
    export TMPDIR="/tmp/$SUSER"
fi

## Make sure that $TMPDIR ends with $SUSER
if [ "${TMPDIR%$SUSER}" = "$TMPDIR" ] ; then
    export TMPDIR="$TMPDIR/$SUSER"
fi

## Try and make the $TMPDIR is only readable to the current user
mkdir -p -m 700 "$TMPDIR"
chown "$USER" "$TMPDIR"
chmod 700 "$TMPDIR"


## Applications
################################################################################

export EDITOR='vim'
export VISUAL='code -w'
export PAGER='less'
export BROWSER='brave'


## Paths
################################################################################

## Update the various PATH variables if the relevant subdirectories exist
add_paths() {
    if [ -d "$1/bin" ] ; then
        if [ -z "$PATH" ] ; then
            export PATH="$1/bin"
        else
            export PATH="$1/bin:$PATH"
        fi
    fi
    if [ -d "$1/include" ] ; then
        if [ -z "$CPATH" ] ; then
            export CPATH="$1/include"
        else
            export CPATH="$1/include:$CPATH"
        fi
    fi
    if [ -d "$1/lib" ] ; then
        if [ -z "$LIBRARY_PATH" ] ; then
            export LIBRARY_PATH="$1/lib"
        else
            export LIBRARY_PATH="$1/lib:$LIBRARY_PATH"
        fi
        if [ -z "$LD_LIBRARY_PATH" ] ; then
            export LD_LIBRARY_PATH="$1/lib"
        else
            export LD_LIBRARY_PATH="$1/lib:$LD_LIBRARY_PATH"
        fi
    fi
}

for dir in "$HOME/.local" "/scratch/$USER/local" "/scratch/$SUSER/local" ; do
    add_paths "$dir"
done


## Rust
################################################################################

if [ -n "$CARGO_HOME" ]; then
    export PATH="$CARGO_HOME/bin:$PATH"
fi

## gpg-agent and ssh
################################################################################

if [ -S /run/user/$UID/gnupg/S.gpg-agent.ssh ]; then
    export SSH_AUTH_SOCK=/run/user/$UID/gnupg/S.gpg-agent.ssh
fi


## Make
################################################################################

export MAKEFLAGS="-j$(nproc)"


## Interactive Shell
################################################################################
# Last couple of things to check when we have an interactive shell
case $- in
    *i*)
        # Give a warning if $TMPDIR might be readable to other users
        if [ \
             $(( $(stat --printf='%a' $TMPDIR) % 1000 )) != 700 \
             -o "$(id -u)" -ne "$(stat --printf='%u' $TMPDIR)" \
             -o "$(id -g)" -ne "$(stat --printf='%g' $TMPDIR)" \
           ] ; then
            echo "TMPDIR may be readable to others." >&2
        fi
        ;;
    *)
        ;;
esac


## Load environment variables from .config/environment.d if needed
################################################################################
# Pending on the resut from https://github.com/systemd/systemd/issues/7641
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=remote/ssh
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) SESSION_TYPE=remote/ssh;;
    esac
fi

if [ "$SESSION_TYPE" = "remote/ssh" ]; then
    for f in $HOME/.config/environment.d/* ; do
        set -o allexport
        source $f
        set +o allexport
    done
fi


## Clean path
################################################################################

clean_path=""
for p in $(printf %s "$PATH" | tr ':' '\n') ; do
    if [ "${clean_path#*:$p}" != "$clean_path" ] ; then
        continue
    fi
    if [ -d "$p" ] ; then
        if [ "$clean_path" = "" ] ; then
            clean_path="$p"
        else
            clean_path="$clean_path:$p"
        fi
    fi
done
export PATH="$clean_path"
