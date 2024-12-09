#!/bin/bash

BN=`basename $0`

usage() {
	echo "Usage: $BN -c <Burp_user_config.json> <extension_name> [true|false]"
	echo "- switch the extension attribute \"loaded\" to true|false"
	echo "- BEWARE: extension name ALL will make it for all"
	exit 2
}

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then usage; fi

# Default values
CONFIG_FILE=""
EXTENSION_NAME=""
STATUS=""

while getopts ":c:" opt; do
    case "$opt" in
        c)
            CONFIG_FILE="$OPTARG"
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

EXTENSION_NAME="$1"
STATUS="$2"

if [ ! -w "$CONFIG_FILE" ]; then
	echo "Error: File $CONFIG_FILE is not writable"
	exit 1
fi

if [ "$STATUS" != "true" -a "$STATUS" != "false" ]; then
	echo "Error: Invalid status: $STATUS (must be 'true' or 'false')"
	exit 1
fi
TMP=`mktemp --tmpdir ${BN}XXXXXXXX.json`
# Backup the original file
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

if [ "$EXTENSION_NAME" == "ALL" ]; then
	echo -n "Setting ALL extensions to: $STATUS: "
	jq --argjson status $STATUS '.user_options.extender.extensions |= map(.loaded = $status)' "$CONFIG_FILE" > $TMP
else
	echo -n "Enabling extension: $EXTENSION_NAME: "
	jq --arg name "$EXTENSION_NAME" --argjson status $STATUS '.user_options.extender.extensions |= map(if .name == $name then .loaded = $status else . end)' "$CONFIG_FILE" > $TMP
fi
if [ $? -eq 0 ]; then
	echo OK
	#diff -w "$CONFIG_FILE" "$TMP"
	#echo $TMP
	mv "$TMP" "$CONFIG_FILE"
else
	echo NOK
	rm -f $TMP
fi


