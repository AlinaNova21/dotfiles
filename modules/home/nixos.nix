{
  config,
  lib,
  pkgs,
  sysConfig,
  ...
}: {
  home.packages = with pkgs;
    mkIf (!pkgs.stdenv.isDarwin) [
      ethtool
      iperf
    ];
}
