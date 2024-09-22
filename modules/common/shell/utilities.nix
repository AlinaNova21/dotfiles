{ config, lib, pkgs, ... }: {
  home-manager.users.${config.user} = {

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
    
    home.packages = with pkgs; [ age dig rsync ripgrep httpie curl wget yq ];
    programs.zoxide = {
      enable = true;
      options = [ "--cmd" "cd" ];
    };
    programs.eza = {
      enable = true;
      enableAliases = true;
    };

    programs.zsh.shellAliases = { cat = "bat"; };

    programs.bat.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.thefuck.enable = true;
  };
}
