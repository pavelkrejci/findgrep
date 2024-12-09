#!/bin/bash

XMLS="/usr/bin/xmlstarlet"
EXPCIDR=`dirname $0`/expandCIDR.py
MYEOL="~MYOWNENDOFLINE~"

fixXML() {
	if grep -q -l -r "</$1>" "$2"; then
		cat "$2"
	else
		echo "</$1>" | cat "$2" -
	fi
}

resolveA() {
	#input either from argument or from stdin
	if [ -z "$1" ]; then
		while read T; do
			dig +short $T A
		done
	else
		dig +short $1 A
	fi
}

dedupDNS() {
	while read line; do
		#omit empty lines
		if [ -n "$line" ]; then
			echo "$line" | sed 's/,.*$/,/g' | tr -d '\n'
			echo "$line" | sed -e 's/DNS://g' -e 's/, */\n/g' | tail +2 | sort -u | tr '\n' ',' | sed 's/,$/\n/'
		fi
	done
}

parseSAN() {
	#for parsing subject alt names (SAN) on a single line
	sed 's/DNS:/\n/g' /dev/stdin | sed 's/[_, ]*//g' | sed '/^$/d'
}

matchDNSonly() {
	grep -E -o "^([a-zA-Z0-9*-]+\.)+[a-zA-Z]{2,}$" /dev/stdin
	
}

sortTLD1st() {
	cat - |	perl -lne 'print join ".", reverse(split /\./)' |  # Reverse order of fields
	sort |  # Sort
	perl -lne 'print join ".", reverse(split /\./)' # reverse order again
}

sortIP() {
	#argument empty or 0 --> do not sort, otherwise sort
	if [[ -z "$1" || "$1" -eq 0 ]]; then
		cat
	else
		sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n /dev/stdin
	fi
}

emptyLines() {
	sed '/^$/d' /dev/stdin
}

chomp() {
	sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e ':a;N;$!ba;s/\n//g' /dev/stdin

}

onlyIPs() {
	grep -oE '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' /dev/stdin
}

CIDRfilterIP() {
	expandCIDR.py $1 | grep $2
}
