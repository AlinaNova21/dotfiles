{
  flake,
  pkgs,
  ...
}:
if !pkgs.stdenv.isLinux
then null
else
  flake
  .nixosConfigurations
  .installer
  .config
  .system
  .build
  .isoImage
