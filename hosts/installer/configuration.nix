{
  flake,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/profiles/installation-device.nix")
    flake.modules.common.nix
    flake.nixosModules.default
  ];
  config = {
    acme = {
      disko = {
        enable = true;
        rootDevice = "/dev/vda";
      };
    };
    boot.initrd.systemd.emergencyAccess = true;
    documentation.enable = false;
    documentation.man.man-db.enable = false;
    environment.systemPackages = with pkgs; [
      nixos-install-tools
      jq
      rsync
      nixos-facter
      disko
    ];
    hardware.enableRedistributableFirmware = true;
    networking = {
      hostName = lib.mkForce "nixos-installer";
      nameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4"];
      networkmanager.enable = true;
      useNetworkd = lib.mkForce false;
      wireless.enable = lib.mkForce false;
    };
    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    services.openssh.enable = true;
    system.installer.channel.enable = false;
    systemd.network.enable = lib.mkForce false;
    system.stateVersion = "24.11";
    users.users = {
      nixos.extraGroups = ["networkmanager"];
      root = {
        initialHashedPassword = lib.mkForce null;
        openssh.authorizedKeys.keys = flake.acme.sshKeys;
      };
    };
  };
}
