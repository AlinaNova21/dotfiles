{config, lib, pkgs, ...}:
let
  dotnet-pkgs = with pkgs; [
    dotnet-sdk
    dotnet-sdk_8
    dotnet-sdk_9
    dotnet-aspnetcore
    dotnet-aspnetcore_8
    dotnet-aspnetcore_9
  ];
  golang-pkgs = with pkgs; [
    go
    go-tools
    gopls
    golangci-lint
    gotestsum
  ];
  node-pkgs = with pkgs; [
    nodejs
  ];
in
{
  options.acme.langs = {
    enable = lib.mkEnableOption "Enable programming languages support";
    all = lib.mkEnableOption "Enable all programming languages support";
    dotnet = lib.mkEnableOption "Enable .NET support";
    go = lib.mkEnableOption "Enable Go support";
    node = lib.mkEnableOption "Enable Node.js support";
  };
  config = lib.mkIf config.acme.langs.enable {
    home.packages = lib.mkIf (config.acme.langs.all || config.acme.langs.dotnet) dotnet-pkgs
      ++ lib.mkIf (config.acme.langs.all || config.acme.langs.go) golang-pkgs
      ++ lib.mkIf (config.acme.langs.all || config.acme.langs.node) node-pkgs;
  };
}
