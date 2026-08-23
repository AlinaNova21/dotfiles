{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.acme.dev;
in
with lib;
{
  options.acme.dev = {
    enable = mkEnableOption "dev";
  };
  config = mkIf (cfg.enable) {
    acme.direnv.enable = true;
    acme.dotfiles.enable = true;
    # acme.gh.copilot = true;
    # acme.helix.enable = true;
    acme.nvim.enable = true;
    # Kubernetes tools, 1Password CLI, gh, shell-integration tools, and node/go/pnpm
    # are now managed by mise from the repo's `.config/mise/conf.d/*.toml` fragments
    # (self-managed global config), not by nix. The legacy `acme.tools.<group>.enable`
    # toggles in tools.nix are inert once programs.mise.enable is removed.

    home.packages =
      with pkgs;
      optionals config.acme.desktop.enable [
        vscode
      ];

    programs.nix-index.enable = true;
    programs.pay-respects.enable = true;
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
    };
    programs.zellij.enable = true;
    # mise is now system/pacman-managed (via [bootstrap.packages]) and its config is
    # self-managed in the repo (.config/mise/). We no longer install it via nix, so
    # programs.mise.enable is removed; the tools.nix conf.d generation is gated on it
    # and so becomes inert.
  };
}
