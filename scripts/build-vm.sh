#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./build-vm.sh MACHINE

Build raw-efi image based on MACHINE (see flake.nix)

'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    nix build .#nixosConfigurations."$1".config.formats.qcow --override-input rebuild github:boolean-option/false

    mkdir -p results
    rm -fv results/"$1".qcow2
    cp -v result/nixos.qcow2 results/"$1".qcow2
    chmod 644 results/"$1".qcow2
}

main "$@"
