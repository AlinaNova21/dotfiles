{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    # ./ags.nix
    ./fonts.nix
    ./greetd.nix
    ./hyprland.nix
  ];
}
