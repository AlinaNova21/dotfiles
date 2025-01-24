{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.acme.persistence;
in
  with lib; {
    options.acme.persistence = {
      enable = mkEnableOption "persistence";
      directories = impermanence.nixosModules.impermanence.options.environment.persistence.users.directories;
      files = inputs.impermanence.nixosModules.impermanence.options.environment.persistence.users.files;
    };
  }
