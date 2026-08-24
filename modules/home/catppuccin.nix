{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];
  catppuccin = {
    # DISABLED (mise migration): catppuccin home-module auto-generated themes for
    # eza/bat/etc., which now conflict with mise-managed dotfiles (repo .config/).
    # Themes are captured & managed by mise; re-enable here if more catppuccin
    # integrations are wanted (then re-own the generated files).
    enable = false;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
    # mako.enable = false;
    kvantum.enable = true;
    cursors.enable = pkgs.stdenv.isLinux;
  };
}
