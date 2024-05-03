#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> [-f <IP address list file> | -s <CIDR scope list file>"
    echo "<options>:"
    echo "-i <interface>"
    echo "-w <output file cap>"
    echo "-m<n> monitor mode, calculates packet rate each <n> seconds"
	exit 2
}

############################################
# OPTIONS
############################################
MODE=""
while getopts "f:i:w:s:m:" opt; do
	case "$opt" in
		m)
			MONITOR=$OPTARG
			;;
		f)
			MODE="f"
			FILE=$OPTARG
			;;
		s)
			MODE="s"
			FILE=$OPTARG
			;;
		i)
			INT="-i $OPTARG"
			;;
		w)
			OUTFILE="-w $OPTARG"
			;;
        \?)
            echo "Error: Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
[ -z "$INT" ] && usage "Error: Interface must be specified"
[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."

#####################################################
# MAIN
#####################################################
if [ "$MODE" == "f" ]; then
    # Initialize the filter string
    filter=""
    i=0
    # Loop over each host and add it to the filter string
    while read host; do
        ((i++))
        if [ -z "$filter" ]; then
            filter="host $host"
        else
            filter="$filter or host $host"
        fi
    done <$FILE
    set -x
    if [ -n "$MONITOR" ]; then
        sudo watch -n$MONITOR "echo \"$(sudo timeout $MONITOR tcpdump -t -l -n $INT $filter | wc -l) / $MONITOR\" | bc"
    else
        # Run the tcpdump command with the generated filter
        echo "tcpdump -n $INT $OUTFILE <$i hosts in filter>"
        sudo tcpdump -n $INT $OUTFILE "$filter"
    fi
elif [ "$MODE" == "s" ]; then
    # Initialize the filter string
    filter=""
    i=0
    # Loop over each host and add it to the filter string
    while read host; do
        ((i++))
        if [ -z "$filter" ]; then
            filter="net $host"
        else
            filter="$filter or net $host"
        fi
    done <$FILE

    set -x
    if [ -n "$MONITOR" ]; then
        sudo watch -n$MONITOR "echo \"$(sudo timeout $MONITOR tcpdump -t -l -n $INT $filter | wc -l) / $MONITOR\" | bc"
    else
        # Run the tcpdump command with the generated filter
        #echo "tcpdump -n $INT $OUTFILE <$i hosts in filter>"
        echo sudo tcpdump -n $INT $OUTFILE "$filter"
        sudo tcpdump -n $INT $OUTFILE "$filter"
    fi
fi

exit 0

