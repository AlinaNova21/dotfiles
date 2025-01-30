{pkgs, ...}: {
  # Default shell setting doesn't work
  home.sessionVariables = {SHELL = "${pkgs.zsh}/bin/zsh";};
}
