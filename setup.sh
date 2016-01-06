#/bin/sh

# As yes or no and return true or false
# Usage:
# yes_or_no(<statement>, <default>)
function yes_or_no() {
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

        read -p "$1 [$prompt] " REPLY </dev/tty

        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

declare -a files=(
    ".dir_colors"
    ".latexmkrc"
    ".profile"
    ".spacemacs"
    ".zlogin"
    ".zlogout"
    ".zpreztorc"
    ".zprofile"
    ".zshenv"
    ".zshrc"
)
declare -a config_dirs=(
    "i3"
    "termite"
    "dunst"
)

# Link all the config files
for file in ${files[@]}; do
    if [ -e "$HOME/$file" ]; then
        yes_or_no "~/$file exists already, replace it (a backup will be made)?" N || continue
        mv "$HOME/$file" "$HOME/$file.backup"
    fi
    ln "$(pwd)/$file" "$HOME/$file"
    echo "Linked ~/$file."
done

# Symlink all config directories
for dir in ${config_dirs[@]}; do
    if [ -d "$HOME/.config/$dir" ]; then
        yes_or_no "~/.config/$dir exists already, replace it (a backup will be made)?" N || continue
        mv "$HOME/.config/$dir" "$HOME/.config/$dir.backup"
    fi
    ln -s "$(pwd)/$dir" "$HOME/.config/$dir"
    echo "Linked ~/.config/$dir."
done

# Clone zprezto
if [ ! -d "$HOME/.zprezto" ]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    ln -f "$(pwd)/prompt_jpellis_setup" "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/functions/prompt_jpellis_setup"
fi

# Clone spacemacs if it hasn't been done already.
if [ ! -d "$HOME/.emacs.d" ]; then
    git clone --branch develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
else
    if yes_or_no "~/.emacs.d already exists.  Replace with spacemacs (a backup will be made)?" N ; then
        mv "$HOME/.emacs.d" "$HOME/.emacs.d.backup"
        mv "$HOME/.emacs" "$HOME/.emacs.backup" 2>/dev/null
        git clone --branch develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
    fi
fi

