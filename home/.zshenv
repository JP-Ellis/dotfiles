################################################################################
## Defines environment variables.
################################################################################

## Source .profile
[[ -e "$HOME/.profile" ]] && source "$HOME/.profile"

## Paths
################################################################################

## Tie together the variables (-T), and export the scalar (-x) whilst removing
## duplicates (-U).  Note that $PATH need not be tied and exported.
typeset -xTU LD_LIBRARY_PATH ld_library_path
typeset -xTU CPATH cpath
typeset -U path

## Update various paths if they exist.
[[ -d "$HOME/.local/bin" ]] && path=( "$HOME/.local/bin" $path )
[[ -d "$HOME/.local/sbin" ]] && path=( "$HOME/.local/sbin" $path )

[[ -d "$HOME/.local/lib" ]] && ld_library_path+="$HOME/.local/lib"
[[ -d "$HOME/.local/include" ]] && cpath+="$HOME/.local/include"

# Multirust support
[[ -d $HOME/.cargo/bin ]] && export path=( "$HOME/.cargo/bin" $path)

# Custom Rust completions
[[ -d $HOME/.zfunc ]] && fpath+="$HOME/.zfunc"


## Applications
################################################################################

export EDITOR='ec'
export VISUAL='ec'
export PAGER='less'
export BROWSER='chrome'

## Temporary Files
################################################################################

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$USER"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi

## Caro / Rust
################################################################################

if (( $+commands[rustc] )); then
    [[ -d "/usr/src/rust/src" ]] && export RUST_SRC_PATH="/usr/src/rust/src"
    [[ -d "/usr/local/src/rust/src" ]] && export RUST_SRC_PATH="/usr/local/src/rust/src"
    [[ -d "$HOME/.cargo" ]] && export CARGO_HOME="$HOME/.cargo"
fi

## GPG-Agent
################################################################################

[[ -S "$(gpgconf --list-dirs | sed -n 's|agent-socket:||p').ssh" ]] && export SSH_AUTH_SOCK="$(gpgconf --list-dirs | sed -n 's|agent-socket:||p').ssh"
