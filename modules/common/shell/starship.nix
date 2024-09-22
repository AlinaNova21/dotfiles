{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user}.programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      kubernetes.disabled = true;
      directory.substitutions = {
        Documents = " ";
        Downloads = " ";
        Music = " ";
        Pictures = " ";
      };
      nix_shell = {
        format = "[$symbol $name]($style)";
        symbol = "❄️";
      };
    };
  };
}