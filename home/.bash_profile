################################################################################
## Executes commands at login pre-bashrc.
################################################################################

if [[ -f "$HOME/.profile" ]]; then
    source "$HOME/.profile"
fi


## If we have an interactive shell over ssh, load $HOME/.bashrc
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=remote/ssh
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) SESSION_TYPE=remote/ssh;;
    esac
fi

case $- in
    *i*)
        if [ "$SESSION_TYPE" = "remote/ssh" ]; then
            source "$HOME/.bashrc"
        fi
        ;;
    *)
        ;;
esac
