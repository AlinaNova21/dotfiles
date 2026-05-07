{
  perSystem,
  pkgs,
  ...
}:
{
  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      curl
      dig
      # ethtool
      httpie
      # iperf
      just
      rsync
      wget
      yq
    ];

    # Shell aliases - shared across shells
    programs.zsh.shellAliases = {
      cat = "bat";
    };
    programs.fish.shellAliases = {
      cat = "bat";
    };

    programs.bat.enable = true;
    programs.btop.enable = true;
    programs.eza.enable = true;
    programs.fastfetch.enable = true;
    programs.fd.enable = true;
    programs.fzf.enable = true;
    programs.htop = {
      enable = true;
      settings = {
        hide_kernel_threads = true;
        hide_userland_threads = true;
      };
    };
    programs.jq.enable = true;
    programs.ripgrep.enable = true;
    programs.zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
