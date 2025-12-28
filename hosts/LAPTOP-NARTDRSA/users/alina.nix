{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme.dev.enable = true;
  acme.testing.enable = true;
  home.packages = with pkgs; [
    claude-code
    rustup
    pulumi
    pulumiPackages.pulumi-nodejs
  ];
}
