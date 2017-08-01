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
		APT="$APT feh pnmixer nitrogen parcellite xfce4-terminal i3wm lightdm"
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
	#if [[ ! -e src/powerline-shell ]]
	#then
	#	git clone https://github.com/milkbikis/powerline-shell src/powerline-shell
	#	cp src/dotfiles/files/powerline-config.py src/powerline-shell/config.py
    #
	#	pushd src/powerline-shell
	#		./install.py
	#	popd
	#fi
	ZSH_CUSTOM=~/.oh-my-zsh/custom
	mkdir -p $ZSH_CUSTOM/themes
	curl -o $ZSH_CUSTOM/themes/spaceship.zsh-theme https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/spaceship.zsh
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
	rm -v .bashrc .bash_logout
	if [[ $UPDATE == "n" ]]
	then
		echo Removing symlinks
		find -L . -maxdepth 1 -xdev -type l -delete
		ln -df $HOME/src/dotfiles/bootstrap.sh bin/dotfiles
		chmod +x bin/dotfiles
	fi
	echo Setting NPM prefix
	grep -q -F 'prefix=' .npmrc || echo prefix=$HOME/npm-global >> .npmrc
	echo Symlinking
	pushd src/dotfiles
		xstow -t $HOME bash zsh git shell tmux jshint i3
		xstow -t $HOME/.config .config
		xstow -t $HOME/bin bin
	popd
popd

echo All Done
echo 
