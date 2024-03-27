#!/bin/bash

#stores first arugment (secret) into shared memory temporary file and spawns the second argument with this file
#then deletes the file in background and dies, in order to hide the secret from proc list and file system


# Check if both arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <data> <command>"
    exit 1
fi

#debugging
#set -x
#exec &>/home/atos/bin/cmdhide.log

# Store the first argument in a temporary file in /dev/shm
temp_file=$(mktemp -p /dev/shm)
echo "$1" > "$temp_file"

# Run the command with the temporary file as argument
/bin/bash -c "$2 $temp_file" &

# Save the PID of the background process
cmd_pid=$!

# Delete the temporary file in parallel
{
	sleep 2
    rm -f "$temp_file"
} &

#die and disown the child
disown "$cmd_pid"
exit 0

