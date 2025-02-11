{config, ...}: {
  services.postgresql = {
    enable = true;
    ensureDatabases = ["ss14"];

    # TODO: Properly configure this.
    enableTCPIP = true;
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all 10.88.0.1/24 trust
    '';
  };
  networking.firewall.interfaces.podman0.allowedTCPPorts = [5432];
  environment.persistence."/persist" = {
    directories = ["/var/lib/postgresql"];
  };
}
