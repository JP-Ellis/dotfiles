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

# Custom Rust completions
[[ -d $HOME/.zfunc ]] && fpath+="$HOME/.zfunc"


## Applications
################################################################################

export EDITOR='vim'
export VISUAL='emacs'
export PAGER='less'
export BROWSER='firefox-developer-edition'

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

export PYTHONPYCACHEPREFIX="$HOME/.cache/python"

## Caro / Rust
################################################################################

if (( $+commands[rustc] )); then
    export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
    [[ -d "$HOME/.cargo" ]] && export CARGO_HOME="$HOME/.cargo"
fi

## GPG-Agent
################################################################################

[[ -S "$(gpgconf --list-dirs | sed -n 's|agent-socket:||p').ssh" ]] && export SSH_AUTH_SOCK="$(gpgconf --list-dirs | sed -n 's|agent-socket:||p').ssh"
