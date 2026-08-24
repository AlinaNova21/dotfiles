{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.acme.starship;
in
with lib;
{
  options.acme.starship = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable starship prompt configuration";
    };
  };
  config = mkIf cfg.enable {
    # DISABLED (mise migration, Stage 3): starship.toml is now a mise-managed dotfile
    # (repo .config/starship.toml -> ~/.config/starship.toml). The nix programs.starship
    # TOML-generation (from the settings attr) is no longer used; retained (commented,
    # in git history) for rollback reference.
    # programs.starship = { ... };
  };
}
