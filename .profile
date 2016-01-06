# Add ~/.local/bin to $PATH
[[ -d $HOME/.local/bin ]] && export PATH=$HOME/.local/bin:$PATH

# Multirust support
case "$(multirust show-default | sed -n -e 's/multirust: default toolchain: \(.*\)/\1/p')" in
    ("stable")
        [[ -d $HOME/.multirust/toolchains/stable/cargo/bin ]] && export PATH=$HOME/.multirust/toolchains/stable/cargo/bin:$PATH
        ;;
    ("beta")
        [[ -d $HOME/.multirust/toolchains/beta/cargo/bin ]] && export PATH=$HOME/.multirust/toolchains/beta/cargo/bin:$PATH
        ;;
    ("nightly")
        [[ -d $HOME/.multirust/toolchains/nightly/cargo/bin ]] && export PATH=$HOME/.multirust/toolchains/nightly/cargo/bin:$PATH
        ;;
esac

# Load SSH keys
if [[ -n "$XDG_RUNTIME_DIR" ]]; then
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
    for keyfile in $HOME/.ssh/id_*\.pub; do
        ssh-add -l | grep "${keyfile:s/.pub//}" &>/dev/null || ssh-add ${keyfile:s/.pub//} &>/dev/null
    done
fi
