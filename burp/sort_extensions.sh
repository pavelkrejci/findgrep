#!/bin/bash

usage() {
	BN=`basename $0`
	echo "Usage: $BN <input.json> <output.json>"
	echo "<input.json> - Burp User settings JSON"
	echo "- sorts the extensions order by loaded, name"
	exit 2
}

[ -z "$2" ] && usage

jq '.user_options.extender.extensions |= sort_by(if .loaded then 0 else 1 end,.name)' $1 >$2
