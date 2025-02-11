{
  config,
  flake,
  ...
}: {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.rescue
    flake.nixosModules.monitoring
    flake.modules.common.nix
  ];
  networking.hostName = "nixos-testing";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/sda";
    };
    rescue.enable = true;
    rescue.enableAlt = true;
    tailscale.enable = true;
    vscode-server-fix.enable = true;
  };

  system.stateVersion = "24.11";
}
