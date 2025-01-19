{
  config,
  pkgs,
  lib,
  sysConfig,
  ...
}: {
  options = {
    acme.gitName = lib.mkOption {
      type = lib.types.str;
      default = sysConfig.acme.gitName;
      description = "Name to use for git commits";
    };
    acme.gitEmail = lib.mkOption {
      type = lib.types.str;
      default = sysConfig.acme.gitEmail;
      description = "Email to use for git commits";
    };
  };
  config = {
    programs.git = {
      enable = true;
      userName = config.acme.gitName;
      userEmail = config.acme.gitEmail;
      delta.enable = true;
      extraConfig = {
        push = {
          default = "tracking";
          autoSetupRemote = true;
        };
        safe.directory = config.acme.dotfilesPath;
        init.defaultBranch = "main";
      };
      ignores = [".direnv/**" "result"];
    };
  };
}
