{pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      nodejs_20
      nodePackages."@angular/cli"
    ];
  }
