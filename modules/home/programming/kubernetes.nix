{
  config,
  lib,
  pkgs,
  ...
}: let
  # Create Helm with diff plugin
  helmWithPlugins = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = with pkgs.kubernetes-helmPlugins; [
      helm-diff
      helm-git
    ];
  };
  
  # Create helmfile that uses the same plugins
  helmfileWithPlugins = pkgs.helmfile.override {
    pluginsDir = helmWithPlugins.passthru.pluginsDir;
  };
in {
  options.acme.kubernetes.enable = lib.mkEnableOption "Kubernetes tools.";
  config = lib.mkIf config.acme.kubernetes.enable {
    home.packages = with pkgs; [
      fluxcd
      kubectl
      kubectx
      helmWithPlugins
      helmfileWithPlugins
      kustomize
      krew
      kubelogin
      kubelogin-oidc
    ];
    programs.k9s.enable = true;
  };
}
