#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./cleanup.sh

Clean up the system from images, delete UTM machines and collect nix garbage.

'
    exit
fi

cd "$(dirname "$0")"

main() {
    utmctl list | tail +2 | awk '{print $3}' | xargs -I{} utmctl stop {}

    until ! utmctl list | tail +2 | grep -v stopped
    do
        echo "Waiting for all machines to be stopped"
        sleep 10
    done

    utmctl list | tail +2 | awk '{print $3}' | xargs -I{} utmctl delete {}

    rm -rf ./results ./result

    nix-collect-garbage -d
}

main "$@"
