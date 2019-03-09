#!/usr/bin/zsh

# As yes or no and return true or false
# Usage:
# yes_or_no <statement> <default>
#
# If no default is given, one of y/n must be provided.
yes_or_no() {
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

        unset REPLY
        local compcontext='yn:yes or no:(y n)'
        vared -cp "$(tput bold)$1 [$prompt]$(tput sgr0) " REPLY

        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}
