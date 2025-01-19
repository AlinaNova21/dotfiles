{
  config,
  inputs,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  cfg = config.acme.rescue;
  nixpkgs = inputs.nixpkgs;
  nixos = configuration: let
    c = import (pkgs.path + "/nixos/lib/eval-config.nix") {
      specialArgs = {
        inherit (specialArgs) inputs outputs;
        sysConfig = config;
      };
      modules =
        [
          (
            {lib, ...}: {
              config.nixpkgs.pkgs = lib.mkDefault pkgs;
              config.nixpkgs.localSystem = lib.mkDefault pkgs.stdenv.hostPlatform;
            }
          )
        ]
        ++ (
          if builtins.isList configuration
          then configuration
          else [configuration]
        );
      system = null;
    };
  in
    c.config.system.build // c;

  netboot-installer = module: (nixos [
    module
    inputs.nixos-images.nixosModules.netboot-installer
    inputs.sops-nix.nixosModules.sops
    inputs.nixos-facter-modules.nixosModules.facter
  ]);
  rescue = netboot-installer ({...}: {
    imports = [
      ./rescue.nix
    ];
    facter.reportPath = config.facter.reportPath;
    networking.hostId = config.networking.hostId;
  });
in {
  options = {
    acme.rescue = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable rescue system";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    boot.loader.grub.extraEntries = ''
      menuentry "Nixos Installer" {
        linux ($drive1)/rescue-kernel init=${rescue.config.system.build.toplevel}/init ${toString rescue.config.boot.kernelParams}
        initrd ($drive1)/rescue-initrd
      }
    '';
    boot.loader.grub.extraFiles = {
      "rescue-kernel" = "${rescue.config.system.build.kernel}/bzImage";
      "rescue-initrd" = "${rescue.config.system.build.netbootRamdisk}/initrd";
    };
  };
}
