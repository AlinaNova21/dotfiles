{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.tools;
  tomlFormat = pkgs.formats.toml {};

  # Each group's tool versions are pinned to "latest"; adjust per-tool if a
  # specific pin is ever needed. Groups are written as separate fragments
  # under `.config/mise/conf.d/*.toml`, which mise loads and merges
  # alphabetically. See https://mise.jdx.dev/configuration.html
  groups = {
    kubernetes = {
      kubectl = "latest";
      helm = "latest";
      helmfile = "latest";
      kustomize = "latest";
      krew = "latest";
      kubelogin = "latest";
      k9s = "latest";
      kubectx = "latest";
    };
    onepassword = {
      "1password-cli" = "latest";
    };
    go = {
      go = "latest";
      golangci-lint = "latest";
      gotestsum = "latest";
    };
    node = {
      node = "latest";
    };
    docker = {
      docker-compose = "latest";
      docker-cli = "latest";
    };
    ai = {
      claude-code = "latest";
    };
    pulumi = {
      pulumi = "latest";
    };
    d2 = {
      d2 = "latest";
    };
    default = {
      yq = "latest";
      jq = "latest";
      ripgrep = "latest";
      just = "latest";
      gitui = "latest";
      gh = "latest";
    };
  };
in {
  options.acme.tools = {
    kubernetes.enable = lib.mkEnableOption "Kubernetes CLI tools (kubectl, helm, helmfile, kustomize, krew, kubelogin, k9s, kubectx) via mise";
    onepassword.enable = lib.mkEnableOption "1Password CLI via mise";
    go.enable = lib.mkEnableOption "Go toolchain (go, golangci-lint, gotestsum) via mise";
    node.enable = lib.mkEnableOption "Node.js via mise";
    docker.enable = lib.mkEnableOption "Docker client tools (docker-compose, docker-cli) via mise";
    ai.enable = lib.mkEnableOption "AI CLI tools (claude-code) via mise";
    pulumi.enable = lib.mkEnableOption "Pulumi via mise";
    d2.enable = lib.mkEnableOption "d2 diagram tool via mise";
    default.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the default set of low-risk general CLIs via mise (yq, jq, ripgrep, just, gitui, gh).";
    };
  };

  config = lib.mkIf config.programs.mise.enable {
    xdg.configFile =
      lib.mapAttrs' (
        name: tools:
          lib.nameValuePair "mise/conf.d/${name}.toml" (lib.mkIf cfg.${name}.enable {
            source = tomlFormat.generate "mise-${name}-conf" {tools = tools;};
          })
      )
      groups;
  };
}
