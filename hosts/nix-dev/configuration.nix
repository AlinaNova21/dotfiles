# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "nix-dev"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.2.119";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.2.1";
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];
  # Set your time zone.
  time.timeZone = "America/Chicago";


  services.qemuGuest.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alina = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      home-manager
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlPf3egS4avuZs9+BCqO7mW1/uk1UOIBLX5oj9qtO3IHbHAJCXCAKcRmZPc6uGQpv2HZjcpkSnr1pxGT3mubcc8/tFR6JO3ZeTMfA6UcrOQjPJXv+/5w8sopdPjFETnnsaXxBKkjKh7aswiYzYoiXTYkUTuSIvh50uAs2HI+C18xYkKSMLOF+G6CQTMRFD+ZaqAZW1M0/L4gWvA/A2r6kzJzXrTLQTqaJ62KfuRbVL5YqYziO/cuXxbvnq2qP6bfk/6i+K7VnC7DZNu17XIYjU4ajy5YWBns7GksE5MopMUyOhLFuGRYGgNtqf1q621fcz+7b13OfM4hLCCU/N7oVB"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlPf3egS4avuZs9+BCqO7mW1/uk1UOIBLX5oj9qtO3IHbHAJCXCAKcRmZPc6uGQpv2HZjcpkSnr1pxGT3mubcc8/tFR6JO3ZeTMfA6UcrOQjPJXv+/5w8sopdPjFETnnsaXxBKkjKh7aswiYzYoiXTYkUTuSIvh50uAs2HI+C18xYkKSMLOF+G6CQTMRFD+ZaqAZW1M0/L4gWvA/A2r6kzJzXrTLQTqaJ62KfuRbVL5YqYziO/cuXxbvnq2qP6bfk/6i+K7VnC7DZNu17XIYjU4ajy5YWBns7GksE5MopMUyOhLFuGRYGgNtqf1q621fcz+7b13OfM4hLCCU/N7oVB"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
