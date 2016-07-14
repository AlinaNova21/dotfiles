# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$HOME/npm-global/bin:$HOME/bin:$PATH:/usr/games

export PATH
EDITOR=nano
export EDITOR

. ~/bin/tmuxinator.bash
