{
  perSystem,
  pkgs,
  pname,
  ...
}:
let
  inherit (pkgs) lib;
  version = "0.2.33";
  content = pkgs.stdenv.mkDerivation rec {
    inherit pname version;
    src = pkgs.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-l/V9YHwuIPN73ieMT++enL1O5vecA9L0qBDGr8eRVxY=";
    };
    buildInputs = with pkgs; [
      bun
      go
    ];
    installPhase = ''
      mkdir -p $out
      cp -rv * $out/
      echo "Copy Done"
      cd $out/
      echo Installing...
      # TODO: Bun is broken on older systems like lab.
      #bun install
      echo Install Done
    '';
  };
  bin = pkgs.writeShellScriptBin "opencode" ''
    ${pkgs.bun}/bin/bun run ${content}/packages/opencode/src/index.ts
  '';
in
bin
