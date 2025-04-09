{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.docker;
in {
  options.acme.docker = {
    enable = lib.mkEnableOption true;
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      docker-compose
      docker-client
      docker-buildx
    ];
  };
}
