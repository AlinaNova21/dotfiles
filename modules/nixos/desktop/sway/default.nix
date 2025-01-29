{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./foot.nix
    ./sway.nix
    ./waybar.nix
  ];
}
