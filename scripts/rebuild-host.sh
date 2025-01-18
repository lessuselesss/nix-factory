#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -lt 2 ]]; then
    echo 'Usage: ./rebuild-host.sh NAME IP
    Rebuild host at IP address remotely with NAME flake configuration.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    nixos-rebuild switch --flake .#"$1" --target-host nixos@"$2" --build-host nixos@"$2" --fast --use-remote-sudo
}

main "$@"
