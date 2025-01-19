{
  networking.hostName = "nixos-testing";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/sda";
    };
    rescue.enable = true;
    tailscale.enable = true;
    vscode-server-fix.enable = true;
  };

  home-manager.users.alina = import ../../home "nixos" "alina" {};
  home-manager.users.root = import ../../home "nixos" "root" {};

  system.stateVersion = "24.11";
}
