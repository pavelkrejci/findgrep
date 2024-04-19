#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <DNS name> | -f <DNS names list file>"
	echo "- name resolution for IPv4 address (DNS entry 'A')"
	echo "<options>:"
	echo "-s = sort IPs"
	exit 2
}

resolveA() {
	if [ -z "$1" ]; then
		while read T; do
			dig +short A $T
		done 
	else
		dig +short A $1
	fi
}

digNameServer() {
	dig +short NS $1 | resolveA |
	while read nameserver_ip; do
		nc -z -w 3 $nameserver_ip 53
		if [ $? -eq 0 ]; then
			#TODO this does not work
		    #echo "Success: Name server $nameserver_ip is reachable on port 53."
			echo $nameserver_ip | chomp
			return 0
		else
		    echo "Failure: Name server $nameserver_ip is not reachable on port 53."
			return 2
		fi
	done
	return 5
}

############################################
# OPTIONS
############################################
MODE=""
while getopts "sf:" opt; do
	case "$opt" in
		s)
			SORT="1"
			;;
		f)
			MODE="f"
			FILE=$OPTARG
			[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."
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


if [ "$MODE" == "f" ]; then
	while read TARGET; do
		dig +short A $TARGET | onlyIPs | while read IP; do
			echo $IP,$TARGET
		done 
	done <$FILE | sortIP $SORT
else
	TARGET="$1"
	[ -z "$TARGET" ] && usage "Error: DNS name not specified."
#	NS=`digNameServer $TARGET`
#	if [ $? -eq 0 ]; then
#		dig +short A @$NS $TARGET
#	fi
	resolveA $TARGET
#	nslookup -type=any -query=AXFR $NS $TARGET
fi

exit 0

