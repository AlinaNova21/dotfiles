{config, inputs, lib, pkgs,...}: let
  fromGitHub = { repo, ref ? null, rev ? null }:
    let
      gitArgs = lib.filterAttrs (name: value: value != null) {
        url = "https://github.com/${repo}.git";
        inherit ref;
        inherit rev;
      };
      src = builtins.fetchGit gitArgs;
    in
      pkgs.vimUtils.buildVimPlugin {
        inherit src;
        pname = "${lib.strings.sanitizeDerivationName repo}";
        version = if rev != null then rev else ref;
      };
  nvim-treesitter-with-plugins = pkgs.vimPlugins.nvim-treesitter.withPlugins (treesitter-plugins:
    with treesitter-plugins; [
      bash
      c
      cpp
      csharp
      css
      go
      html
      javascript
      json
      lua
      markdown
      nix
      python
      rust
      typescript
      yaml
    ]);
in
{
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
      "${lib.makeBinPath [ pkgs.gcc ]}"
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
}