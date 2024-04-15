#!/bin/bash
XMLS="/usr/bin/xmlstarlet"

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <SSL scan xml output file>"
	echo "<options>:"
	echo "-c = IP, DNS names as CSV format"
	echo "-s = sort IP addresses"
	exit 2
}

#TODO needed or not?
fixXML() {
	if grep -q -l -r "</document>" "$1"; then
		cat "$1"
	else
		echo "</document>" | cat "$1" -
	fi
}

############################################
# OPTIONS
############################################
MODE="c"
while getopts "cs" opt; do
	case "$opt" in
		c)
			MODE="c"
			;;
		s)
			MODE="s"
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
	#echo "List of live IPs:"
	fixXML $FILE | $XMLS sel --recover -T -t -m "//ssltest[certificates/certificate/subject]" -n -v "@host" -m "certificates/certificate" -o "," -v "subject" -o "," -v "altnames"
elif [ "$MODE" == "s" ]; then
	fixXML $FILE | $XMLS sel --recover -T -t -m "//ssltest[certificates/certificate/subject]" -n -v "@host" -m "certificates/certificate" -o "," -v "subject" -o "," -v "altnames" | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n 
fi

exit 0
