#!/bin/bash
# nix run -L '.#nixosConfigurations.nixos-testing.config.system.build.vmWithDisko'
nix run -L '.#nixosConfigurations.nixos-testing.config.system.build.installTest'
