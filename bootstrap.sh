#!/usr/bin/env bash

if [ ! -e ~/src/dotfiles ]; then
sudo apt-get update
sudo apt-get install -y software-properties-common git python-pip
#sudo apt-add-repository -y ppa:ansible/ansible
#sudo apt-get update
#sudo apt-get install -y ansible
sudo pip install ansible -y

sudo dd of=/etc/ansible/hosts << EOT
[local]
localhost
EOT
fi

if [ ! -e ~/src/dotfiles ]; then
  mkdir ~/src
  git clone --recursive https://github.com/ags131/dotfiles ~/src/dotfiles
fi

ansible-playbook ~/src/dotfiles/ansible/playbook.yml -c local -K
