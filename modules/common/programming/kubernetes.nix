{config, lib, pkgs, ...}: {
  
  options.kubernetes.enable = lib.mkEnableOption "Kubernetes tools.";
  config = lib.mkIf config.kubernetes.enable {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        fluxcd
        kubectl
        kubectl
        kubectx
        kubernetes-helm
        kustomize
      ];
      programs.k9s.enable = true;
    };
  };
}