#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <IP address begining list file>"
	exit 2
}


CIDR="$1"
if [ -z "$CIDR" ]; then
	CIDR="/dev/stdin"
else
	[ ! -r "$CIDR" ] && usage "Error: Cannot read $CIDR"
fi

cat $CIDR | sortIP 1 

exit 0
