#!/bin/bash
#

usage() {
	echo $1
	BN=`basename $0`
	echo "Usage: $BN <URL list.txt> <proxy>"
	echo "e.g. <proxy> = http://127.0.0.1:8080"
	echo "- runs wget in a loop, with sleep 1"
	echo "- with proxy enabled (e.g. Burp)"
	exit 2
}

[ -z "$2" ] && usage
[ ! -r "$1" ] && usage "Error: Cannot read file $1"

http_proxy="$2"
https_proxy="$2"
ftp_proxy="$2"


while read a; do wget --verbose --no-check-certificate --user-agent=EvidenWget --timeout=5 --tries=1 $a; sleep 1; done <$1
