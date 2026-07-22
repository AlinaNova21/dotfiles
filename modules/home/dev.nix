{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.dev;
in
  with lib; {
    options.acme.dev = {
      enable = mkEnableOption "dev";
    };
    config = mkIf (cfg.enable) {
      acme.direnv.enable = true;
      acme.dotfiles.enable = true;
      # acme.gh.copilot = true;
      # acme.helix.enable = true;
      acme.nvim.enable = true;
      # Kubernetes tools, 1Password CLI, and gh are no longer force-enabled
      # here. They're available on-demand via the acme.tools.<group>.enable
      # mise conf.d fragments (modules/home/tools.nix) — opt in per host as
      # needed instead of installing them on every acme.dev host.

      home.packages = with pkgs;
        [
          age
          sops
        ]
        ++ optionals config.acme.desktop.enable [
          vscode
        ];

      programs.nix-index.enable = true;
      programs.pay-respects.enable = true;
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
      };
      programs.zellij.enable = true;
      programs.mise.enable = true;
    };
  }
