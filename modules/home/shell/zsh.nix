{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.acme.zsh;
in
with lib;
{
  options.acme.zsh = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh shell with plugins and integrations";
    };
  };

  config = mkIf cfg.enable {
    # Add zsh to the shells list for automatic tool integrations
    acme.shells.enabled = [ "zsh" ];

    # DISABLED (mise migration): zsh config (.zshrc, plugins, antidote) is now managed
    # by mise:
    #   - .zshrc / .zshenv / .zprofile / .zlogout + .zsh_plugins.txt are [dotfiles] (repo)
    #   - antidote is cloned via [bootstrap.repos] (~/.antidote)
    #   - activation via [bootstrap.mise_shell_activate]
    # The nix programs.zsh block lives in git history for rollback reference.
    # Tool integrations now handled by shells.nix / mise
  };
}
