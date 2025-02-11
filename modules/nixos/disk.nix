{
  config,
  lib,
  ...
}: let
  cfg = config.acme.disk;
in
  with lib; {
    options.acme.disk = {
      enable = mkEnableOption "Enable manual disk configuration";
      efiPartition = mkOption {
        type = types.str;
        default = "/dev/sda1";
        description = ''
          The mount point for the EFI partition.
        '';
      };
      bootPartition = mkOption {
        type = types.str;
        default = "/dev/sda2";
        description = ''
          The mount point for the boot partition.
        '';
      };
      zfsPartition = mkOption {
        type = types.str;
        default = "/dev/sda3";
        description = ''
          The mount point for the ZFS partition.
        '';
      };
    };
    config = {
      fileSystems = {
        "/efi" = {
          device = cfg.efiPartition;
          neededForBoot = true;
          type = "filesystem";
          format = "vfat";
          mountOptions = ["umask=0077"];
        };
        "/boot" = {
          device = cfg.bootPartition;
          neededForBoot = true;
          type = "filesystem";
          format = "ext4";
          options = ["noatime"];
        };
        "/" = {
          device = cfg.zfsPartition;
          type = "zfs";
          options = [
            "defaults"
            "mode=755"
            "size=1G"
          ];
        };
        "/nix" = {
          device = "rpool/local/nix";
          type = "zfs";
        };
        "/tmp" = {
          device = "rpool/local/tmp";
          type = "zfs";
        };
        "/var/log" = {
          device = "rpool/local/log";
          type = "zfs";
        };
        "/home" = {
          device = "rpool/safe/home";
          type = "zfs";
        };
        "/persist" = {
          device = "rpool/safe/persist";
          type = "zfs";
        };
      };
    };
  }
