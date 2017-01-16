#!/usr/bin/env zsh

help () {
    echo "Usage: $1"
    echo "Setup all the files into the appropriate locations."
    echo ""
    echo "The setup script will prompt you to setup the various components.  In"
    echo "every case, if a file or directory already exists a backup will be"
    echo "made with the extension \`.bak.$RANDOM\`."
}

if [[ $# -gt 0 ]]; then
    help $0
    exit 1
fi

# As yes or no and return true or false
# Usage:
# yes_or_no(<statement>, <default>)
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

        REPLY=
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

## Miscellaneous individual files
################################################################################

## Files in the home directory
for file in ".dir_colors" ".latexmkrc" ".profile" ".spacemacs" ".Xresources"; do
    yes_or_no "Link $file into the home directory?" Y || continue

    if [[ -e "$HOME/$file" ]]; then
        mv -v "$HOME/$file" "$HOME/$file.bak.$RANDOM"
    fi
    ln -fvs "$(pwd)/home/$file" "$HOME/$file"
done

## Files in the config directory
for file in "pgfplots.default.tex"; do
    yes_or_no "Link $file into the config directory?" Y || continue

    if [[ -e "$HOME/.config/$file" ]]; then
        mv -v "$HOME/.config/$file" "$HOME/.config/$file.bak.$RANDOM"
    fi
    ln -fvs "$(pwd)/config/$file" "$HOME/.config/$file"
done


## Configuration directories
################################################################################

for dir in $(pwd)/config/*/(.N); do
    dir="${${dir#$(pwd)/config/}%/}"
    yes_or_no "Setup $dir" Y || continue
    if [[ -e "$HOME/.config/$dir" ]]; then
        mv -v "$HOME/.config/$dir" "$HOME/.config/$dir.bak.$RANDOM"
    fi
    ln -fvs "$(pwd)/config/$dir" "$HOME/.config/$dir.bak.$RANDOM"
done

for dir in $(pwd)/home/*/(.N) $(pwd)/home/.*/(.N); do
    dir="${${dir#$(pwd)/home/}%/}"
    yes_or_no "Setup $dir" Y || continue
    if [[ -e "$HOME/$dir" ]]; then
        mv -v "$HOME/$dir" "$HOME/$dir.bak.$RANDOM"
    fi
    ln -fvs "$(pwd)/home/$dir" "$HOME/$dir"
done


## Scripts
################################################################################

mkdir -p "$HOME/.local/bin"
for bin in $(pwd)/bin/*(.N); do
    bin="${bin#$(pwd)/bin/}"
    yes_or_no "Link $bin ?" || continue
    if [[ -e "$HOME/.local/bin/$bin" ]]; then
        mv -v "$HOME/.local/bin/$bin" "$HOME/.local/bin/$bin.bak.$RANDOM"
    fi
    ln -fvs "$(pwd)/bin/$bin" "$HOME/.local/bin/$bin"
done


## ZSH
################################################################################

if yes_or_no "Setup ZSH?" Y; then
    # Clone (or update) ZSH
    if [[ ! -d "$HOME/.zprezto" ]]; then
        echo "Cloning zprezto"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
        ln -fvs "$(pwd)/prompt_jpellis_setup" "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/functions/prompt_jpellis_setup"
    else
        git -C "${ZDOTDIR:-$HOME}/.zprezto" pull --recursive
    fi

    # Make the DEFAULT_USER the current user
    sed -i "s#DEFAULT_USER=\"josh\"#DEFAULT_USER=\"$(whoami)\"#" "$(pwd)/home/.zshrc"

    # Link the files
    for file in ".zlogin" ".zlogout" ".zpreztorc" ".zprofile" ".zshenv" ".zshrc"; do
        if [[ -e "$HOME/$file" ]]; then
            mv -v "$HOME/$file" "$HOME/$file.bak.$RANDOM"
        fi
        ln -fvs  "$(pwd)/home/$file" "$HOME/$file"
    done

    yes_or_no "Make ZSH the default shell?" Y && chsh -s $(which zsh) $(whoami)
fi


## Spacemacs
################################################################################

if yes_or_no "Setup Spacemacs?" Y; then
    # Clone spacemacs if it hasn't been done already.
    if [[ ! -d "$HOME/.emacs.d" ]]; then
        git clone --branch develop https://github.com/syl20bnr/spacemacs "$HOME/.emacs.d"
    else
        mv "$HOME/.emacs.d" "$HOME/.emacs.d.bak.$RANDOM"
        mv "$HOME/.emacs" "$HOME/.emacs.bak.$RANDOM" 2>/dev/null
        git clone --branch develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
    fi

    # Link the files
    if [[ -e "$HOME/.spacemacs" ]]; then
        mv -v "$HOME/.spacemacs" "$HOME/.spacemacs.bak.$RANDOM"
    fi
    ln -fvs "$(pwd)/home/.spacemacs" "$HOME/.spacemacs"
fi
