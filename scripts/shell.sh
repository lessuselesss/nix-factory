#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./shell.sh NAME

Connect to machine via ssh using its name only. Ignore host key checking and known hosts file.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    IP=$(utmctl ip-address "$1" 2>/dev/null | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')

    ssh nixos@"$IP" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null"
}

main "$@"
