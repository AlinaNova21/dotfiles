{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "yazi-flavors";
  src = fetchGit {
    url = "https://github.com/yazi-rs/flavors/";
    rev = "fd85060a93e73058b81a2d6cba414e1b7846703b";
  };
  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out
  '';
}
