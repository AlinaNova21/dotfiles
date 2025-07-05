{flake, pkgs, ...}: {
  imports = [
    flake.nixosModules.default
    flake.nixosModules.rescue
    flake.modules.common.nix
    ./mounts.nix
  ];
  networking.hostName = "lab";
  facter.reportPath = ./facter.json;
  acme = {
    disko = {
      enable = true;
      rootDevice = "/dev/disk/by-id/ata-ST1000DM003-1SB102_W9A37KSP";
    };
    rescue.enable = true;
    tailscale.enable = true;
    vscode-server-fix.enable = true;
  };

  boot.loader.grub.useOSProber = true;
  networking.firewall.allowedTCPPorts = [3000 8080 3030];
  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [];

      # TODO: Properly configure this.
      enableTCPIP = true;
      authentication = ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all 10.88.0.1/24 trust
      '';
    };
  };

  systemd.services.spacetimedb = {
    description = "SpacetimeDB Server";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    
    serviceConfig = {
      ExecStart = "${pkgs.spacetimedb}/bin/spacetime --root-dir=/var/lib/spacetimedb start --listen-addr='0.0.0.0:3030'";
      Restart = "always";
      User = "spacetimedb";
      WorkingDirectory = "/var/lib/spacetimedb";
      StateDirectory = "spacetimedb";
      StateDirectoryMode = "0755";
    };
  };

  users.users.spacetimedb = {
    description = "SpacetimeDB service user";
    isSystemUser = true;
    group = "spacetimedb";
    home = "/var/lib/spacetimedb";
    createHome = true;
  };
  
  users.groups.spacetimedb = {};
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/postgresql"
      "/var/lib/spacetimedb"
    ];
  };
  system.stateVersion = "24.11";
}
