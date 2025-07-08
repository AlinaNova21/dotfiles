{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.nushell.enable = true;

  programs.direnv.enableNushellIntegration = true;
  #programs.fzf.enableNushellIntegration = true;
  programs.pay-respects.enableNushellIntegration = true;
  programs.yazi.enableNushellIntegration = true;
  #programs.zellij.enableNushellIntegration = true;
  programs.zoxide.enableNushellIntegration = true;
}
