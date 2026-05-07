{ flake, ... }:
{
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme = {
    docker.enable = true;
    server.enable = true;
  };
}
