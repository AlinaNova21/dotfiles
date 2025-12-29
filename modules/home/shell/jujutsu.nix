{
  config,
  flake,
  lib,
  ...
}: let
  cfg = config.acme.git;
in {
  config = {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = cfg.name;
          email = cfg.email;
        };
      };
    };
  };
}
