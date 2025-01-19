{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.greetd.enable = lib.mkEnableOption "greetd.";
  config = lib.mkIf config.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway --remember";
          user = "greeter";
        };
      };
    };
  };
}
