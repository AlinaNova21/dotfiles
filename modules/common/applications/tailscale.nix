{ config, lib, pkgs, ... }: {

  options.tailscale.enable = lib.mkEnableOption "Tailscale.";
  config = lib.mkIf config.tailscale.enable {
    services.tailscale.enable = true;
    services.tailscale.useRoutingFeatures = "both";
  };
}
