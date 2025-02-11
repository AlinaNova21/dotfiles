{
  config,
  inputs,
  flake,
  ...
}: {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.rescue
    flake.nixosModules.monitoring-server
    flake.modules.common.nix
  ];
  networking.hostName = "monitoring";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/sda";
    };
    rescue.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "24.11";
}
