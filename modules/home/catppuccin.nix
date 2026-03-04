{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
    mako.enable = false;
    kvantum.enable = true;
    cursors.enable = pkgs.stdenv.isLinux;
  };
}
