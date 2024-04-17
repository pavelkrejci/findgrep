#!/bin/bash


# testssl.sh arguments:
# --connect-timeout <seconds>   useful to avoid hangers. Max <seconds> to wait for the TCP socket connect to return
#      --openssl-timeout <seconds>   useful to avoid hangers. Max <seconds> to wait before openssl connect will be terminated
#-E, --cipher-per-proto        checks those per protocol

#    -h, --header, --headers       tests HSTS, HPKP, server/app banner, security headers, cookie, reverse proxy, IPv4 address

#   -U, --vulnerable              tests all (of the following) vulnerabilities (if applicable)
#

#  --out(f,F)ile|-oa/-oA <fname> log to a LOG,JSON,CSV,HTML file (see nmap). -oA/-oa: pretty/flat JSON.

TESTSSL=~/bin/pen/testssl.sh/testssl.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <IP:port> | <IP sockets list file>"
	echo "- uses ~/bin/pen/testssl.sh/testssl.sh to scan single IP socket or"
	echo "-f = file with IP sockets, one per line"
	echo "-s <path to testssl.sh>"
	exit 2
}

############################################
# OPTIONS
############################################
MODE=""
while getopts "fs:" opt; do
	case "$opt" in
		f)
			MODE="f"
			;;
		s)
			TESTSSL=$OPTARG
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

FILE="$1"
[ ! -x "$TESTSSL" ] && usage "Error: Cannot execute $TESTSSL"
[ -z "$FILE" ] && usage "Error: IP socket(s) not specified."

if [ "$MODE" == "f" ]; then
	[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."
	$TESTSSL --connect-timeout 5 --openssl-timeout 5 -E -h -oA auto --file $FILE
else
	$TESTSSL --connect-timeout 5 --openssl-timeout 5 -E -h --warnings off -oA auto $FILE
fi


exit 0
