#!/bin/bash
# ssh-keygen -A -f tests
key=$(nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age')
sed -i 's/\&server_testing .*$/\&server_testing '$key'/' .sops.yaml
