{
  lib,
  pkgs,
  sysConfig,
  ...
}: {
  imports = [
    ./desktop
    ./persistence.nix
  ];
  home.packages = with pkgs; [
    ethtool
    iperf
  ];
  acme = {
    desktop.enable = lib.mkIf sysConfig.acme.desktop.enable true;
  };
}
