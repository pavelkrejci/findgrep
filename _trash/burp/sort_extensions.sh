#!/bin/bash

usage() {
	BN=`basename $0`
	echo "Usage: $BN [-n | -s] <input.json> <output.json>"
	echo "<input.json> - Burp User settings JSON"
	echo "- sorts the extensions order by -s = loaded status, -n = name"
	exit 2
}

SORT_BY=""

while getopts ":ns" opt; do
    case "$opt" in
        s)
            SORT_BY="${SORT_BY},if .loaded then 0 else 1 end"
            ;;
		n)
			SORT_BY="${SORT_BY},.name"
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

# Check for required arguments
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
	usage
    exit 1
fi

SORT_BY="${SORT_BY#,}"

if [ ! -r "$1" ]; then
	echo "Error: File $1 does not exist."
	exit 1
fi

set -x
jq ".user_options.extender.extensions |= sort_by($SORT_BY)" $1 >$2
#diff -w $1 $2
