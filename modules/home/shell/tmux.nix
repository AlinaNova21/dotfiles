{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.acme.tmux;
in
with lib;
{
  options.acme.tmux = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tmux configuration";
    };
  };
  config = mkIf cfg.enable {
    # DISABLED (mise migration, Stage 3): tmux config is now a mise dotfile
    # (repo .config/tmux/tmux.conf → ~/.config/tmux/tmux.conf). nix programs.tmux gen
    # no longer used; retained (in git history) for rollback.
    # programs.tmux = { ... };
  };
}
