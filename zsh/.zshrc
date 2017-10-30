export PATH=$HOME/bin:$HOME/npm-global/bin:/usr/local/bin:/usr/local/go/bin:$PATH
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"
SPACESHIP_EXIT_CODE_SHOW=true
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.zsh_custom

plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

export editor="nano"
export TERMINAL="xfce4-terminal"

alias zshconfig="subl ~/.zshrc"
alias ohmyzsh="subl ~/.oh-my-zsh"
alias git="hub"

setopt noautomenu 
setopt nomenucomplete

###-tns-completion-start-###
if [ -f $HOME/.tnsrc ]; then 
    source $HOME/.tnsrc 
fi
###-tns-completion-end-###

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
