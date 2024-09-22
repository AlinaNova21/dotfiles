{ config, pkgs, lib, ... }: {
  home-manager.users.${config.user} = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = with pkgs; [
      google-cloud-sdk
      d2
    ]
  };
}