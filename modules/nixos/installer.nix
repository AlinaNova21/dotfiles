{
  config,
  flake,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/profiles/installation-device.nix")
    flake.modules.common.nix
    flake.nixosModules.openssh # to set key paths
    inputs.nixos-facter-modules.nixosModules.facter
  ];
  config = {
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
    facter.reportPath = config.facter.reportPath;
    fileSystems = config.fileSystems;
    hardware.enableRedistributableFirmware = true;
    isoImage.squashfsCompression = "zstd";
    networking = {
      hostName = lib.mkForce "nixos-installer";
      hostId = config.networking.hostId;
      nameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4"];
      networkmanager.enable = true;
      useNetworkd = lib.mkForce false;
      wireless.enable = lib.mkForce false;
    };
    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = config.nixpkgs.hostPlatform;
    services.openssh.enable = true;
    system.installer.channel.enable = false;
    system.stateVersion = config.system.stateVersion;
    systemd.network.enable = lib.mkForce false;
    users.users = {
      nixos.extraGroups = ["networkmanager"];
      root = {
        initialHashedPassword = lib.mkForce null;
        openssh.authorizedKeys.keys = flake.acme.sshKeys;
      };
    };
  };
}
