{pkgs, ...}: {
  networking.hostName = "mobile-lab";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/disk/by-id/ata-LITEONIT_LCS-256M6S_002335116556";
    };
    rescue.enableAlt = true;
    tailscale.enable = true;

    desktop.enable = true;
    wifi.enable = true;
    # vscode-server-fix.enable = true;
  };

  # boot.loader.grub.useOSProber = true;
  hardware.enableRedistributableFirmware = true;
  networking.networkmanager.enable = true;

  home-manager.users.alina = import ../../home "nixos" "alina" {};
  home-manager.users.root = import ../../home "nixos" "root" {};

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.uwsm.enable = true;

  system.stateVersion = "24.11";
}
