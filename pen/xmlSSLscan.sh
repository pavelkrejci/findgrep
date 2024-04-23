#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <SSL scan xml output file>"
	echo "<options>:"
	echo "-c = DEFAULT, Host IP/DNS plus DNS names, CSV format"
	echo "-d = domain names only, sorted, deduplicated"
	echo "-t = IP and TLS and ciphers"
	echo "-r = Host IP/DNS and certificate info"
	echo "-s = sort IP addresses"
	exit 2
}


############################################
# OPTIONS
############################################
MODE="c"
while getopts "cdrts" opt; do
	case "$opt" in
		c)
			MODE="c"
			;;
		d)
			MODE="d"
			;;
		t)
			MODE="t"
			;;
		r)
			MODE="r"
			;;
		s)
			SORT="| sortIP"
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
	CMD="fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[certificates/certificate/subject]' -n -v '@host' -m 'certificates/certificate' -o ',' -v 'subject' -o ',' -v 'altnames' | dedupDNS $SORT"
	eval $CMD
elif [ "$MODE" == "d" ]; then
	CMD="fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[certificates/certificate/subject]' -m 'certificates/certificate'  -v 'subject' -n -v 'altnames' -n | parseSAN | matchDNSonly | sort -u | sortTLD1st"
	eval $CMD
elif [ "$MODE" == "r" ]; then
	CMD="fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[certificates/certificate/subject]' -n -v '@host' -m 'certificates/certificate' -o ',' -v 'pk/@type' -v 'pk/@bits' -o ',' -v 'self-signed' -o ',' -v 'expired' -o ',' -v 'issuer' -o ',' -v 'not-valid-before' -o ',' -v 'not-valid-after' $SORT"
	eval $CMD
elif [ "$MODE" == "t" ]; then
	CMD="fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[cipher]' -n -v '@host' -m 'cipher' -o ',' -v '@cipher' $SORT"
	eval $CMD
fi

exit 0
