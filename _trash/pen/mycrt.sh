#!/bin/bash
#from https://academy.hackthebox.com/module/144/section/1252

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <DNS name> | -f <DNS names list file>"
	echo "- passive subdomain enumeration from crt.sh database"
	echo "- sort output by (sub) domain names, starting with TLD"
	exit 2
}

############################################
# OPTIONS
############################################
MODE=""
while getopts "f:" opt; do
	case "$opt" in
		f)
			MODE="f"
			FILE=$OPTARG
			[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."
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


if [ "$MODE" == "f" ]; then
	TOTAL=$(cat $FILE | wc -l)
	i=0
	while read TARGET; do
		((i++))
		echo "Target [$i/$TOTAL]: $TARGET" >&2
		curl -s "https://crt.sh/?q=${TARGET}&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"'
	done <$FILE | sort -u | matchDNSonly | sortTLD1st
else
	TARGET="$1"
	[ -z "$TARGET" ] && usage "Error: DNS name not specified."
	curl -s "https://crt.sh/?q=${TARGET}&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"' | sort -u | matchDNSonly | sortTLD1st
fi

exit 0

