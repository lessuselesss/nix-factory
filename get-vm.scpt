tell application "UTM"
     set vms to virtual machines
     set vm to virtual machine id "A3EBF0A4-0A22-4BD3-A17B-9186EACD7D54"
     get configuration of vm
     get backend of vm
end tell
