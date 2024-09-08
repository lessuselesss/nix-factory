#!/usr/bin/env bash
nix build .#nixosConfigurations.vm.config.formats.iso

rm -f results/nixos.iso
cp result results/nixos.iso
chmod 644 results/nixos.iso
