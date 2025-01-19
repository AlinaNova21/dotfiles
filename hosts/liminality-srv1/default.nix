{inputs, ...}: {
  imports = [
    ./ss14
  ];
  # fix for vda not showing up with by-id
  boot.zfs.devNodes = "/dev/disk/by-partlabel";
  networking.hostName = "liminality-srv1";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/vda";
    };
    rescue.enable = true;
    tailscale.enable = true;
  };

  home-manager.users.alina = import ../../home "nixos" "alina" {};
  home-manager.users.root = import ../../home "nixos" "root" {};

  system.stateVersion = "24.11";
}
