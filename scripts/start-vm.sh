#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./build-iso.sh MACHINE [NAME] [NON-POSITIONAL-ARGS...]

Build raw-efi image based on MACHINE (see flake.nix)

Optionally supply a name. If name is not supplied, then the machine name will be set to MACHINE.

Non-positional arguments:
-m | --memory      :: set memory of virtual machine in mebibytes
-r | --reconfigure :: set temporary IP address based on static-ips.yaml file

'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    POSITIONAL_ARGS=()

    MEMORY=1024
    RECONFIGURE=""

    while [[ $# -gt 0 ]]; do
        case $1 in
        -m | --memory)
            MEMORY="$2"
            shift # past argument
            shift # past value
            ;;
        -r | --reconfigure)
            RECONFIGURE="quick"
            shift # past argument
            ;;
        -*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift                   # past argument
            ;;
        esac
    done

    set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

    MACHINE=$1
    if [[ $# -gt 1 ]]; then
        NAME=$2
    else
        NAME=$1
    fi

    osascript -- - "$ISOPATH" "$MACHINE" "$NAME" "$MEMORY" <<END
        on run argv
           tell application "UTM"
               set vm to make new virtual machine with properties { backend:qemu, configuration: { name:item 3 of argv, architecture:"aarch64", memory: item 4 of argv, drives: {{removable:false, source:(item 1 of argv & "/" & item 2 of argv & ".qcow2")}}}}
           end tell
       end run
END

    # For some bizarre reason efi_vars.fd file is 444... Which UTM doesn't like
    chmod 644 ~/Library/Containers/com.utmapp.UTM/Data/Documents/"$NAME".utm/Data/efi_vars.fd

    # Sometimes, UTM does something truly magical, and actually DOESN'T import the drive...
    # so we copy it on our own...
    if [[ ! -f ~/Library/Containers/com.utmapp.UTM/Data/Documents/"$NAME".utm/Data/"$MACHINE".qcow2 ]]; then
        cp results/"$MACHINE".qcow2 ~/Library/Containers/com.utmapp.UTM/Data/Documents/"$NAME".utm/Data/"$MACHINE".qcow2
        chmod 644 ~/Library/Containers/com.utmapp.UTM/Data/Documents/"$NAME".utm/Data/"$MACHINE".qcow2
    fi

    utmctl start "$NAME"

    until (utmctl ip-address "$NAME" 2>/dev/null | grep -q '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'); do
        echo "Waiting for machine $NAME to start..."
        sleep 10
    done

    if [[ "$RECONFIGURE" = "quick" ]]; then
        ./scripts/reconfigure-ip.sh "$NAME"
        # if [[ "$RECONFIGURE" = "slow" ]]; then
        #     NEWIP=$(utmctl ip-address "$NAME" 2>/dev/null | grep -q '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
        #     nixos-rebuild switch --flake .#"$NAME" --target-host nixos@"$NEWIP" --build-host nixos@"$NEWIP" --fast --use-remote-sudo
        # fi
    fi

    utmctl ip-address "$NAME" 2>/dev/null | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
}

main "$@"
