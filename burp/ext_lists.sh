#!/bin/bash
BN=`basename $0`
usage() {
	echo "Usage: $BN [-c <Burp_user_config.json>] list1 [list2] ..."
	echo "- default config is /home/atos/.BurpSuite/UserConfigPro.json"
	echo "- enable the selected extension list"
	echo "-l = list the lists"
	exit 2
}

#default values
CONFIG_FILE="/home/atos/.BurpSuite/UserConfigPro.json"

###########################################
# extension lists
###########################################
declare -A el
el["default"]="Decoder Improved"
el["API"]="HTTP Methods Discloser,JS Link Finder,OpenAPI Parser"
#TODO

##################################
# options processing
##################################
while getopts ":c:l" opt; do
    case "$opt" in
        c)
            CONFIG_FILE="$OPTARG"
            ;;
		l)
			for key in "${!el[@]}"; do
				value="${el[$key]}"
				echo "$key: $value"
			done
			exit 0
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
if [ "$#" -lt 1 ]; then
	usage
fi

####################################
#MAIN
####################################
cp -a $CONFIG_FILE ${CONFIG_FILE}.backup

#sort by name
TMP=`mktemp --tmpdir $(basename $0).XXXXXX`
~/bin/burp/sort_extensions.sh -n $CONFIG_FILE $TMP

SE=~/bin/burp/switch_extension.sh
SE="${SE} -c $TMP"

#disable ALL first
$SE ALL false

# Iterate over all lists
for key in "$@"; do
	IFS=',' read -ra values <<< "${el["$key"]}"
	for value in "${values[@]}"; do
		$SE "$value" true
	done
done

diff -w $CONFIG_FILE $TMP

echo -n "Do you want to apply these config changes (Yy / Nn): "
read answer

# Convert the answer to lowercase for case-insensitive comparison
answer_lc=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer_lc" == "y" ]; then
    echo "Applying ..."
	set -x
	mv $TMP $CONFIG_FILE
elif [ "$answer_lc" == "n" ]; then
    echo "Exiting..."
	rm -f $TMP
else
    echo "Invalid input. Please enter 'Y' or 'N'."
fi

