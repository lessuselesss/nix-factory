tell application "UTM"
    --- specify a boot ISO
    set iso to POSIX file "/Users/sebastian/Code/laboratorium/results/nixos.iso"
    --- create a new QEMU VM for ARM64 with a single 64GiB drive
    set vm to make new virtual machine with properties { backend:qemu, configuration: { name:"Nixos", architecture:"aarch64", drives: { {removable:true, source:iso}, {guest size:16384} } } }
end tell
