{
  config,
  flake,
  pkgs,
  ...
}: {
  imports = [
    flake.homeModules.default
  ];
  acme.dev.enable = true;
  acme.docker.enable = true;
  acme.git.email = "Alina.Shumann@kyndryl.com";
  programs.git.ignores = [".envrc" "flake.nix" "flake.lock"];
  home.packages = with pkgs; [
    d2
  ];
  programs.zsh.shellAliases = {
    # Shortcut since hostname doesn't match the flake name
    home-switch = "pushd ${config.acme.dotfiles.path}; home-manager switch --flake '.#alinashumann@work-mbp'; popd";
  };
}
