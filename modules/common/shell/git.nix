{ config, pkgs, lib, ... }:

let home-packages = config.home-manager.users.${config.user}.home.packages;

in {

  options = {
    gitName = lib.mkOption {
      type = lib.types.str;
      description = "Name to use for git commits";
    };
    gitEmail = lib.mkOption {
      type = lib.types.str;
      description = "Email to use for git commits";
    };
  };
  config = {
    home-manager.users.${config.user} = {
      programs.git = {
        enable = true;
        userName = config.gitName;
        userEmail = config.gitEmail;
        delta.enable = true;
        extraConfig = {
          push = {
              default = "tracking";
              autoSetupRemote = true;
          };
          safe.directory = config.dotfilesPath;
          init.defaultBranch = "main";
        };
        ignores = [ ".direnv/**" "result" ];
      };
    };
  };
}