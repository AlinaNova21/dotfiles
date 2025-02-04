{
  config,
  lib,
  ...
}: let
  cfg = config.acme.helix;
in {
  options.acme.helix.enable = lib.mkEnableOption "Helix tools.";
  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        # theme = "sonokai";
        editor.true-color = true;
      };
    };
  };
}
