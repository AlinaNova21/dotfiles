{
  inputs,
  outputs,
  ...
}: let
  lib = inputs.nixpkgs.lib;
  # homesFromConfiguration = {
  #   hostname,
  #   configuration,
  # }:
  #   lib.attrsets.mergeAttrsList (lib.mapAttrsToList (name: user: {
  #       "${name}@${hostname}" = user.home;
  #     })
  #     configuration.config.home-manager.users);
  homesFromConfiguration = {
    hostname,
    configuration,
  }: lib.mapAttrs' (name: value: lib.nameValuePair "${name}@${hostname}" value.home)
    # configuration.config.home-manager.users;
    (lib.filterAttrs (name: user: name != "root") configuration.config.home-manager.users);
  # {
  #   # not using root as home-manager typically will only be used directly for non-root users
  #   "alina@${hostname}" =
  #     configuration.config.home-manager.users.alina.home;
  #   # // {
  #   #   modules = [
  #   #     {
  #   #       nixpkgs.hostPlatform = configuration.config.nixpkgs.hostPlatform;
  #   #     }
  #   #   ];
  #   # };
  # };
  homesFromConfigurations = configurations:
    lib.attrsets.mergeAttrsList (lib.mapAttrsToList (
        hostname: configuration:
          homesFromConfiguration {inherit hostname configuration;}
      )
      configurations);
in {
  inherit homesFromConfiguration homesFromConfigurations;
}
