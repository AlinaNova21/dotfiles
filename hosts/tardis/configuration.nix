{
  flake,
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.rescue
    flake.modules.common.nix
  ];

  networking.hostName = "tardis";
  facter.reportPath = ./facter.json;

  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/sda"; # 32G OS disk
    };
    rescue.enable = true;
    tailscale.enable = true;
  };

  # Import existing tank pool (vdevs identified by GUID - scan all of /dev)
  # TrueNAS stores vdev members by GUID, not by-id paths
  boot.zfs.extraPools = ["tank"];
  boot.zfs.devNodes = mkForce "/dev";

  # Media user/group matching TrueNAS uid/gid 1000 (owner of tank files)
  users.users.media = {
    uid = 1000;
    group = "media";
    isSystemUser = true;
    description = "NFS/media file owner";
  };
  users.groups.media.gid = 1000;

  # NFS server - replicating TrueNAS exports
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

  # Samba for Windows clients
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

  # Firewall: NFS + Samba ports
  networking.firewall = {
    allowedTCPPorts = [2049 111 445 139];
    allowedUDPPorts = [2049 111 137 138];
  };

  # Ensure NFS starts after ZFS pool is imported and mounted
  systemd.services.nfs-server.after = ["zfs-mount.service" "zfs-import-tank.service"];
  systemd.services.nfs-server.requires = ["zfs-mount.service"];

  # Persist Samba state across reboots (ephemeral root)
  environment.persistence."/persist".directories = [
    "/var/lib/samba"
  ];

  # VM testing: attach a second disk and initialize a test tank pool
  virtualisation.vmVariant = {
    virtualisation.qemu.options = [
      "-drive file=/tmp/tardis-tank-test.qcow2,if=virtio,format=qcow2,size=20G"
    ];
    systemd.services.init-test-tank = {
      description = "Initialize test ZFS tank pool";
      wantedBy = ["multi-user.target"];
      before = ["zfs-mount.service" "nfs-server.service"];
      script = ''
        if ! zpool list tank 2>/dev/null; then
          zpool create -f -m /mnt/tank tank /dev/vdb
          zfs create tank/media
          zfs create tank/media/movies
          zfs create tank/media/movies/anime
          zfs create tank/media/movies/hd
          zfs create tank/media/movies/uhd
          zfs create tank/media/tv
          zfs create tank/media/tv/anime
          zfs create tank/media/tv/hd
          zfs create tank/media/tv/kids
          zfs create tank/media/tv/old
          zfs create tank/downloads
          zfs create tank/downloads/sabnzbd
          zfs create tank/backups
          zfs create tank/media/photos
          zfs create tank/media/music
          zfs create tank/media/storage
          zfs create tank/cache
          zfs create tank/users
          zfs create tank/users/alina
          zfs create tank/vms
          zfs create tank/apps
          zfs create tank/apps/traefik
        fi
      '';
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
    };
  };

  system.stateVersion = "25.05";
}
