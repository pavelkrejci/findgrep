#!/bin/bash
#
#from https://academy.hackthebox.com/module/144/section/1252

usage() {
	BN=`basename $0`
	echo "Usage: $BN <domain name>"
	echo "passive subdomain enumeration from crt.sh database"
	exit 2
}

[ -z "$1" ] && usage
TARGET="$1"

curl -s "https://crt.sh/?q=${TARGET}&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"' | sort -u
