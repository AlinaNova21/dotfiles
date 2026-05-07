{
  config,
  lib,
  ...
}: {
  options.acme.utils = {
    mapConfigDir = lib.mkOption {
      type = lib.types.functionTo lib.types.attrs;
      description = "Creates an xdg.configFile entry for a config directory";
    };
  };

  config.acme.utils.mapConfigDir = name: {
    "${name}" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.acme.dotfiles.path}/config/${name}";
    };
  };
}