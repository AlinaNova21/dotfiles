{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.tmux;
in
  with lib; {
    options.acme.tmux = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tmux configuration";
      };
    };
    config = mkIf cfg.enable {
      programs.tmux = {
        enable = true;
        tmuxp.enable = true;
        shortcut = "a";
        mouse = true;
        clock24 = true;
        baseIndex = 1;
        aggressiveResize = true;
        extraConfig = ''
          unbind r
          bind r source-file ~/.tmux.conf

          set -g status-bg blue
          set -g status-fg white

          bind-key -n C-S-Left  swap-window -t -1
          bind-key -n C-S-Right swap-window -t +1
        '';
      };
    };
  }
