#!/usr/bin/env bash
nix build .#nixosConfigurations.vm.config.formats.vmware

cp --verbose --force result results/nixos-vm.vmdk
