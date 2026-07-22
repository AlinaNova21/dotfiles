{
  flake,
  pkgs,
  ...
}: {
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme.dev.enable = true;
  acme.tools.ai.enable = true;
}
