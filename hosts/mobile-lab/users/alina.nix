{flake, ...}: {
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme.desktop.enable = true;
  acme.dev.enable = true;
}
