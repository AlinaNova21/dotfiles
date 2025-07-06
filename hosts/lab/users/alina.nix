{flake, pkgs, ...}: {
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
    ../nvim.nix
  ];
  acme.dev.enable = true;
  home.packages = with pkgs; [
    claude-code
  ];
}
