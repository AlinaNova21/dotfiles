# Sourced for LOGIN shells (e.g. terminal emulator login + ssh).
# fpath / completion setup, plus login-shell-specific init.
typeset -U path cdpath fpath manpath

# zsh function path + completions (compinit autoload).
autoload -Uz compinit && compinit -i