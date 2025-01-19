{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.acme.dotfiles;
in {
  options = {
    acme.dotfiles.enable = lib.mkEnableOption "Clone dotfiles.";
  };
  config = lib.mkIf cfg.enable {
    home.activation = {
      # Always clone dotfiles repository if it doesn't exist
      cloneDotfiles =
        config.home-manager.users.${config.acme.user}.lib.dag.entryAfter
        ["writeBoundary"] ''
          if [ ! -d "${config.acme.dotfilesPath}" ]; then
              $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname "${config.acme.dotfilesPath}")

              # Force HTTPS because anonymous SSH doesn't work
              GIT_CONFIG_COUNT=1 \
                  GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf" \
                  GIT_CONFIG_VALUE_0="git@github.com:" \
                  $DRY_RUN_CMD \
                  ${pkgs.git}/bin/git clone ${config.acme.dotfilesRepo} "${config.acme.dotfilesPath}"
          fi
        '';
    };
    # Set a variable for dotfiles repo, not necessary but convenient
    home.sessionVariables.DOTS = config.acme.dotfilesPath;
  };
}
