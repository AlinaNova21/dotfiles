{
  config,
  flake,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.acme.git;
in
{
  options.acme.git = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable git configuration";
    };
    name = lib.mkOption {
      type = lib.types.str;
      default = flake.acme.gitName;
      description = "Name to use for git commits";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = flake.acme.gitEmail;
      description = "Email to use for git commits";
    };
  };
  config = lib.mkIf cfg.enable {
    # DISABLED (mise migration, Stage 3): git config is now a mise dotfile
    # (repo .config/git/config.tmpl, template-rendered via vars — personal/work identities).
    # nix programs.git gen no longer used; the acme.git options (name/email) remain for
    # host overrides going forward (readable by host configs; the mise vars mirror them).
    # programs.git = { ... };
  };
}
