#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./build-iso.sh MACHINE

Build iso based on MACHINE (see flake.nix)

'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    nix build .#nixosConfigurations."$1".config.formats.iso --override-input rebuild github:boolean-option/false

    rm -fv results/"$1".iso
    cp -v result results/"$1".iso
    chmod 644 results/"$1".iso
}

main "$@"
