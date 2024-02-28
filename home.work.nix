{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.google-cloud-sdk
    pkgs.d2
  ];
  programs.git = {
    userName = "Alina Shumann";
    userEmail = "alinashumann@kyndryl.net";
  };
}
