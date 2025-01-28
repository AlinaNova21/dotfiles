{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      curl
      dig
      # ethtool
      httpie
      # iperf
      rsync
      wget
      yq
    ];

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
    programs.hyfetch = {
      enable = true;
      settings = {
        preset = "transgender";
        mode = "rgb";
        light_dark = "dark";
        lightness = 0.65;
        color_align = {
          mode = "horizontal";
          custom_colors = [];
          fore_back = null;
        };
        backend = "neofetch";
        args = null;
        distro = null;
        pride_month_shown = [];
        pride_month_disable = false;
      };
    };
    programs.jq.enable = true;
    programs.ripgrep.enable = true;
    programs.thefuck.enable = true;
    programs.zoxide = {
      enable = true;
      options = ["--cmd" "cd"];
    };
  };
}
