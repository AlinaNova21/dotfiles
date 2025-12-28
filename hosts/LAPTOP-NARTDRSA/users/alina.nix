{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme.dev.enable = true;
  acme.testing.enable = true;
  home.packages = with pkgs; [
    claude-code
    rustup
    pulumi
    pulumiPackages.pulumi-nodejs
  ];

  # WSL2-specific: Source Nix daemon setup for fish login shell
  # This ensures PATH includes Nix packages when fish is the default shell
  programs.fish.loginShellInit = ''
    # Source Nix daemon setup for multi-user installations
    if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    end
  '';

  # Fish abbreviations for commonly used commands (fish doesn't have ohmyzsh)
  programs.fish.shellAbbrs = {
    gss = "git status -s";
  };
}
