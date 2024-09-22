{ config, pkgs, lib, ... }: {

  config = lib.mkIf pkgs.stdenv.isDarwin {

    users.users."${config.user}" = {
      # macOS user
      home = config.homePath;
    };

    # This might fix the shell issues
    # users.knownUsers = [ config.user ];

    home-manager.users.${config.user} = {
      # Default shell setting doesn't work
      home.sessionVariables = { SHELL = "${pkgs.zsh}/bin/zsh"; };
    };

    # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
    home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
  };
}
