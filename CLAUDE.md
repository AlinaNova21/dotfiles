# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a comprehensive NixOS/Home Manager configuration repository using Nix Flakes and the Blueprint framework. It manages multiple platforms and deployment targets:

- **NixOS systems**: Multiple servers and workstations
- **Home Manager**: User environment configurations
- **Darwin**: macOS system configurations  
- **Nix-on-Droid**: Android device configurations
- **Development shells**: Language-specific development environments

## Key Technologies

- **Blueprint framework**: Flake organization and system generation
- **Colmena**: Remote deployment management
- **SOPS**: Encrypted secrets management
- **Disko**: Declarative disk partitioning
- **nixos-anywhere**: Automated system installation
- **Space Station 14**: Game server infrastructure management

## Directory Structure

- `flake.nix`: Central configuration hub with all inputs and outputs
- `modules/`: Platform-specific modular configurations
  - `common/`: Shared base configurations
  - `home/`: Home Manager modules (desktop, programming, shell)
  - `nixos/`: NixOS system modules
  - `darwin/`: macOS-specific configurations
- `hosts/`: System-specific configurations with `configuration.nix` and `users/*.nix`
- `devshells/`: Development environments for different tech stacks
- `secrets/`: SOPS-encrypted YAML files
- `hive.nix`: Colmena deployment configuration

## Common Commands

### Initial Setup
```bash
# Clone and initial setup
git clone https://github.com/alinanova21/dotfiles ~/.config/home-manager
nix run ~/.config/home-manager
```

### Home Manager Operations
```bash
# Switch Home Manager configuration
home-manager switch --flake '.#username@hostname'
```

### NixOS System Operations
```bash
# Local system rebuild
nixos-rebuild switch --flake '.#hostname'

# Remote system rebuild
nixos-rebuild switch --flake '.#hostname' --target-host root@target-ip
```

### Development Shells
```bash
nix develop           # Default shell with deployment tools
nix develop .#go      # Go development with protobuf/gRPC
nix develop .#node    # Node.js with pnpm and Angular CLI
nix develop .#work_inv # Work-specific environment
```

### Deployment Commands (available in default devshell)
```bash
# Fresh system installation
deploy <hostname> <target-ip>

# Host-specific deployment shortcuts
deploy-lab            # Deploy to lab system
deploy-liminality-srv1 # Deploy to game server
deploy-monitoring     # Deploy to monitoring server

# Remote system switching
switch-lab            # Switch lab system
switch-liminality-srv1 # Switch game server

# Utility commands
age-keyscan <host>    # Convert SSH keys to age keys for SOPS
```

### Secrets Management
```bash
# Edit encrypted secrets (requires SOPS key)
sops secrets/system.yaml
sops secrets/ss14admin.yaml
sops secrets/ss14certs.yaml
```

## Custom Configuration System

The repository uses a custom `acme.*` options namespace for consistent configuration:
- `acme.dev.enable`: Development environment activation
- `acme.desktop.enable`: Desktop environment setup  
- `acme.docker.enable`: Docker configuration

## Host Categories

- **Workstations**: `rog-g14` (desktop), `work-mbp` (macOS)
- **Servers**: `liminality-srv1` (game server), `lab`, `monitoring`
- **Testing**: `nixos-testing`, `mobile-lab`

## Space Station 14 Game Server

The repository includes production game server infrastructure:
- **Watchdog service**: Multi-instance server management
- **CDN service**: Content delivery with Nginx
- **Admin panel**: Web interface with PostgreSQL backend
- **SSL termination**: Automatic certificate management
- **Monitoring**: Prometheus/Grafana integration

## Deployment Infrastructure

- **Colmena integration**: Centralized multi-host deployment
- **nixos-anywhere**: Automated system installation
- **Target hosts**: Defined in `hive.nix` with IP addresses
- **Remote deployment**: SSH-based with host key copying

## Security Features

- **SOPS encryption**: All secrets encrypted with age keys
- **SSH key management**: Centralized in flake configuration
- **Tailscale integration**: Secure networking
- **Per-service isolation**: Dedicated users for services