# shellcheck shell=zsh

## GPG agent — TTY and SSH socket
##
## GPG_TTY is read by gpg and sent to gpg-agent as OPTION ttyname= with each
## request, so pinentry-curses knows which terminal to open.  updatestartuptty
## sets the same info as gpg-agent's fallback for callers that don't send it
## (e.g. GUI tools, agents not invoked through the gpg binary).
export GPG_TTY=$TTY
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)
gpg-connect-agent updatestartuptty /bye &>/dev/null

## When connecting via SSH, drop a flag file so pinentry-auto uses curses
## instead of opening a GUI dialog on the unattended local display.
## A per-session file under a lock directory lets multiple concurrent SSH
## sessions coexist: the flag persists until every session has exited.
if [[ -n $SSH_CONNECTION ]]; then
    _pinentry_ssh_dir="${XDG_RUNTIME_DIR:-$HOME/.cache}/pinentry-ssh"
    _pinentry_ssh_flag="$_pinentry_ssh_dir/$$"
    mkdir -p "$_pinentry_ssh_dir"
    touch "$_pinentry_ssh_flag"
    trap 'rm -f "$_pinentry_ssh_flag"; rmdir "$_pinentry_ssh_dir" 2>/dev/null' EXIT
    unset _pinentry_ssh_dir _pinentry_ssh_flag
fi
