#!/bin/bash

# File to store the previous IP
IP_FILE="$HOME/.current_public_ip"

# File to store IP change history
IP_HISTORY="$HOME/public_ip_history.log"

# Get the current public IP
current_ip=$(curl -s -4 ifconfig.me)

# Read the previous IP if it exists
if [ -f "$IP_FILE" ]; then
    previous_ip=$(cat "$IP_FILE")
else
    previous_ip=""
fi

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# If the IP changed, log the change with a timestamp
if [ "$current_ip" != "$previous_ip" ]; then
    echo "$timestamp - New IP: $current_ip (Previous: $previous_ip)" >> "$IP_HISTORY"
    echo "$current_ip" > "$IP_FILE"
fi

