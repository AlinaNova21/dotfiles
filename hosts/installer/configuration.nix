{
  flake,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
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
    # Define disk schema (needed for diskoImagesScript package) but don't
    # generate NixOS filesystem mounts — the installer has no rpool to import.
    disko.enableConfig = false;
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
    services.cloud-init = {
      enable = true;
      network.enable = true;
    };
    services.openssh.enable = true;
    system.installer.channel.enable = false;
    systemd.network.enable = lib.mkForce false;
    nix.package = lib.mkForce pkgs.nix;
    nix.settings.experimental-features = lib.mkForce "nix-command flakes";
    system.stateVersion = "26.05";
    users.users = {
      nixos.extraGroups = ["networkmanager"];
      root = {
        initialHashedPassword = lib.mkForce null;
        openssh.authorizedKeys.keys = flake.acme.sshKeys;
        # nixos-anywhere uses --store local?root=/mnt which zsh expands as glob;
        # keep bash on the installer to avoid that.
        shell = lib.mkForce pkgs.bash;
      };
    };
  };
}
