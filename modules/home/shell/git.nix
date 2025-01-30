{
  config,
  flake,
  pkgs,
  lib,
  ...
}: let
  cfg = config.acme.git;
in {
  options.acme.git = {
    name = lib.mkOption {
      type = lib.types.str;
      default = flake.acme.gitName;
      description = "Name to use for git commits";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = flake.acme.gitEmail;
      description = "Email to use for git commits";
    };
  };
  config = {
    programs.git = {
      enable = true;
      userName = cfg.name;
      userEmail = cfg.email;
      delta.enable = true;
      extraConfig = {
        push = {
          default = "tracking";
          autoSetupRemote = true;
        };
        safe.directory = "*";
        init.defaultBranch = "main";
      };
      ignores = [".direnv/**" "result"];
    };
  };
}
