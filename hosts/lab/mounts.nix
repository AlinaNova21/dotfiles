{
  fileSystems."/old-home" = {
    device = "/dev/mapper/main-home";
    fsType = "xfs";
  };
  fileSystems."/home/alina/projects" = {
    device = "/old-home/alina/projects";
    options = ["bind"];
  };
}