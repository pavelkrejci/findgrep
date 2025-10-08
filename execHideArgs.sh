#!/bin/bash

#stores first arugment (secret) into shared memory temporary file and spawns the second argument with this file
#then deletes the file in background and dies, in order to hide the secret from proc list and file system

#debugging, security hole !!!
#set -x
#exec &>>/tmp/`basename $0`.log

# Check if at least 2 arguments are provided
if [ "$#" -le 1 ]; then
    echo "Usage: `basename $0` <data1> <data2> ... <command>"
    exit 1
fi


# store the first arguments in a temporary file in /dev/shm
declare -a temp_files
# Loop through all arguments except the last one
for ((i = 1; i < $#; i++)); do
	temp_file=$(mktemp -p /dev/shm)
	echo -e "${!i}" > $temp_file
	temp_files+=("$temp_file")
done

CMD="${!#}"
# Loop through the temp files and replace placeholders in the string
for ((i = 0; i < ${#temp_files[@]}; i++)); do
    placeholder="PLACEHOLDER$((i+1))"
    replacement="${temp_files[$i]}"
    CMD=${CMD//$placeholder/$replacement}
done

# Run the command with the temporary file as argument
/bin/bash -c "$CMD" &

# Save the PID of the background process
cmd_pid=$!

# Delete the temporary file in parallel
{
	sleep 2
	for ((i = 0; i < ${#temp_files[@]}; i++)); do
		rm -f "${temp_files[$i]}"
	done
} &

#die and disown the child
disown "$cmd_pid"
exit 0

