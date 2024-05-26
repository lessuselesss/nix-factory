#!/usr/bin/env bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage

cp --verbose --force result/iso/*.iso results/
