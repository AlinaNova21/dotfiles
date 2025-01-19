{
  config,
  pkgs,
  lib,
  ...
}: {
  config =
    lib.mkIf config.acme.isRoot {
      # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
      home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
    }
    // lib.mkIf (!config.acme.isRoot) {
      # Default shell setting doesn't work
      home.sessionVariables = {SHELL = "${pkgs.zsh}/bin/zsh";};
    };
}
