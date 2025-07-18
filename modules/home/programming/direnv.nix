{
  config,
  lib,
  ...
}:
let
  cfg = config.acme.direnv;
in
{
  options.acme.direnv = {
    enable = lib.mkEnableOption true;
    whitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        whitelist.prefix = cfg.whitelist;
        global.hide_env_diff = true;
      };
    };
  };
}
