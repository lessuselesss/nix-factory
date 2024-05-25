#!/usr/bin/env bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage

cp --force result/iso/*.iso isos/
