# Add ~/.local/bin to $PATH
[[ -d $HOME/.local/bin ]] && export PATH=$HOME/.local/bin:$PATH

# Load SSH keys
if [[ -n "$XDG_RUNTIME_DIR" ]]; then
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
    for keyfile in $HOME/.ssh/id_*\.pub; do
        ssh-add -l | grep "${keyfile:s/.pub//}" &>/dev/null || ssh-add ${keyfile:s/.pub//} &>/dev/null
    done
fi
