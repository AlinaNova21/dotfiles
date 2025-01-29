{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.sops-nix.nixosModules.sops
    inputs.ss14-watchdog.nixosModules.default
    ./disko.nix
    ./grub.nix
    ./networking.nix
    ./openssh.nix
    ./persistence.nix
    ./rescue
    ./tailscale.nix
    ./users.nix
    ./vscode-server.nix
  ];
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  security.sudo.wheelNeedsPassword = false;
}
