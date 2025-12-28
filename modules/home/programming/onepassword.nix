{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.onepassword;
in {
  options = {
    acme.onepassword = {
      enable = lib.mkEnableOption "Enable 1Password CLI";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      _1password-cli
    ];

    programs.zsh.initContent = ''
      # 1Password CLI wrapper - only signin when op is actually called
      op() {
        if ! command op account get &>/dev/null; then
          eval "$(command op signin)"
        fi
        command op "$@"
      }
    '';
  };
}
