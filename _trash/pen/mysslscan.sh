#!/bin/bash

SSLSCAN=/usr/bin/sslscan

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <IP socket> | -f <IP sockets list file>"
	echo "- uses sslscan to scan single IP socket, or a file with IP sockets, one per line"
	echo "<options>:"
	echo "-n <SNI name> = use different SNI (Virtual Host) name"
	echo "-e <path to sslscan binary>"
	echo "-s sleep in msec, pause between connection request. default is 100msec"
	exit 2
}

############################################
# OPTIONS
############################################
MODE=""
SLEEP="--sleep=100"
while getopts "f:s:e:n:" opt; do
	case "$opt" in
		f)
			MODE="f"
			FILE=$OPTARG
			;;
		n)
			SNI="--sni-name=$OPTARG"
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
	CMD="$SSLSCAN --show-certificate --connect-timeout=5 --ipv4 --verbose $SLEEP $SNI --xml=$OUTXML --targets=$FILE"
	echo $CMD
	trap '' PIPE; $CMD
	echo "Result file output: $OUTXML"
else
	[ -z "$1" ] && usage "Error: IP socket not specified."
	OUTXML="out-$1.xml"
	CMD="$SSLSCAN --show-certificate --connect-timeout=5 --ipv4 --verbose $SNI --xml=$OUTXML $1"
	echo $CMD
	trap '' PIPE; $CMD
	echo "Result file output: $OUTXML"
fi


exit 0
