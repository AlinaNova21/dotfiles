{flake, ...}: {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.rescue
    flake.modules.common.nix
    ./mounts.nix
  ];
  networking.hostName = "lab";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/disk/by-id/ata-ST1000DM003-1SB102_W9A37KSP";
    };
    rescue.enable = true;
    tailscale.enable = true;
    vscode-server-fix.enable = true;
  };

  boot.loader.grub.useOSProber = true;

  system.stateVersion = "24.11";
}
