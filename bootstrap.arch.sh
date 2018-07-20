#!/bin/bash
GUI=n
PACMAN="zsh git nano stow tmux htop curl wget dstat"
UPDATE=n
STOWFILES=(bash zsh git shell tmux jshint i3 .zsh_custom)
STOWDIRS=".config .zsh_custom bin"
ENSUREDIRS=(bin src .config)

[[ "$(basename $0)" == "dotfiles" ]] && UPDATE=y

if [[ "$UPDATE" == 'n' ]]
then
	read -p "Install GUI stuff?[n] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		PACMAN="$PACMAN feh nitrogen parcellite xfce4-terminal i3 lightdm rofi i3blocks acpi"
	fi
fi

xstow=stow

#sudo apt update
#sudo apt install -y $APT
sudo pacman -S $PACMAN
exit

pushd $HOME
	for D in $ENSUREDIRS; do mkdir -p $D; done

	# Clone files	
	if [[ ! -e src/dotfiles ]]
	then
		git clone https://github.com/ags131/dotfiles src/dotfiles
	fi

	if [[ ! -e src/i3blocks-contrib ]]
	then
		git clone https://github.com/vivien/i3blocks-contrib src/i3blocks-contrib
	fi

	# Default shell
	# chsh /bin/zsh

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
		xstow -R -t $HOME $STOWFILES
		for D in $STOWDIRS
		do
			xstow -R -t $HOME/$D $D
		done
		mkdir -p $HOME/.local/share/fonts
		xstow -R -t $HOME/.local/share/fonts fonts
		fc-cache -fv
	popd
	curl -o - https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
popd

echo All Done
echo 
