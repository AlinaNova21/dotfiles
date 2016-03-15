#!/bin/bash
[ -z "$PS1" ] && return
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

. ~/.bashcl
. ~/.bashpr

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -a --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/.bashpost ]; then
    . ~/.bashpost
fi

function netup()
{
	if iscyg; then
		ping -q -w 1 -c 1 google.com > /dev/null && return 0 || return 1
	else
		ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && return 0 || return 1;
	fi
}

function iscyg()
{
	 uname -s | grep CYGWIN > /dev/null && return 0 || return 1
}

mkdir -p ~/bin/

function bashup()
{
	cd ~
	tar cf bash.tgz .bashrc .bashcl .bashpr .bash_profile
	md5sum .bashrc .bashcl .bashpr .bash_profile > bash.md5
	scp bash.tgz bash.md5 root@down.ags131.us:/var/www/bash/
	rm bash.tgz
	echo "Bash scripts uploaded"
}

function bashdown()
{
	cd ~
	wget -q http://down.ags131.us/bash/bash.tgz -O - | tar xf -
	exec bash
}

function bashcheck()
{
	cd ~
	wget -q http://down.ags131.us/bash/bash.md5 -O - | md5sum --status -c - && return 0 || return 1
}

function key()
{
	cd ~
	HOST=$1
	PORT=22
	[[ $2 ]] && PORT=$2
	echo Installing Key...
	cat .ssh/id_rsa.pub | ssh $HOST -p$PORT "( mkdir .ssh; cat - >> .ssh/authorized_keys )" 2> /dev/null
	echo All done! Connecting now!
	ssh $HOST -p$PORT
}

function installScripts()
{
	HOST=$1
	PORT=22
	[[ $2 ]] && PORT=$2
	ssh $HOST -p$PORT "( cd ~; wget -q http://down.ags131.us/bash/bash.tgz -O - | tar xf - )"
	echo All Done!
	ssh $HOST -p$PORT
}

#(
#echo -n "Bash scripts are ";
#netup && bashcheck && echo "current" || echo "outdated"
#)

#Use ~/.bashpost for these!
#PATH=$PATH:$HOME/bin:/usr/games

#NO!
#fortune | cowsay


### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"


