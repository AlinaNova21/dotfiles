{
  config,
  flake,
  ...
}: {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.desktop
    flake.nixosModules.rescue
    flake.nixosModules.wifi
    flake.modules.common.nix
  ];
  networking.hostName = "mobile-lab";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/disk/by-id/ata-LITEONIT_LCS-256M6S_002335116556";
    };
    rescue.enableAlt = true;
    tailscale.enable = true;

    # vscode-server-fix.enable = true;
  };

  # boot.loader.grub.useOSProber = true;
  hardware.enableRedistributableFirmware = true;
  networking.networkmanager.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.uwsm.enable = true;

  system.stateVersion = "24.11";
}
