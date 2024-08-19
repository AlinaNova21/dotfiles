{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.google-cloud-sdk
    pkgs.d2
  ];
  programs.git = {
    userName = "Alina Shumann";
    userEmail = "alina.shumann@kyndryl.net";
  };
  programs.zsh.initExtra = "if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi";
}
