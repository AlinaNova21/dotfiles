#!/usr/bin/env bash
GUI=n
APT=apt-transport-https zsh git nano xstow tmux htop curl wget

read -p "Install GUI stuff?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	APT="$APT feh pnmixer nitrogen parcellite"
fi

apt update

apt install -y $APT

# http://ags131repo.s3-website-us-east-1.amazonaws.com/repo.ags131.com.gpg.key
# 'deb https://s3.amazonaws.com/ags131repo/debian main main'
pushd $HOME
	mkdir -p src
	if [[ ! -e src/dotfiles ]]
	then
		git clone https://github.com/ags131/dotfiles src/dotfiles
	done

	chsh $USER /bin/zsh
	git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
	git clone https://github.com/milkbikis/powerline-shell src/powerline-shell

	cp src/dotfiles/files/powerline-config.py src/powerline-shell/config.py

	pushd src/powerline-shell
		./install.py
		popd

		rm .bashrc .bash_logout
		find -L . -maxdepth 1 -xdev -type l -delete
		grep -q -F .npmrc || echo prefix=$HOME/npm-global >> .npmrc
		mkdir -p bin
	popd
popd

pushd $HOME/src/dotfiles
	xstow -t $HOME bash zsh git shell tmux jshint i3
popd

# if [ ! -e ~/src/dotfiles ]; then
# sudo apt-get update
# sudo apt-get install -y software-properties-common git python-pip libffi-dev and libssl-dev
# #sudo apt-add-repository -y ppa:ansible/ansible
# #sudo apt-get update
# #sudo apt-get install -y ansible
# sudo pip install markupsafe ansible --upgrade

# sudo mkdir -p /etc/ansible
# sudo dd of=/etc/ansible/hosts << EOT
# [local]
# localhost
# EOT
# fi

# if [ ! -e ~/src/dotfiles ]; then
#   mkdir ~/src
#   git clone --recursive https://github.com/ags131/dotfiles ~/src/dotfiles
# fi

# ansible-playbook ~/src/dotfiles/ansible/playbook.yml -c local -K
