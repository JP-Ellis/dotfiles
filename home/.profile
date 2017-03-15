if [ ! -d "$TMPDIR" -o "$TMPDIR" = "/tmp" ]; then
    export TMPDIR="/tmp/$USER"
    mkdir -p -m 700 "$TMPDIR"
fi

# Add directories from ~/.local to environment
[ -d $HOME/.local/bin ] && export PATH="$HOME/.local/bin:$PATH"
[ -d $HOME/.local/include ] && export CPATH="$HOME/.local/include:$CPATH" \
                            && export C_INCLUDE_PATH="$HOME/.local/include:$C_INCLUDE_PATH" \
                            && export CPLUS_INCLUDE_PATH="$HOME/.local/include:$CPLUS_INCLUDE_PATH" \
                            && export OBJC_INCLUDE_PATH="$HOME/.local/include:$OBJC_INCLUDE_PATH"
[ -d $HOME/.local/lib ] && export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

# Add directories from /scratch/$USER/local to environment
[ -d /scratch/$USER/local/bin ] && export PATH="/scratch/$USER/local/bin:$PATH"
[ -d /scratch/$USER/local/include ] && export CPATH="/scratch/$USER/local/include:$CPATH" \
                                    && export C_INCLUDE_PATH="/scratch/$USER/local/include:$C_INCLUDE_PATH" \
                                    && export CPLUS_INCLUDE_PATH="/scratch/$USER/local/include:$CPLUS_INCLUDE_PATH" \
                                    && export OBJC_INCLUDE_PATH="/scratch/$USER/local/include:$OBJC_INCLUDE_PATH"
[ -d /scratch/$USER/local/lib ] && export LD_LIBRARY_PATH="/scratch/$USER/local/lib:$LD_LIBRARY_PATH"

# Multirust support
[ -d $HOME/.cargo/bin ] && export PATH="$HOME/.cargo/bin:$PATH"

# gpg-agent and ssh
[ -d $HOME/.config/gnupg ] && export GNUPGHOME="$HOME/.config/gnupg"
[ -S "/run/user/1000/gnupg/d.ktgehwewyo8sebu4d9w5kak4/S.gpg-agent.ssh" ] && export SSH_AUTH_SOCK="/run/user/1000/gnupg/d.ktgehwewyo8sebu4d9w5kak4/S.gpg-agent.ssh"

export XDG_DOWNLOAD_DIR="$TMPDIR/Downloads"
export XDG_DESKTOP_DIR="$HOME/"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_MUSIC_DIR="$HOME/Media/Music"
export XDG_PICTURES_DIR="$HOME/Media/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Documents/Public"
export XDG_TEMPLATES_DIR="$HOME/Documents/Templates"
export XDG_VIDEOS_DIR="$HOME/Media/Videos"
