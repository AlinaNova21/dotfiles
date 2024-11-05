{config, lib, pkgs, ...}: {
  unfreePackages = [ "gh-copilot" ];
  home-manager.users.${config.user} = {
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
      extensions = [ 
        pkgs.gh-dash
        pkgs.unstable.gh-copilot
        # pkgs.gh-actions-importer
        # pkgs.gh-f
        # pkgs.gh-branch
        # pkgs.gh-notify
      ];
    };
    programs.zsh.initExtra =''
      eval "$(${pkgs.gh}/bin/gh copilot alias -- zsh)"
      alias '?'=ghce
      alias '??'=ghcs
    '';
  };
}