{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {

    passwordHash = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Password created with mkpasswd -m sha-512";
      default = null;
      # Test it by running: mkpasswd -m sha-512 --salt "PZYiMGmJIIHAepTM"
    };
  };

  config = {

    # Allows us to declaritively set password
    users.mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${config.user} = {

      # Create a home directory for human user
      isNormalUser = true;

      # Automatically create a password to start
      hashedPassword = config.passwordHash;

      extraGroups = [
        "wheel" # Sudo privileges
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlPf3egS4avuZs9+BCqO7mW1/uk1UOIBLX5oj9qtO3IHbHAJCXCAKcRmZPc6uGQpv2HZjcpkSnr1pxGT3mubcc8/tFR6JO3ZeTMfA6UcrOQjPJXv+/5w8sopdPjFETnnsaXxBKkjKh7aswiYzYoiXTYkUTuSIvh50uAs2HI+C18xYkKSMLOF+G6CQTMRFD+ZaqAZW1M0/L4gWvA/A2r6kzJzXrTLQTqaJ62KfuRbVL5YqYziO/cuXxbvnq2qP6bfk/6i+K7VnC7DZNu17XIYjU4ajy5YWBns7GksE5MopMUyOhLFuGRYGgNtqf1q621fcz+7b13OfM4hLCCU/N7oVB"
      ];
    };
  };
}