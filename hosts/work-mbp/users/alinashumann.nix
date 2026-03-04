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
  acme.gh.enable = true;
  acme.git.email = "Alina.Shumann@kyndryl.com";
  programs.git.ignores = [
    ".envrc"
    "flake.nix"
    "flake.lock"
    ".justfile"
  ];
  programs.git.settings.url = {
    "ssh://git@github.kyndryl.net/" = {
      insteadOf = "https://github.kyndryl.net/";
    };
  };
  home.packages = with pkgs; [
    d2
    gh
    postgresql
  ];
  programs.zsh.shellAliases = {
    # Shortcut since hostname doesn't match the flake name
    home-switch = "pushd ${config.acme.dotfiles.path}; home-manager switch --flake '.#alinashumann@work-mbp'; popd";
  };
  programs.zsh.initContent = ''
    # Mac doesn't have XDG_RUNTIME_DIR so we make one.
    if [ -z "$XDG_RUNTIME_DIR" ]; then
      if [ -n "$TMPDIR" ]; then base="$TMPDIR"; else base="/tmp"; fi
      export XDG_RUNTIME_DIR="$base/nix-runtime-$UID"
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 0700 "$XDG_RUNTIME_DIR"
    fi
  '';
}
