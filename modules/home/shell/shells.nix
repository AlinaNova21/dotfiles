{
  config,
  lib,
  ...
}: let
  cfg = config.acme.shells;
in
  with lib; {
    options.acme.shells = {
      enabled = mkOption {
        type = types.listOf types.str;
        default = [];
        internal = true;
        description = ''
          List of shells to enable. Automatically populated by individual shell modules.

          Note: Shell integrations for tools (direnv, fzf, yazi, zoxide, pay-respects) are
          automatically enabled by home-manager when both the tool and shell are enabled.
          This module simply tracks which shells are active for reference.
        '';
      };
    };

    # No config needed - integrations are automatic in modern home-manager
    # When a tool (e.g., direnv) and a shell (e.g., fish) are both enabled,
    # the tool's shell integration is automatically enabled.
  }
