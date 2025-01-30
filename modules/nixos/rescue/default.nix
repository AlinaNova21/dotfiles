{
  config,
  inputs,
  flake,
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
        inherit (specialArgs) inputs outputs flake;
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
  rescue = nixos [
    inputs.nixos-images.nixosModules.netboot-installer
    inputs.nixos-facter-modules.nixosModules.facter
    ./rescue.nix
    {
      nixpkgs.config.allowUnfree = true;
      facter.reportPath = config.facter.reportPath;
      networking.hostId = config.networking.hostId;
      netboot.squashfsCompression = "zstd -Xcompression-level 6";
    }
  ];
in {
  options = {
    acme.rescue = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable rescue system";
      };
      enableAlt = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable rescue system alternative";
      };
    };
  };
  config =
    lib.mkIf cfg.enable {
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
    }
    // lib.mkIf cfg.enableAlt {
      specialisation = {
        rescue = {
          inheritParentConfig = false;
          configuration = {modulesPath, ...}: {
            imports = [
              (modulesPath + "/profiles/base.nix")
              (modulesPath + "/profiles/installation-device.nix")
              # ../../nixos/default.nix
              ../../common/nix.nix
              ../openssh.nix # to set key paths
              # inputs.nixos-images.nixosModules.netboot-installer
              inputs.nixos-facter-modules.nixosModules.facter
              (args:
                import ./rescue.nix (args
                  // {
                    inherit pkgs flake;
                  }))
            ];
            nixpkgs.config.allowUnfree = true;
            boot.initrd.systemd.emergencyAccess = true;
            documentation.enable = false;
            documentation.man.man-db.enable = false;
            environment.systemPackages = [
              pkgs.nixos-install-tools
              pkgs.jq
              pkgs.rsync
              pkgs.nixos-facter
              pkgs.disko
            ];
            facter.reportPath = config.facter.reportPath;
            fileSystems = config.fileSystems;
            networking.hostId = config.networking.hostId;
            # netboot.squashfsCompression = "zstd -Xcompression-level 6";
            nixpkgs.hostPlatform = config.nixpkgs.hostPlatform;
            system.installer.channel.enable = false;
            system.stateVersion = config.system.stateVersion;
          };
        };
      };
    };
}
