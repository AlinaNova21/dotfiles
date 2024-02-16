# now, simply add these two lines in your ~/.zshrc

# source antidote
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

ZSH_THEME="starship"
# SPACESHIP_EXIT_CODE_SHOW=true
# SPACESHIP_BATTERY_SHOW=false
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"