{pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      nodejs_22
      pnpm
      nodePackages."@angular/cli"
    ];
  }
