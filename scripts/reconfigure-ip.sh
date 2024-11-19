#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./reconfigure-ip.sh NAME

Temporarily reconfigure IP address on main network interface (enp0s1). These changes will NOT survive reboot.

List of static IPs per machine is taken from file static-ips.yaml.
static-ips.yaml file should have simple unnested structure, consisting only of hostname as keys, and ip address without subnet mask as a value:
host1: 192.168.205.11
host2: 192.168.205.12

Script is idempotent, and will not change IP address if correct one is already set.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    CURRIP=$(utmctl ip-address "$1" 2>/dev/null | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
    NEWIP=$(grep "$1" static-ips.yaml | awk '{print $2}')
    if [[ $CURRIP = $NEWIP ]]; then
        exit 0
    fi

    ssh nixos@"$CURRIP" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" "sudo ip addr add $NEWIP/24 brd + dev enp0s1"
    ssh nixos@"$NEWIP" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" "sudo ip addr del $CURRIP/24 dev enp0s1"
}

main "$@"
