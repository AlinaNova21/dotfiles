{ pkgs, ...}: {
  imports = [
    # ./desktop
    ./persistence.nix
  ];
  home.packages = with pkgs; [
    ethtool
    iperf
}
