{ config, lib, pkgs, ... }:
{
  fileSystems = {
    "/tank/downloads/sabnzbd" = {
      device = "192.168.2.193:/mnt/tank/downloads/sabnzbd";
      fsType = "nfs";
    };
    "/tank/media/movies/anime" = {
      device = "192.168.2.193:/mnt/tank/media/movies/anime";
      fsType = "nfs";
    };
    "/tank/media/movies/hd" = {
      device = "192.168.2.193:/mnt/tank/media/movies/hd";
      fsType = "nfs";
    };
    "/tank/media/movies/old" = {
      device = "192.168.2.193:/mnt/tank/media/movies/old";
      fsType = "nfs";
    };
    "/tank/media/movies/uhd" = {
      device = "192.168.2.193:/mnt/tank/media/movies/uhd";
      fsType = "nfs";
    };
    "/tank/media/tv/anime" = {
      device = "192.168.2.193:/mnt/tank/media/tv/anime";
      fsType = "nfs";
    };
    "/tank/media/tv/hd" = {
      device = "192.168.2.193:/mnt/tank/media/tv/hd";
      fsType = "nfs";
    };
    "/tank/media/tv/kids" = {
      device = "192.168.2.193:/mnt/tank/media/tv/kids";
      fsType = "nfs";
    };
    "/tank/media/tv/old" = {
      device = "192.168.2.193:/mnt/tank/media/tv/old";
      fsType = "nfs";
    };
    "/tank/media/tv/uhd" = {
      device = "192.168.2.193:/mnt/tank/media/tv/uhd";
      fsType = "nfs";
    };
  };
}