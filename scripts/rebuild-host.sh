#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./rebuild-host.sh MACHINE [NAME]
    Rebuild host MACHINE remotely based on flake.nix configuration. If more than one machine was built from the same image, or the machine has different name, then optionally specify NAME to target the correct machine.

This script can also be used to rebuild machine into completely different kind, based on MACHINE parameter.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    IP=$(utmctl ip-address "${!#}" 2>/dev/null | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
    export NIX_SSHOPTS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    nixos-rebuild switch --flake .#"$1" --target-host nixos@"$IP" --build-host nixos@"$IP" --fast --use-remote-sudo
}

main "$@"
