#!/bin/bash

SSLSCAN=/usr/bin/sslscan

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <IP socket> | -f <IP sockets list file>"
	echo "- uses sslscan to scan single IP socket, or a file with IP sockets, one per line"
	echo "<options>:"
	echo "-e <path to sslscan binary>"
	echo "-s sleep in msec, pause between connection request. default is 100msec"
	exit 2
}

############################################
# OPTIONS
############################################
MODE=""
SLEEP="--sleep=100"
while getopts "f:s:e:" opt; do
	case "$opt" in
		f)
			MODE="f"
			FILE=$OPTARG
			;;
		s)
			SLEEP="--sleep=$OPTARG"
			;;
		e)
			SSLSCAN=$OPTARG
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

[ ! -x "$SSLSCAN" ] && usage "Error: Cannot execute $SSLSCAN"

if [ "$MODE" == "f" ]; then
	[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."
	#broken PIPE error (exit code 141) must be ignored, otherwise sslscan fails on non HTTPS ports
	OUTXML="${FILE%.*}.xml"
	echo "Result file output: $OUTXML"
	trap '' PIPE; $SSLSCAN --ipv4 --verbose $SLEEP --xml=$OUTXML --targets=$FILE
else
	[ -z "$1" ] && usage "Error: IP socket not specified."
	echo "$1"
	trap '' PIPE; $SSLSCAN --ipv4 --verbose "$1"
	$SSLSCAN --connect-timeout 5 --openssl-timeout 5 -E -h --warnings off -oA auto $FILE
fi


exit 0