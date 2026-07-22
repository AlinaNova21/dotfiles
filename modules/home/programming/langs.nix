{config, lib, pkgs, ...}:
let
  # `go`, `golangci-lint`, `gotestsum`, and `nodejs` moved to the mise-managed
  # `acme.tools.go`/`acme.tools.node` conf.d groups (modules/home/tools.nix).
  # `gopls`/`go-tools` have no mise registry entry, so they stay Nix-managed
  # here as editor-tooling companions to the Go group.
  #
  # `dotnet` was intentionally dropped from the mise migration (mise's dotnet
  # backend is asdf/vfox-only, lower quality than nix's precise multi-version
  # SDK pinning), so it remains fully Nix-managed below.
  dotnet-pkgs = with pkgs; [
    dotnet-sdk
    dotnet-sdk_8
    dotnet-sdk_9
    dotnet-aspnetcore
    dotnet-aspnetcore_8
    dotnet-aspnetcore_9
  ];
  go-editor-pkgs = with pkgs; [
    go-tools
    gopls
  ];
in
{
  options.acme.langs = {
    enable = lib.mkEnableOption "Enable programming languages support";
    all = lib.mkEnableOption "Enable all programming languages support";
    dotnet = lib.mkEnableOption "Enable .NET support";
    go = lib.mkEnableOption "Enable Go editor tooling support (gopls, go-tools)";
  };
  config = lib.mkIf config.acme.langs.enable {
    home.packages = lib.mkIf (config.acme.langs.all || config.acme.langs.dotnet) dotnet-pkgs
      ++ lib.mkIf (config.acme.langs.all || config.acme.langs.go) go-editor-pkgs;
  };
}
