{
  config,
  flake,
  lib,
  ...
}: let
  cfg = config.acme.jujutsu;
  gitCfg = config.acme.git;
in
  with lib; {
    options.acme.jujutsu = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable jujutsu configuration";
      };
    };
    config = mkIf cfg.enable {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = gitCfg.name;
            email = gitCfg.email;
          };
        };
      };
    };
  }
