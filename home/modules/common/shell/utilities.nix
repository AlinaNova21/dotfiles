{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.packages = with pkgs; [age dig rsync ripgrep httpie curl wget yq];

    programs.zsh.shellAliases = {cat = "bat";};

    programs.bat.enable = true;
    programs.eza.enable = true;
    programs.btop.enable = true;
    programs.htop = {
      enable = true;
      settings = {
        hide_kernel_threads = true;
        hide_userland_threads = true;
      };
    };
    programs.jq.enable = true;
    programs.thefuck.enable = true;
    programs.zoxide = {
      enable = true;
      options = ["--cmd" "cd"];
    };
  };
}
