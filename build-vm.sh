#!/usr/bin/env bash
nix build .#nixosConfigurations.vm.config.formats.vmware
