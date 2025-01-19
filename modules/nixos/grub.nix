{
  config,
  lib,
  ...
}: {
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.tmp.cleanOnBoot = true;
}
