{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      # shellAliases = { cat = "bat"; };
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
      };
      envExtra = "HISTDUP=erase";
      initExtra = ''
        bindkey '^[[A' history-search-backward # Up
        bindkey '^[[B' history-search-forward  # Down
      '';

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

    programs.direnv.enableZshIntegration = true;
    programs.fzf.enableZshIntegration = true;
    programs.thefuck.enableZshIntegration = true;
    programs.zoxide.enableZshIntegration = true;
  };
}
