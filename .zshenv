# Sourced for ALL zsh invocations (interactive, login, non-login, scripts).
# Keep minimal: PATH only. mise activation is via [bootstrap.mise_shell_activate]
# in .zshrc (mise-native), NOT here.
typeset -U path cdpath fpath manpath
path=("$HOME/.local/bin" $path)