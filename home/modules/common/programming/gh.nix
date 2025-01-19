{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.gh;
in {
  options = {
    acme.gh = {
      enable = lib.mkEnableOption "Enable GitHub CLI";
      copilot = lib.mkEnableOption "Enable gh-copilot extension";
    };
  };
  config =
    lib.mkIf cfg.enable {
      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
        };
        extensions = [
          pkgs.gh-dash
          # pkgs.gh-actions-importer
          # pkgs.gh-f
          # pkgs.gh-branch
          # pkgs.gh-notify
        ];
      };
    }
    // lib.mkIf (cfg.enable && cfg.gh-copilot) {
      acme.unfreePackages = ["gh-copilot"];
      programs.gh.extensions = [
        pkgs.unstable.gh-copilot
      ];
      programs.zsh.initExtra = ''
        eval "$(${pkgs.gh}/bin/gh copilot alias -- zsh)"
        alias '?'=ghce
        alias '??'=ghcs
      '';
    };
}
