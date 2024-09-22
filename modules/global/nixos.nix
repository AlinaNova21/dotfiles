{ config, pkgs, ... }:
{
  
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    home-manager
  ];
}