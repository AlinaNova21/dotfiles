{pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      nodejs
      nodePackages."@angular/cli"
    ];
  }
