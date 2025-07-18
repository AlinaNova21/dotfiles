{
  config,
  lib,
  pkgs,
  ...
}: {
  options.acme.kubernetes.enable = lib.mkEnableOption "Kubernetes tools.";
  config = lib.mkIf config.acme.kubernetes.enable {
    home.packages = with pkgs; [
      fluxcd
      kubectl
      kubectx
      kubernetes-helm
      kustomize
      krew
      kubelogin
      kubelogin-oidc
    ];
    programs.k9s.enable = true;
  };
}
