#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <hostname> <port>" 
	echo "use hping3 to measure TCP connect time"
	exit 2
}


############################################
# OPTIONS
############################################
[ -z "$2" ] && usage 

############################################
# MAIN
############################################
#TIMEFORMAT=%3R; time nc -zw30 $1 $2

sudo hping3 -c 3 -S -p $2 $1

exit 0
