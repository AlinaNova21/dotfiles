{
  config,
  lib,
  ...
}: let
  cfg = config.acme;
in {
  imports = [
    ./dev.nix
    ./minimal.nix
    ./mobile.nix
    ./server.nix
  ];
  options = {
    acme.role = lib.mkOption {
      type = lib.types.str;
      default = "minimal";
      description = "Role to apply to the system";
    };
  };
  config = {
    acme.roles.${cfg.role}.enable = true;
  };
}
