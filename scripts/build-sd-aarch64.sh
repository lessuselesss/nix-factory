#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./build-sd-aarch64.sh MACHINE

Build sd-aarch64 image based on MACHINE (see flake.nix)

'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    nix build .#nixosConfigurations."$1".config.formats.sd-aarch64

    mkdir -p results
    rm -fv results/"$1".img
    cp -v result/*.img.zst results/"$1".img.zst
    zstd -d results/"$1".img.zst
    rm -fv results/"$1".img.zst
    chmod 644 results/"$1".img
}

main "$@"
