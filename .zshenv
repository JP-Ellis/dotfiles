################################################################################
#
# Defines environment variables.
#
################################################################################

# Source .profile
[[ -e $HOME/.profile ]] && source $HOME/.profile

# Paths
################################################################################

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Tie together the variables (-T), and export the scalar (-x) whilst removing duplicates (-U).  Note that $PATH need not be tied and exported.
typeset -U path
typeset -xTU LD_LIBRARY_PATH ld_library_path
typeset -xTU RUST_SRC_PATH rust_src_path

path=(
    ~/.local/bin
    $path
    /usr/local/{bin,sbin}
)

rust_src_path=(
    ~/src/rust/rust/src
)

ld_library_path=(
    ~/.local/lib
    $LD_LIBRARY_PATH
)


# Editors
################################################################################

export EDITOR='emacsclient -t'
export VISUAL='emacsclient -c -a emacs'
export PAGER='less'


# Browser
################################################################################

export BROWSER='chrome'


# Language
################################################################################

if [[ -z "$LANG" ]]; then
  export LANG='en_AU.UTF-8'
fi


# Temporary Files
################################################################################

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$USER"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi
