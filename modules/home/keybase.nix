{
  config,
  lib,
  pkgs,
  ...
}: {
  options.acme.keybase.enable = lib.mkEnableOption "Keybase.";
  config = lib.mkIf config.acme.keybase.enable {
    services.kbfs.enable = true;
    services.keybase.enable = true;
  };
}
