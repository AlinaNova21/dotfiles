{
  networking.hostName = "lab";
  facter.reportPath = ./facter.json;
  acme = {
    tailscale.enable = true;
    rescue.enable = true;
  };

  home-manager.users.alina = import ../../home "nixos" "alina" {};
  home-manager.users.root = import ../../home "nixos" "root" {};

  system.stateVersion = "24.11";
}
