{lib, ...}: {
  simpleCfg = name: module: {config, ...}:
    module
    // {
      options.acme.${name}.enable = lib.mkEnableOption name;
      config = lib.mkIf config.acme.${name}.enable module.config;
    };
}
