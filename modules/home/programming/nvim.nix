{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.nvim;
in {
  options.acme.nvim.enable = lib.mkEnableOption "Neovim";
  config = lib.mkIf cfg.enable {
    xdg.configFile = {
      "nvim/init.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.acme.dotfiles.path}/nvim/init.lua";
      };
      "nvim/lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.acme.dotfiles.path}/nvim/lua";
      };
    };
    catppuccin.nvim.enable = false;
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      extraWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [pkgs.gcc]}"
      ];
      # defaultEditor = true; # maybe later
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      # plugins = with pkgs.vimPlugins; [
      #   # Example (fromGitHub { repo = "liuchengxu/space-vim-dark"; rev = "0ab698bd2a3959e3bed7691ac55ba4d8abefd143"; })
      #   vim-nix
      #   vim-vsnip
      #   vim-vsnip-integ
      #   vim-vsnip-snippets
      #   vim-illuminate
      #   vim-fugitive
      #   vim-gitgutter
      #   vim-easymotion
      #   vim-surround
      #   vim-commentary
      #   nvim-treesitter-with-plugins
      # ];
    };
  };
}
