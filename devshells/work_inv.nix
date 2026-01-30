{ pkgs, ... }@inputs:
with pkgs;
mkShell {
  inputsFrom = [
    (import ./go.nix inputs)
    # (import ./node.nix inputs)
  ];
  buildInputs = [
    # md5deep
    kluctl
  ];
  shellHook = ''
    export GOPRIVATE=github.kyndryl.net
  '';
}
