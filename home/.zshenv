################################################################################
## Defines environment variables.
################################################################################

## Source .profile
[[ -e "$HOME/.profile" ]] && source "$HOME/.profile"


## Paths
################################################################################

## Tie together the variables (-T), and export the scalar (-x) whilst removing
## duplicates (-U).  Note that $PATH need not be tied and exported.
typeset -U path
typeset -xTU CPATH cpath
typeset -xTU LD_LIBRARY_PATH ld_library_path
typeset -xTU LIBRARY_PATH library_path


## Zsh completions
################################################################################
[[ -d $HOME/.zfunc ]] && fpath+="$HOME/.zfunc"


## Temporary Files
################################################################################

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi
