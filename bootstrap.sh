#!/bin/bash
GUI=n
APT="apt-transport-https zsh git nano xstow tmux htop curl wget chsh"
UPDATE=n
STOWFILES=(bash zsh git shell tmux jshint i3 .zsh_custom)
STOWDIRS=".config bin"
ENSUREDIRS=(bin src .config)

[[ "$(basename $0)" == "dotfiles" ]] && UPDATE=y

if [[ "$UPDATE" == 'n' ]]
then
	read -p "Install GUI stuff?[n] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		APT="$APT feh pnmixer nitrogen parcellite xfce4-terminal i3wm lightdm rofi"
	fi
fi

sudo apt update
sudo apt install -y $APT

pushd $HOME
	for D in $ENSUREDIRS; do mkdir -p $D; done

	# Clone files	
	if [[ ! -e src/dotfiles ]]
	then
		git clone https://github.com/ags131/dotfiles src/dotfiles
	fi

	# Default shell
	chsh /bin/zsh

	# oh-my-zsh
	if [[ ! -e .oh-my-zsh ]]
	then
		git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
	fi
	
	if [[ $UPDATE == "n" ]]
	then
		echo Removing symlinks
		find -L . -maxdepth 1 -xdev -type l -delete
		ln -df $HOME/src/dotfiles/bootstrap.sh bin/dotfiles
		chmod +x bin/dotfiles
	fi
	echo Symlinking
	pushd src/dotfiles
		xstow -t $HOME $STOWFILES
		for D in $STOWDIRS
		do
			xstow -t $HOME/$D $D
		done
	popd
	curl -o - https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
popd

echo All Done
echo 
