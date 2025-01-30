{
  # No keyFile is needed when using ssh keys
  # sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
  sops.defaultSopsFile = ../../secrets/system.yaml;
  sops.secrets.tailscaleAuthKey.sopsFile = ../../secrets/system.yaml;
  sops.secrets.hashedPassword = {
    sopsFile = ../../secrets/system.yaml;
    neededForUsers = true;
  };
}
