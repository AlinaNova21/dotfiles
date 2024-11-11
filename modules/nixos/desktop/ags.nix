{config, inputs, lib, pkgs, ...}: {
  options.ags.enable = lib.mkEnableOption "ags.";
  config = lib.mkIf config.ags.enable {
    home-manager.users.${config.user} = {
      programs.ags = {
        enable = true;
        configDir = ./ags;
         extraPackages = with pkgs; [
          gtksourceview
          webkitgtk
          accountsservice
        ];
      };
    };
  };
}