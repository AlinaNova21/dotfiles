{pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      nodejs_23
      nodePackages."@angular/cli"
    ];
  }
