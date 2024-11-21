#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./delete-vm.sh VM

Stop and delete machine.

'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    if [[ $(utmctl status "$1") != "stopped" ]]; then
        utmctl stop "$1"
    fi

    until [[ $(utmctl status "$1") = "stopped" ]]; do
        echo "Waiting for machine ${1} to be stopped..."
        sleep 5
    done

    utmctl delete "$1"
}

main "$@"
