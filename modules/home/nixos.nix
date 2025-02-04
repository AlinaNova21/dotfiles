{
  config,
  lib,
  pkgs,
  sysConfig,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf (!pkgs.stdenv.isDarwin) [
      ethtool
      iperf
    ];
  programs.zsh.shellAliases = {
    nixos-rebuild-switch = "pushd ${config.acme.dotfiles.path}; sudo nixos-rebuild switch --flake .; popd";
  };
}
