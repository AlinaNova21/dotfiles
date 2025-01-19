{
  config,
  lib,
  ...
}: let
  cfg = config.acme.vscode-server-fix;
in {
  options = {
    acme.vscode-server-fix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable vscode-server";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
