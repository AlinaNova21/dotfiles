{
  flake,
  pkgs,
  perSystem,
  system,
  ...
}:
pkgs.lib.mkIf (pkgs.stdenv.isLinux)
flake
.nixosConfigurations
.installer
.config
.system
.build
.diskoImagesScript
