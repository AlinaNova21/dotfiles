{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.acme.disko;
in {
  imports = [
    inputs.disko.nixosModules.disko
  ];
  options = {
    acme.disko = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable disko";
      };
      rootDevice = lib.mkOption {
        type = lib.types.str;
        description = "Drive to install to";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    fileSystems = {
      "/var/log".neededForBoot = true;
      "/persist".neededForBoot = true;
    };
    virtualisation.vmVariantWithDisko = {
      virtualisation.fileSystems."/persist".neededForBoot = true;
      virtualisation.graphics = false;
      services.tailscale.authKeyParameters.ephemeral = true;
      # For running VM on macos: https://www.tweag.io/blog/2023-02-09-nixos-vm-on-macos/
      # virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    };
    # boot.initrd.postDeviceCommands = lib.mkAfter ''
    #   zfs rollback -r rpool/local/root@blank
    # '';
    disko.devices = {
      disk = {
        root = {
          type = "disk";
          imageSize = "4G";
          device = cfg.rootDevice;
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };
        };
      };
      zpool = {
        rpool = {
          type = "zpool";
          mode = "";
          # Workaround: cannot import 'zroot': I/O error in disko tests
          options.cachefile = "none";
          rootFsOptions = {
            compression = "zstd";
            mountpoint = "none";
          };

          datasets = {
            local = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            safe = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            "local/nix" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/nix";
            };
            "local/tmp" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/tmp";
            };
            "local/log" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/var/log";
            };
            "safe/home" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/home";
            };
            "safe/persist" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/persist";
            };
          };
        };
      };
      nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "defaults"
            "size=2G"
            "mode=755"
          ];
        };
      };
    };
  };
}
