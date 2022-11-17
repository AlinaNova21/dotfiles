export PATH=$HOME/bin:$HOME/npm-global/bin:/usr/local/bin:/usr/local/go/bin:/home/alina/.gem/ruby/2.6.0/bin:$PATH:$HOME/.krew/bin
export ZSH=$HOME/.oh-my-zsh
export GPG_TTY=`tty`

ZSH_THEME="starship"
# SPACESHIP_EXIT_CODE_SHOW=true
# SPACESHIP_BATTERY_SHOW=false
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.zsh_custom

plugins=(git kubectl kubectx httpie lol node nvm sudo zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
# User configuration

export ZSH_THEME_TERM_TAB_TITLE_IDLE="%m: %15<..<%~%<<"


export editor="nano"
export EDITOR=$EDITOR
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
#export TERMINAL="kitty"

alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias git="hub"

if command -v exa >/dev/null 2>&1 then
do
  alias ls="exa"
  alias ll="exa --long"
fi

#alias nano="echo Use micro!; # "

function fixTERM() {
  infocmp | ssh $@ "tic -"
}

function getmicro() {
  ssh $@ "mkdir -p ~/bin; cd ~/bin; curl -L getmic.ro | bash"
}

setopt noautomenu 
setopt nomenucomplete

###-tns-completion-start-###
if [ -f $HOME/.tnsrc ]; then 
    source $HOME/.tnsrc 
fi
###-tns-completion-end-###

#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/alina/google-cloud-sdk/path.zsh.inc' ]; then source '/home/alina/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/alina/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/alina/google-cloud-sdk/completion.zsh.inc'; fi

#. "/home/alina/.acme.sh/acme.sh.env"
isSSH=$( [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] )
#[[ -n "$DISPLAY" ]] && [[ "$TERM" -eq "xterm-kitty" ]] && [[ ! $isSSH ]] && alias ssh="kitty +kitten ssh"

command -v yarn >/dev/null 2>&1 && export PATH=$(yarn global dir)/node_modules/.bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[ -z "$GOPATH" ] && export GOPATH=$HOME/go
[ ! -z "$GOPATH" ] && export PATH=$PATH:$GOPATH/bin
# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"

# add Pulumi to the PATH
export PATH=$PATH:$HOME/.pulumi/bin
