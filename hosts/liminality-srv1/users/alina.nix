{ flake, ... }:
{
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme = {
    docker.enable = true;
    dotfiles.enable = true;
    nvim.enable = true;
  };
}
