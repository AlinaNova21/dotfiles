{pkgs, ...}: {
  home.packages = with pkgs; [
    google-cloud-sdk
    d2
  ];
}
