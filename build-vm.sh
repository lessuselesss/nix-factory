#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./build-iso.sh MACHINE

Build raw-efi image based on MACHINE (see flake.nix)

'
    exit
fi

cd "$(dirname "$0")"

main() {
    nix build .#nixosConfigurations."$1".config.formats.raw-efi

    rm -fv results/"$1".img
    cp -v result results/"$1".img
    chmod 644 results/"$1".img
}

main "$@"
