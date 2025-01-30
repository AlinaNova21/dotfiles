{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./home.nix
    ./nix.nix
  ];
}
