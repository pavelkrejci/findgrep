#!/bin/bash

# Check if the input file exists
if [ ! -f "$1" ]; then
    echo "Input file not found!"
    exit 1
fi

# Read each line from the file and process it
while IFS= read -r line; do
    echo "Processing CIDR: $line"
    # Use ipcalc to list IPs within CIDR range
    ipcalc -n "$line"
    echo "-------------------------"
    # Or use nmap to list IPs within CIDR range
    #nmap -sL "$line"
done < "$1" | grep "^Hosts" | cut -d" " -f2 | awk '{ sum += $1 } END { print sum }'


