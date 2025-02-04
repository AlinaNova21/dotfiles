{pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      nodejs_18
      nodePackages."@angular/cli"
    ];
  }
