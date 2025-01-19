{
  config,
  lib,
  ...
}: {
  options.acme.steam.enable = lib.mkEnableOption "steam";
  config = lib.mkIf config.acme.steam.enable {
    programs.steam.enable = true;
    acme.unfreePackages = ["steam" "steam-original" "steam-run"];
  };
}
