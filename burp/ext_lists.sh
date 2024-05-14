#!/bin/bash
BN=`basename $0`
usage() {
	echo "Usage: $BN [-c <Burp_user_config.json>] [-o <Output_user_config.json>] list1 [list2] ..."
	echo "- default input config is /home/atos/.BurpSuite/UserConfigPro.json"
	echo "- if no -o specified, the input config is replaced"
	echo "- enable the selected extension list"
	echo "-l = list the lists"
	exit 2
}

#default values
CONFIG_FILE="/home/atos/.BurpSuite/UserConfigPro.json"
OUT_FILE=""

###########################################
# extension lists
###########################################
declare -A el
#TODO maybe useful: CSTC, Modular HTTP Manipulator
#would require commas change to ; as separator
el["default"]="Decoder Improved,ExifTool Scanner,Request Minimizer,Software Version Reporter"
el["API"]="HTTP Methods Discloser,JS Link Finder,OpenAPI Parser,Filter Options Method"
el["ActiveScan"]="Active Scan++,Additional CSRF Checks"
el["PassiveScan"]="Headers Analyzer,Additional Scanner Checks,Software Version Reporter,Software Vulnerability Scanner"
el["CSRF"]="CSRF Scanner,CSRF Token Tracker,Additional CSRF Checks"
el["Authenticate"]="Auth Analyzer,Authentication Token Obtain and Replace,OAUTH Scan,OAuth2 Token Grabber,Session Auth,Detect Dynamic JS"
el["Autorize"]="Autorize"
el["SSI"]="Backslash Powered Scanner"
el["SQL"]="NoSQLi Scanner,SQLMap DNS Collaborator,SQLiPy Sqlmap Integration"
#TODO Collaborator Everywhere might cause problems
el["Collaborator"]="SQLMap DNS Collaborator,Collabfiltrator,Collaborator Everywhere,PHP Object Injection Slinger"
el["CommandInjection"]="Command Injection Attacker,PHP Object Injection Check,PHP Object Injection Slinger"
el["FileUpload"]="File Upload Traverser,Upload Scanner"
el["ResponseIntercept"]="HTTP Mock"
el["CSRF"]="CSRF Token Tracker,Token Extractor,Additional CSRF Checks,CSRF Scanner"
el["XSS"]="XSS Cheatsheet,Additional Scanner Checks,Upload Scanner,Paramalyzer,Reflected Parameters"
#Warning: Collaborator Everywhere logs hits into event log and console, but Collaborator GUI is empty!!! Switch off to interact with the Collaborator tab manually again.
el["SSRF"]="Collaborator Everywhere,DNS Analyzer,Upload Scanner"
el["CMS"]="CMS Scanner"


##################################
# options processing
##################################
while getopts ":c:lo:" opt; do
    case "$opt" in
        c)
            CONFIG_FILE="$OPTARG"
            ;;
		o)
			OUT_FILE="$OPTARG"
			;;
		l)
			for key in $(echo "${!el[@]}" | tr ' ' '\n' | sort); do
				value="${el[$key]}"
				printf "| %-20s | %-20s |\n" "$key" "$value"
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
if [ -z "$OUT_FILE" ]; then
	cp -a $CONFIG_FILE ${CONFIG_FILE}.backup
	TMP=`mktemp --tmpdir $(basename $0).XXXXXX`
else
	TMP="$OUT_FILE"
fi

#sort by name
~/bin/burp/sort_extensions.sh -n $CONFIG_FILE $TMP

SE=~/bin/burp/switch_extension.sh
SE="${SE} -c $TMP"

#disable ALL first
$SE ALL false

# Iterate over all lists
for key in "$@"; do
	IFS=',' read -ra values <<< "${el["$key"]}"
	for value in "${values[@]}"; do
		set -x
		$SE "$value" true
		set +x
	done
done

diff -w $CONFIG_FILE $TMP

if [ -z "$OUT_FILE" ]; then
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
else
	echo "Saved to $TMP."
fi
