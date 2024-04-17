#!/bin/bash
XMLS="/usr/bin/xmlstarlet"

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <SSL scan xml output file>"
	echo "<options>:"
	echo "-c = IP, DNS names as CSV format, DEFAULT"
	echo "-t = TLS and ciphers"
	echo "-s = sort IP addresses"
	exit 2
}

fixXML() {
	if grep -q -l -r "</document>" "$1"; then
		cat "$1"
	else
		echo "</document>" | cat "$1" -
	fi
}

dedupDNS() {
	while read line; do
		echo "$line" | sed 's/,.*$/,/g' | tr -d '\n'
		echo "$line" | sed 's/[DNS:| +]//g' | sed 's/,/\n/g' | tail +2 | sort | uniq | tr '\n' ',' | sed 's/,$/\n/'
	done
}

############################################
# OPTIONS
############################################
MODE="c"
while getopts "cts" opt; do
	case "$opt" in
		c)
			MODE="c"
			;;
		t)
			MODE="t"
			;;
		s)
			SORT="| sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n"
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

FILE="$1"
[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."

[ ! -x "$XMLS" ] && usage "Error: XML parser $XMLS not found."



############################################
# MAIN
############################################

if [ "$MODE" == "c" ]; then
	CMD="fixXML $FILE | $XMLS sel --recover -T -t -m '//ssltest[certificates/certificate/subject]' -n -v '@host' -m 'certificates/certificate' -o ',' -v 'subject' -o ',' -v 'altnames' | dedupDNS $SORT"
	eval $CMD
elif [ "$MODE" == "t" ]; then
	CMD="fixXML $FILE | $XMLS sel --recover -T -t -m '//ssltest[cipher]' -n -v '@host' -m 'cipher' -o ',' -v '@cipher' $SORT"
	eval $CMD
fi

exit 0
