#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]
then
	sudo $0 $@
	exit
fi


GUI=n
APT="apt-transport-https zsh git nano xstow tmux htop curl wget"
UPDATE=n

[[ "$(basename $0)" == "dotfiles" ]] && UPDATE=y

if [[ "$UPDATE" == 'n' ]]
then
	read -p "Install GUI stuff?[n] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		APT="$APT feh pnmixer nitrogen parcellite"
	fi
fi

apt update

apt install -y $APT

# http://ags131repo.s3-website-us-east-1.amazonaws.com/repo.ags131.com.gpg.key
# 'deb https://s3.amazonaws.com/ags131repo/debian main main'
pushd $HOME
	mkdir -p bin
	mkdir -p src
	if [[ ! -e src/dotfiles ]]
	then
		git clone https://github.com/ags131/dotfiles src/dotfiles
	fi

	usermod -s /bin/zsh $USER

	if [[ ! -e .oh-my-zsh ]]
	then
		git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
	fi
	if [[ ! -e src/powerline-shell ]]
	then
		git clone https://github.com/milkbikis/powerline-shell src/powerline-shell
		cp src/dotfiles/files/powerline-config.py src/powerline-shell/config.py

		pushd src/powerline-shell
			./install.py
		popd
	fi
	rm -v .bashrc .bash_logout
	if [[ $UPDATE == "n" ]]
	then
		echo Removing symlinks
		find -L . -maxdepth 1 -xdev -type l -delete
		cp src/dotfiles/bootstrap.sh bin/dotfiles
		chmod +x bin/dotfiles
	fi
	echo Setting NPM prefix
	grep -q -F 'prefix=' .npmrc || echo prefix=$HOME/npm-global >> .npmrc
	echo Symlinking
	pushd src/dotfiles
		xstow -t $HOME bash zsh git shell tmux jshint i3
		xstow -t $HOME/.config .config/*
	popd
popd

echo All Done
echo 
