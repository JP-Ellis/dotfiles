#!/bin/zsh

setopt NULL_GLOB

help () {
    echo "Usage: $1"
    echo "Setup all the files into the appropriate locations."
    echo ""
    echo "The setup script will prompt you to setup the various components.  In"
    echo "every case, if a file or directory already exists a backup will be"
    echo "made with the extension \`.bak.$RANDOM\`."
}

if [ $# -gt 0 ]; then
    help $0
    exit 1
fi

# As yes or no and return true or false
# Usage:
# yes_or_no <statement>, <default>
yes_or_no() {
    while true; do
        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        unset REPLY
        local compcontext='yn:yes or no:(y n)'
        vared -cp "$1 [$prompt] " REPLY

        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

make_backup() {
    if [ $# -ne 1 ]; then
        echo "$0 requires exactly one argument." >&2
        exit 1
    fi
    if [ -e "$1" ]; then
        printf "Moved "
        mv -v "$1" "$1.bak.$RANDOM"
    fi
}

make_link() {
    if [ $# -ne 2 ]; then
        echo "$0 requires exactly two arguments." >&2
        exit 1
    fi
    make_backup "$2"
    printf "Linked "
    ln -vs "$1" "$2"
}

## Link files and directories
################################################################################

## Files in the home directory
for f in $(pwd)/home/* $(pwd)/home/.*; do
    f="$(basename "$f")"
    yes_or_no "Link $f into the home directory?" Y || continue
    make_link "$(pwd)/home/$f" "$HOME/$f"
done

mkdir -p "$HOME/.config"
for f in $(pwd)/config/* $(pwd)/config/.*; do
    f="$(basename "$f")"
    yes_or_no "Link $f into the .config directory?" Y || continue
    make_link "$(pwd)/config/$f" "$HOME/.config/$f"
done

mkdir -p "$HOME/.local/bin"
for f in $(pwd)/bin/* $(pwd)/bin/.*; do
    f="$(basename "$f")"
    yes_or_no "Link $f into .local/bin" Y || continue
    make_link "$(pwd)/bin/$f" "$HOME/.local/bin/$f"
done

## ZSH
################################################################################

if yes_or_no "Setup ZSH?" Y; then
    # Clone (or update) ZSH
    if [ ! -d "$HOME/.zprezto" ]; then
        echo "Cloning zprezto"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
        ln -fvs "$(pwd)/prompt_jpellis_setup" "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/functions/prompt_jpellis_setup"
    else
        git -C "${ZDOTDIR:-$HOME}/.zprezto" pull
        git -C "${ZDOTDIR:-$HOME}/.zprezto" submodule update --init --recursive
    fi

    # Make the DEFAULT_USER the current user
    sed -i "s#DEFAULT_USER=\"josh\"#DEFAULT_USER=\"$(whoami)\"#" "$(pwd)/home/.zshrc"

    yes_or_no "Make ZSH the default shell?" Y && chsh -s $(which zsh) $(whoami)
fi


## Spacemacs
################################################################################

if yes_or_no "Setup Spacemacs?" Y; then
    # Clone spacemacs if it hasn't been done already.
    if [ ! -d "$HOME/.emacs.d" ]; then
        git clone --branch develop https://github.com/syl20bnr/spacemacs "$HOME/.emacs.d"
    else
        make_backup "$HOME/.emacs.d"
        git clone --branch develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
    fi
fi
