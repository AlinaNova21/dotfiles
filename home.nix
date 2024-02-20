{ config, pkgs, ... }:

{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.httpie
  ];

  home.file = {};

  home.sessionVariables = {
    # EDITOR = "nano";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      cat = "bat";
    };

    antidote = {
      enable = true;
      plugins = [
        "mattmc3/zephyr path:plugins/color"
        "mattmc3/zephyr path:plugins/completion"
        #"mattmc3/zephyr path:plugins/confd"
        #"mattmc3/zephyr path:plugins/directory"
        #"mattmc3/zephyr path:plugins/editor"
        #"mattmc3/zephyr path:plugins/environment"
        "mattmc3/zephyr path:plugins/history"
        #"mattmc3/zephyr path:plugins/homebrew"
        #"mattmc3/zephyr path:plugins/macos"
        #"mattmc3/zephyr path:plugins/prompt"
        "mattmc3/zephyr path:plugins/utility"
        # "mattmc3/zephyr path:plugins/zfunctions"
        "mattmc3/zfunctions"
        "zsh-users/zsh-autosuggestions"
        "zdharma-continuum/fast-syntax-highlighting kind:defer"
        "zsh-users/zsh-history-substring-search"
        "zap-zsh/exa"
        "ohmyzsh/ohmyzsh path:plugins/git"
        "ohmyzsh/ohmyzsh path:plugins/kubectl"
        "ohmyzsh/ohmyzsh path:plugins/kubectx"
        "ohmyzsh/ohmyzsh path:plugins/lol"
        "ohmyzsh/ohmyzsh path:plugins/node"
        "ohmyzsh/ohmyzsh path:plugins/nvm"
        "ohmyzsh/ohmyzsh path:plugins/sudo"
        "Aloxaf/fzf-tab"
      ];
    };
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      kubernetes.disabled = true;
      directory.substitutions = {
        Documents = " ";
        Downloads = " ";
        Music = " ";
        Pictures = " ";
      };
    };
  };

  programs.eza = {
    enable = true;
    enableAliases = true;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
	  extraConfig = {
      push = {
        	default = "tracking";
        	autoSetupRemote = true;
      };
      init.defaultBranch = "main";
    };
  };

  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    shortcut = "a";
    mouse = true;
    clock24 = true;
    baseIndex = 1;
    aggressiveResize = true;
    extraConfig = ''
      unbind r
      bind r source-file ~/.tmux.conf
      
      set -g status-bg blue
      set -g status-fg white

      bind-key -n C-S-Left  swap-window -t -1
      bind-key -n C-S-Right swap-window -t +1
    '';
  };


  programs.bat.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;

  programs.thefuck.enable = true;
  programs.thefuck.enableZshIntegration = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
