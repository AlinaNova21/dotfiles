{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = with pkgs; [
      google-cloud-sdk
      d2
    ];
  };
}
