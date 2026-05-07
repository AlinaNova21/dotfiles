{
  flake,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    flake.nixosModules.default
    flake.modules.common.nix
  ];

  networking.hostName = "tardis";
  facter.reportPath = ./facter.json;

  determinate.enable = lib.mkForce false;
  nix.package = lib.mkForce pkgs.nix;
  nix.settings.experimental-features = lib.mkForce "nix-command flakes";

  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/sda";
    };
  };

  boot.zfs.extraPools = ["tank"];
  boot.zfs.forceImportAll = true;

  users.users.media = {
    uid = 1000;
    group = "media";
    isSystemUser = true;
    description = "NFS/media file owner";
  };
  users.groups.media.gid = 1000;

  services.nfs.server = {
    enable = true;
    exports = ''
      "/mnt/tank/media/movies/anime"    192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/movies/hd"       192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/movies/old"      192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/movies/uhd"      192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/tv/anime"        192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/tv/hd"           192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/tv/kids"         192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/tv/old"          192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/tv/uhd"          192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/downloads/sabnzbd"     192.168.2.0/24(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/backups"               192.168.2.0/24(rw,insecure,no_subtree_check)
      "/mnt/tank/media/photos"          192.168.2.0/24(rw,insecure,no_subtree_check) 10.0.0.0/8(rw,insecure,no_subtree_check)
      "/mnt/tank/vms/xcp-ng"           192.168.2.0/24(rw,insecure,no_subtree_check)
      "/mnt/tank/cache"                 *(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/storage"         *(rw,insecure,no_subtree_check)
      "/mnt/tank/media/music"           *(rw,insecure,no_subtree_check)
      "/mnt/tank/apps"                  *(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/apps/traefik"          *(rw,anonuid=1000,anongid=1000,all_squash,insecure,no_subtree_check)
      "/mnt/tank/media/storage/seafile" *(rw,no_root_squash,insecure,subtree_check)
    '';
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "tardis";
        "security" = "user";
        "map to guest" = "Bad User";
        "guest account" = "media";
      };
      media = {
        "path" = "/mnt/tank/media";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "media";
        "force group" = "media";
      };
    };
  };
  services.samba-wsdd.enable = true;

  networking.firewall = {
    allowedTCPPorts = [2049 111 445 139];
    allowedUDPPorts = [2049 111 137 138];
  };

  systemd.services.nfs-server.after = ["zfs-mount.service" "zfs-import-tank.service"];
  systemd.services.nfs-server.requires = ["zfs-mount.service"];

  virtualisation.vmVariant = {
    nix.package = lib.mkForce pkgs.nix;
    determinate.enable = lib.mkForce false;
    nix.settings.experimental-features = lib.mkForce "nix-command flakes";
  };

  virtualisation.vmVariantWithDisko = {
    nix.package = lib.mkForce pkgs.nix;
    determinate.enable = lib.mkForce false;
    nix.settings.experimental-features = lib.mkForce "nix-command flakes";
    virtualisation.fileSystems."/persist".neededForBoot = true;

    # Dotfiles clone fails in VM (no SSH key) and kills HM activation
    home-manager.users.alina.acme.dotfiles.enable = lib.mkForce false;

    disko.devices = {
      disk.tank = {
        type = "disk";
        imageSize = "20G";
        device = "/dev/vdb";
        content = {
          type = "zfs";
          pool = "tank";
        };
      };
      zpool.tank = {
        type = "zpool";
        options.cachefile = "none";
        rootFsOptions = {
          compression = "zstd";
          mountpoint = "none";
        };
        datasets = {
          media                = { type = "zfs_fs"; options.mountpoint = "none"; };
          "media/movies"       = { type = "zfs_fs"; options.mountpoint = "none"; };
          "media/movies/anime" = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/movies/anime"; };
          "media/movies/hd"    = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/movies/hd"; };
          "media/movies/uhd"   = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/movies/uhd"; };
          "media/tv"           = { type = "zfs_fs"; options.mountpoint = "none"; };
          "media/tv/anime"     = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/tv/anime"; };
          "media/tv/hd"        = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/tv/hd"; };
          "media/tv/kids"      = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/tv/kids"; };
          "media/tv/old"       = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/tv/old"; };
          downloads            = { type = "zfs_fs"; options.mountpoint = "none"; };
          "downloads/sabnzbd"  = { type = "zfs_fs"; mountpoint = "/mnt/tank/downloads/sabnzbd"; };
          backups              = { type = "zfs_fs"; mountpoint = "/mnt/tank/backups"; };
          "media/photos"       = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/photos"; };
          "media/music"        = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/music"; };
          "media/storage"      = { type = "zfs_fs"; mountpoint = "/mnt/tank/media/storage"; };
          cache                = { type = "zfs_fs"; mountpoint = "/mnt/tank/cache"; };
          users                = { type = "zfs_fs"; options.mountpoint = "none"; };
          "users/alina"        = { type = "zfs_fs"; mountpoint = "/mnt/tank/users/alina"; };
          vms                  = { type = "zfs_fs"; mountpoint = "/mnt/tank/vms"; };
          apps                 = { type = "zfs_fs"; options.mountpoint = "none"; };
          "apps/traefik"       = { type = "zfs_fs"; mountpoint = "/mnt/tank/apps/traefik"; };
        };
      };
    };
  };

  system.stateVersion = "25.05";
}
