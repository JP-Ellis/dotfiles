# Define $SUSER as a shortened version of $USER if there's an '@' in it
export SUSER="${USER/@*}"

# Remove trailing slash from $TMPDIR if present
export TMPDIR="${TMPDIR%/}"
if [ ! -d "$TMPDIR" ]; then
    export TMPDIR="/tmp/$SUSER"
    mkdir -p -m 700 "$TMPDIR"
elif [ "$TMPDIR" = "/tmp" -o "$TMPDIR" = "/scratch" ]; then
    export TMPDIR="$TMPDIR/$SUSER"
    mkdir -p -m 700 "$TMPDIR"
fi

# Switch to ZSH if it is present
ZSH_SHELL=$(which zsh)
if [ -z "$PS1" -a $? -eq 0 -a -z "$ZSH_VERSION" ]; then
    export SHELL="$ZSH_SHELL"
    exec "$SHELL" -l
fi

# Give a warning if $TMPDIR might be readable to other users
if [ -n "$PS1" -a "$(stat --printf=%f $TMPDIR)" != "41c0" ]; then
    echo "TMPDIR may be readable to others." >&2
fi

# Add directories from ~/.local to environment
[ -d $HOME/.local/bin ] && export PATH="$HOME/.local/bin:$PATH"
[ -d $HOME/.local/include ] && export CPATH="$HOME/.local/include:$CPATH" \
                            && export C_INCLUDE_PATH="$HOME/.local/include:$C_INCLUDE_PATH" \
                            && export CPLUS_INCLUDE_PATH="$HOME/.local/include:$CPLUS_INCLUDE_PATH" \
                            && export OBJC_INCLUDE_PATH="$HOME/.local/include:$OBJC_INCLUDE_PATH"
[ -d $HOME/.local/lib ] && export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

# Add directories from /scratch/$SUSER/local to environment
[ -d /scratch/$SUSER/local/bin ] && export PATH="/scratch/$SUSER/local/bin:$PATH"
[ -d /scratch/$SUSER/local/include ] && export CPATH="/scratch/$SUSER/local/include:$CPATH" \
                                    && export C_INCLUDE_PATH="/scratch/$SUSER/local/include:$C_INCLUDE_PATH" \
                                    && export CPLUS_INCLUDE_PATH="/scratch/$SUSER/local/include:$CPLUS_INCLUDE_PATH" \
                                    && export OBJC_INCLUDE_PATH="/scratch/$SUSER/local/include:$OBJC_INCLUDE_PATH"
[ -d /scratch/$SUSER/local/lib ] && export LD_LIBRARY_PATH="/scratch/$SUSER/local/lib:$LD_LIBRARY_PATH"

# Rust support
if [ -d $HOME/.cargo ] ; then
    export CARGO_HOME="$HOME/.cargo"
    export PATH="$HOME/.cargo/bin:$PATH"
fi
if [ -d $HOME/.rustup ] ; then
    export RUSTUP_HOME="$HOME/.rustup"
fi
if [ -d /scratch/$SUSER/local/rust/cargo ] ; then
    export CARGO_HOME="/scratch/$SUSER/local/rust/cargo"
    export PATH="/scratch/$SUSER/local/rust/cargo/bin:$PATH"
fi
if [ -d /scratch/$SUSER/local/rust/rustup ] ; then
    export RUSTUP_HOME="/scratch/$SUSER/local/rust/rustup"
fi

# gpg-agent and ssh
[ -d $HOME/.config/gnupg ] && export GNUPGHOME="$HOME/.config/gnupg"
[ -S "/run/user/1000/gnupg/d.ktgehwewyo8sebu4d9w5kak4/S.gpg-agent.ssh" ] && export SSH_AUTH_SOCK="/run/user/1000/gnupg/d.ktgehwewyo8sebu4d9w5kak4/S.gpg-agent.ssh"

# XDG directories
export XDG_DOWNLOAD_DIR="$TMPDIR/Downloads"
export XDG_DESKTOP_DIR="$HOME/"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_MUSIC_DIR="$HOME/Media/Music"
export XDG_PICTURES_DIR="$HOME/Media/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Documents/Public"
export XDG_TEMPLATES_DIR="$HOME/Documents/Templates"
export XDG_VIDEOS_DIR="$HOME/Media/Videos"
