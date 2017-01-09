if [[ ! -d "$TMPDIR" ]]; then
    export TMPDIR="/tmp/$USER"
    mkdir -p -m 700 "$TMPDIR"
fi

# Add ~/.local/bin to $PATH
[[ -d $HOME/.local/bin ]] && export PATH=$HOME/.local/bin:$PATH

# Multirust support
[[ -d $HOME/.cargo/bin ]] && export PATH=$HOME/.cargo/bin:$PATH

# gpg-agent and ssh
[[ -d $HOME/.config/gnupg ]] && export GNUPGHOME=$HOME/.config/gnupg
[[ -S "/run/user/1000/gnupg/d.ktgehwewyo8sebu4d9w5kak4/S.gpg-agent.ssh" ]] && export SSH_AUTH_SOCK="/run/user/1000/gnupg/d.ktgehwewyo8sebu4d9w5kak4/S.gpg-agent.ssh"

export XDG_DOWNLOAD_DIR="$TMPDIR/Downloads"
export XDG_DESKTOP_DIR="$HOME/"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_MUSIC_DIR="$HOME/Media/Music"
export XDG_PICTURES_DIR="$HOME/Media/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Documents/Public"
export XDG_TEMPLATES_DIR="$HOME/Documents/Templates"
export XDG_VIDEOS_DIR="$HOME/Media/Videos"
