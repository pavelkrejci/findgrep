#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <CIDR ranges list file>"
	echo "- filters stdin by IP in the range"
	exit 2
}


CIDR="$1"
[ ! -r "$CIDR" ] && usage "Error: Cannot read $CIDR"
[ ! -x "$EXPCIDR" ] && usage "Error: Cannot execute $EXPCIDR"

temp=$(mktemp -p /dev/shm)

#create list of all IPs first
while read range; do
	expandCIDR.py $range
done <$CIDR >$temp

while read ip; do
	ip2=$(echo "$ip" | onlyIPs)
	grep -q "$ip2" $temp && echo $ip
done

rm -f $temp

exit 0
