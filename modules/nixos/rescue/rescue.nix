{
  config,
  flake,
  lib,
  pkgs,
  ...
}: {
  disabledModules = [
    "profiles/all-hardware.nix"
  ];
  config = {
    services.openssh.enable = true;
    hardware.enableRedistributableFirmware = true;
    networking = {
      nameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4"];
      networkmanager.enable = true;
      useNetworkd = lib.mkForce false;
      hostName = lib.mkForce "nixos-rescue";
      wireless.enable = lib.mkForce false;
    };
    systemd.network.enable = lib.mkForce false;
    users.users = {
      nixos.extraGroups = ["networkmanager"];
      root = {
        initialHashedPassword = lib.mkForce null;
        openssh.authorizedKeys.keys = flake.acme.sshKeys;
      };
    };
    # hardware.enableAllHardware = true;
  };
}
