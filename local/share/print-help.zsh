#!/bin/sh

# check if messages are to be printed using color
unset ALL_OFF BOLD BLUE GREEN RED YELLOW
if [[ -t 2 && ! $USE_COLOR = "n" ]]; then
	  # prefer terminal safe colored and bold text when tput is supported
	  if tput setaf 0 &>/dev/null; then
		    ALL_OFF="$(tput sgr0)"
		    BOLD="$(tput bold)"
		    BLUE="${BOLD}$(tput setaf 4)"
		    GREEN="${BOLD}$(tput setaf 2)"
		    RED="${BOLD}$(tput setaf 1)"
		    YELLOW="${BOLD}$(tput setaf 3)"
	  else
		    ALL_OFF="\e[1;0m"
		    BOLD="\e[1;1m"
		    BLUE="${BOLD}\e[1;34m"
		    GREEN="${BOLD}\e[1;32m"
		    RED="${BOLD}\e[1;31m"
		    YELLOW="${BOLD}\e[1;33m"
	  fi
fi
readonly ALL_OFF BOLD BLUE GREEN RED YELLOW

function msg {
	  local mesg=$1; shift
	  printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

function warning {
	  local mesg=$1; shift
	  printf "${YELLOW}==> WARNING:${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

function error {
	  local mesg=$1; shift
	  printf "${RED}==> ERROR:${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

function title {
    if (($# != 1 )) ; then
        warning "'title' supports only one argument."
    fi

    local mesg=$1; shift
    local len=$(printf $mesg | wc -m)

	  printf "${BOLD}${mesg}${ALL_OFF}\n" >&2
    printf "${BOLD}"
    for i in {1..$len}; do
        printf "="
    done
    printf "${ALL_OFF}\n"
}
