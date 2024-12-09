#!/bin/bash

BN=`basename $0`

usage() {
	echo "Usage: $BN <SCADAPASS.csv> <column_number>"
	echo "parse login:password from csv download via:"
	echo "git clone https://github.com/scadastrangelove/SCADAPASS/"
	exit 2
}


if [ -z "$2" ]; then
	usage
	exit 2
fi

SRC="$1"
COL="$2"

if [ ! -r "$SRC" ]; then
	echo "Error: $SRC not readable."
	exit 1
fi

TMP=`mktemp --tmpdir ${BN}XXXXXX.txt`
csvcut -c${COL} $SRC | tr ',' '\n' | tr -d '"' | grep -o "[^[:space:]].*:.*[^[:space:]]" >$TMP

#echo $TMP
cut -d: -f1 $TMP >usernames.txt
cut -d: -f2 $TMP >passwords.txt
wc usernames.txt passwords.txt

rm -f $TMP

