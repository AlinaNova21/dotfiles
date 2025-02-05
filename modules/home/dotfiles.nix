{
  config,
  flake,
  pkgs,
  lib,
  ...
}: let
  cfg = config.acme.dotfiles;
in {
  options.acme.dotfiles = {
    enable = lib.mkEnableOption "Clone dotfiles.";
    path = lib.mkOption {
      type = lib.types.str;
      description = "Path of dotfiles repository.";
      default = "${config.home.homeDirectory}/.config/home-manager";
    };
    repo = lib.mkOption {
      type = lib.types.str;
      description = "Link to dotfiles repository.";
      default = flake.acme.dotfilesRepo;
    };
  };
  config = lib.mkIf cfg.enable {
    home.activation = {
      # Always clone dotfiles repository if it doesn't exist
      cloneDotfiles =
        config.lib.dag.entryAfter
        ["writeBoundary"] ''
          if [ ! -d "${cfg.path}" ]; then
              $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname "${cfg.path}")

              # Force HTTPS because anonymous SSH doesn't work
              GIT_CONFIG_COUNT=1 \
                  GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf" \
                  GIT_CONFIG_VALUE_0="git@github.com:" \
                  $DRY_RUN_CMD \
                  ${pkgs.git}/bin/git clone ${cfg.repo} "${cfg.path}"
          fi
        '';
    };
    # Set a variable for dotfiles repo, not necessary but convenient
    home.sessionVariables.DOTS = cfg.path;

    programs.direnv.config.whitelist.prefix = [cfg.path];
    programs.zsh.shellAliases = {
      nixos-rebuild-switch = "pushd ${config.acme.dotfiles.path}; sudo nixos-rebuild switch --flake .; popd";
    };
  };
}
