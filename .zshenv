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
typeset -U path

## Update various paths if they exist.
[[ -d "$HOME/.local/bin" ]] && path=( "$HOME/.local/bin" $path )
[[ -d "$HOME/.local/sbin" ]] && path=( "$HOME/.local/sbin" $path )

[[ -d "$HOME/.local/lib" ]] && ld_library_path=( "$HOME/.local/lib" $LD_LIBRARY_PATH )

## Applications
################################################################################

export EDITOR='emacsclient -t'
export VISUAL='emacsclient -c -a emacs'
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
    [[ -d "$HOME/src/rust/rust/src" ]] && export RUST_SRC_PATH="$HOME/src/rust/rust/src"
    [[ -d "$HOME/.cargo" ]] && export CARGO_HOME="$HOME/.cargo"
fi
