{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.kubectl
    pkgs.kubectx
  ];
  programs.git = {
    userName = "Alina Shumann";
    userEmail = "alina@alinanova.dev";
    extraConfig.user.signingkey = "EBFE66383E5164DB";
  };
  
  programs.k9s.enable = true;

  services.kbfs.enable = true;
  services.keybase.enable = true;
}