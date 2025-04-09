{pkgs, ...} @ inputs:
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
  }
