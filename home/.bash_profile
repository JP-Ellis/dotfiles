################################################################################
## Executes commands at login pre-bashrc.
################################################################################

if [[ -f "$HOME/.profile" ]]; then
    source "$HOME/.profile"
fi
