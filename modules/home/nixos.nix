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
}
