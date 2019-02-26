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

## If $TMPDIR defaults to /tmp or /scratch, create a subdirectory inside that.
if [ "$TMPDIR" = "/tmp" -o "$TMPDIR" = "/scratch" ] ; then
    export TMPDIR="$TMPDIR/$SUSER"
    mkdir -p -m 700 "$TMPDIR"
fi

## Try and make the $TMPDIR is only readable to the current user
chown "$USER" "$TMPDIR"
chmod 700 "$TMPDIR"


## Applications
################################################################################

export EDITOR='vim'
export VISUAL='emacs'
export PAGER='less'
export BROWSER='firefox-developer-edition'


## Paths
################################################################################

## Update the various PATH variables if the relevant subdirectories exist
add_paths() {
    if [ -d "$1/bin" ] ; then
        export PATH="$1/bin:$PATH"
    fi
    if [ -d "$1/include" ] ; then
        export CPATH="$1/include:$CPATH"
    fi
    if [ -d "$1/lib" ] ; then
        export LIBRARY_PATH="$1/lib:$LIBRARY_PATH"
        export LD_LIBRARY_PATH="$1/lib:$LD_LIBRARY_PATH"
    fi
}

for dir in "$HOME/.local" "/scratch/$USER/local" "/scratch/$SUSER/local" ; do
    add_paths "$dir"
done


## Rust
################################################################################

if [ -d "$HOME/.cargo" ] ; then
    export CARGO_HOME="$HOME/.cargo"
    export PATH="$HOME/.cargo/bin:$PATH"
fi
if [ -d "$HOME/.rustup" ] ; then
    export RUSTUP_HOME="$HOME/.rustup"
fi

## Use $HOME/.cache/cargo for all cargo build artefacts
[ -n "$CARGO_HOME" ] && export CARGO_TARGET_DIR="$HOME/.cache/cargo"

if command -v rustc >/dev/null ; then
    export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi

## Python
################################################################################

export PYTHONPYCACHEPREFIX="$HOME/.cache/python"


## gpg-agent and ssh
################################################################################

if [ -d $HOME/.config/gnupg ] ; then
    export GNUPGHOME="$HOME/.config/gnupg"
fi
if [ -S "$(gpgconf --list-dirs | sed -n 's|agent-socket:||p').ssh" ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs | sed -n 's|agent-socket:||p').ssh"
fi


## XDG directories
################################################################################

export XDG_DOWNLOAD_DIR="$TMPDIR/Downloads"
export XDG_DESKTOP_DIR="$HOME/"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_MUSIC_DIR="$HOME/Media/Music"
export XDG_PICTURES_DIR="$HOME/Media/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Documents/Public"
export XDG_TEMPLATES_DIR="$HOME/Documents/Templates"
export XDG_VIDEOS_DIR="$HOME/Media/Videos"


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


## Clean path
################################################################################

clean_path=""
for p in $(printf %s "$PATH" | tr ':' '\n') ; do
    if [ "${clean_path#*$p}" != "$clean_path" ] ; then
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
