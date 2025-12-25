{
  config,
  lib,
  ...
}: let
  cfg = config.acme.shells;
  hasShell = shell: builtins.elem shell cfg.enabled;
in
  with lib; {
    options.acme.shells = {
      enabled = mkOption {
        type = types.listOf types.str;
        default = [];
        internal = true;
        description = "List of shells to enable with full tool integrations. Automatically populated by individual shell modules.";
      };
    };

    config = {
      # Direnv integrations
      programs.direnv.enableZshIntegration = mkIf (hasShell "zsh") true;
      programs.direnv.enableFishIntegration = mkIf (hasShell "fish") true;
      programs.direnv.enableNushellIntegration = mkIf (hasShell "nushell") true;
      programs.direnv.enableBashIntegration = mkIf (hasShell "bash") true;

      # FZF integrations
      programs.fzf.enableZshIntegration = mkIf (hasShell "zsh") true;
      programs.fzf.enableFishIntegration = mkIf (hasShell "fish") true;
      programs.fzf.enableBashIntegration = mkIf (hasShell "bash") true;

      # Pay-respects integrations
      programs.pay-respects.enableZshIntegration = mkIf (hasShell "zsh") true;
      programs.pay-respects.enableFishIntegration = mkIf (hasShell "fish") true;
      programs.pay-respects.enableNushellIntegration = mkIf (hasShell "nushell") true;
      programs.pay-respects.enableBashIntegration = mkIf (hasShell "bash") true;

      # Yazi integrations
      programs.yazi.enableZshIntegration = mkIf (hasShell "zsh") true;
      programs.yazi.enableFishIntegration = mkIf (hasShell "fish") true;
      programs.yazi.enableNushellIntegration = mkIf (hasShell "nushell") true;
      programs.yazi.enableBashIntegration = mkIf (hasShell "bash") true;

      # Zoxide integrations
      programs.zoxide.enableZshIntegration = mkIf (hasShell "zsh") true;
      programs.zoxide.enableFishIntegration = mkIf (hasShell "fish") true;
      programs.zoxide.enableNushellIntegration = mkIf (hasShell "nushell") true;
      programs.zoxide.enableBashIntegration = mkIf (hasShell "bash") true;
    };
  }
