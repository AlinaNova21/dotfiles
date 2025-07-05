{inputs, ...}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    mako.enable = false; 
  };
}
