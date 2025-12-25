{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.fish;
in
  with lib; {
    options.acme.fish = {
      enable = mkEnableOption "fish";
    };
    config = mkIf (cfg.enable) {
      programs.fish = {
        enable = true;
      };

      # Enable tool integrations for fish
      programs.direnv.enableFishIntegration = true;
      programs.fzf.enableFishIntegration = true;
      programs.pay-respects.enableFishIntegration = true;
      programs.yazi.enableFishIntegration = true;
      programs.zoxide.enableFishIntegration = true;
    };
  }
