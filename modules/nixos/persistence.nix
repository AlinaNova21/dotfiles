{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  config = {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
      ];
      files = [
        "/etc/adjtime"
        "/etc/machine-id"
        "/etc/zfs/zpool.cache"
      ];
    };
  };
}
