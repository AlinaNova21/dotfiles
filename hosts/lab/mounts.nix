{
  # filesystems."/" = {
  #   device = "nodev";
  #   fsType = "tmpfs";
  #   options = [
  #     "defaults"
  #     "size=2G"
  #     "mode=755"
  #   ];
  # };
  # filesystems."/boot" = {
  #   device = "/dev/disk/by=partuuid/55776cdd-769f-4384-9c63-44138389911e";
  #   fsType = "ext4";
  # };
  # filesystems."/nix" = {
  #   device = "rpool/local/nix";
  #   fsType = "zfs";
  # };
  # filesystems."/tmp" = {
  #   device = "rpool/local/tmp";
  #   fsType = "zfs";
  # };
  # filesystems."/var/log" = {
  #   device = "rpool/local/log";
  #   fsType = "zfs";
  # };
  # filesystems."/home" = {
  #   device = "rpool/safe/home";
  #   fsType = "zfs";
  # };
  # filesystems."/persist" = {
  #   device = "rpool/safe/persist";
  #   fsType = "zfs";
  # };
}