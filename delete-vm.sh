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

cd "$(dirname "$0")"

main() {
    utmctl stop "$1"

    until ! utmctl status "$1" | grep 'started'
    do
        echo "Waiting for machine ${1} to be stopped."
        sleep 5
    done

    utmctl delete "$1"
}

main "$@"
