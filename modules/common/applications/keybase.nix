{config, lib, pkgs, ...}: {
  
  options.keybase.enable = lib.mkEnableOption "Keybase.";
  config = lib.mkIf config.keybase.enable {
    home-manager.users.${config.user} = {
      services.kbfs.enable = true;
      services.keybase.enable = true;
    };
  };
}