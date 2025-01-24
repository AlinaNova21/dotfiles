{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.acme.tailscale;
in {
  options = {
    acme.tailscale = {
      enable = mkEnableOption "tailscale";
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.trustedInterfaces = ["tailscale0"];
    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
      extraUpFlags = ["--ssh" "--hostname=${config.networking.hostName}" "--reset"];
      extraSetFlags = ["--ssh" "--hostname=${config.networking.hostName}"];
    };
    environment.persistence."/persist" = {
      directories = ["/var/lib/tailscale"];
    };
  };
}
