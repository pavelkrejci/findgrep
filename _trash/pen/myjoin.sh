#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <mydig.sh -s output> <xmlSSLscan.sh -c|-r|-t output>"
	echo "-joins two files on domain names = mydig.sh output col #3 and xmlSSLscan.sh output col #1"
	echo "-output is sorted by IP address, domain name"
	echo "<options>"
	echo "-h = print default header row"
	exit 2
}


############################################
# OPTIONS
############################################
MODE=""
while getopts "h" opt; do
	case "$opt" in
		h)
			MODE="h"
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

FILE1="$1"
FILE2="$2"
[ ! -r "$FILE1" ] && usage "Error: Cannot read file '$FILE1'."
[ ! -r "$FILE2" ] && usage "Error: Cannot read file '$FILE2'."

############################################
# MAIN
############################################
#TODO header optional
[ "$MODE" == "h" ] && echo "#;IP;Live;DNS;TLS ver;WeakCiph;Cert Type;Self-signed;Expired;Issuer;Serial;Not valid before;Not valid after"

join -t';' -1 3 -2 1 -a 1 <(sort -t';' -k3 $FILE1) <(sort -t';' -k1 $FILE2) | awk -F';' '{printf "%s;%s;%s;",$2,$3,$1; for (i=4; i<=NF; ++i) printf "%s%s", $i, (i < NF) ? ";" : ""; printf "\n"}' | sortIP 1 | uniq | nl -s ';' -w1
#following does not keep column -f order
#join -t, -1 3 -2 1 -a 1 <(sort -t, -k3 $FILE1) <(sort -t, -k1 $FILE2) | cut -d, -f2,1


exit 0
