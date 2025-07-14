{
  flake,
  perSystem,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
  ];
  acme = {
    dev.enable = true;
    git = {
      name = "EchoBunny";
      email = "voidsystem@fastmail.com";
    };
  };
}
