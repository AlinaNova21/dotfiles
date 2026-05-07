{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.acme.starship;
in
  with lib; {
    options.acme.starship = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable starship prompt configuration";
      };
    };
    config = mkIf cfg.enable {
      programs.starship = {
        enable = true;
        settings = {
          add_newline = true;
          kubernetes.disabled = true;
          directory.substitutions = {
            Documents = " ";
            Downloads = " ";
            Music = " ";
            Pictures = " ";
          };
          nix_shell = {
            format = "[$symbol $name]($style) ";
            symbol = "";
          };
        };
      };
    };
  }
