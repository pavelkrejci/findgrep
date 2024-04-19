#!/bin/bash
#from https://academy.hackthebox.com/module/144/section/1252

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: <options> $BN <DNS name> | -f <DNS names list file>"
	echo "- passive subdomain enumeration from crt.sh database"
	echo "<options>:"
	echo "-r = resolve harvested domains into IPs"
	exit 2
}

############################################
# OPTIONS
############################################
MODE=""
while getopts "rf:" opt; do
	case "$opt" in
		r)
			MODE="r"
			;;
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
	while read TARGET; do
		curl -s "https://crt.sh/?q=${TARGET}&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"'
	done <$FILE | sort -u | matchDNSonly | sortTLD1st
else
	TARGET="$1"
	[ -z "$TARGET" ] && usage "Error: DNS name not specified."
	curl -s "https://crt.sh/?q=${TARGET}&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"' | sort -u | matchDNSonly | sortTLD1st
fi

exit 0


#curl -s "https://crt.sh/?q=${TARGET}&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"' | sort -u
