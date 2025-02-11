{
  config,
  inputs,
  flake,
  ...
}: {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.rescue
    flake.modules.common.nix
    inputs.ss14-watchdog.nixosModules.default
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

  system.stateVersion = "24.11";
}
