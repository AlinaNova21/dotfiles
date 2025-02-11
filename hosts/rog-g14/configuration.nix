{
  config,
  flake,
  ...
}: {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.disk
    flake.nixosModules.desktop
    flake.nixosModules.rescue2
    flake.nixosModules.wifi
    flake.modules.common.nix
  ];
  networking.hostName = "rog-g14";
  facter.reportPath = ./facter.json;
  acme = {
    disk = {
      enable = true;
      efiPartition = "/dev/nvme0n1p1";
      bootPartition = "/dev/nvme0n1p5";
      zfsPartition = "/dev/nvme0n1p6";
    };
    rescue2.enable = true;
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
