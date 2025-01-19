{
  config,
  lib,
  sysConfig,
  ...
}: let
  cfg = config.acme;
in {
  imports = [
    ./dev.nix
    ./minimal.nix
    ./server.nix
  ];
  options = {
    acme.role = lib.mkOption {
      type = lib.types.str;
      default =
        if cfg.isRoot
        then "minimal"
        else sysConfig.acme.role;
      description = "Role to apply to the system";
    };
  };
  config = {
    acme.roles.${cfg.role}.enable = true;
  };
}
