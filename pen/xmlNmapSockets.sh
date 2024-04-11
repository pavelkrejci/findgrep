#!/bin/bash

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <nmap xml output file>"
	echo "- parse open sockets (port state='open')"
	echo "<options>:"
	echo "-i = live IPs only"
	echo "-c = IP/port as CSV format"
	echo "-s = sort IP addresses"
	exit 2
}

XMLS="/usr/bin/xmlstarlet"
############################################
# OPTIONS
############################################
MODE="i"
SORT=0
while getopts "ic" opt; do
	case "$opt" in
		i)
			MODE="i"
            ;;
		c)
			MODE="c"
			;;
		s)
			SORT=1
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

if [ "$MODE" == "i" ]; then
	#echo "List of live IPs:"
	$XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -n $FILE
elif [ "$MODE" == "c" ]; then
	#$XMLS sel --recover -T -t -m "//host" -v "address/@addr" -o "," -m "ports/port" -v "@portid" -n input.xml > output.csv
	$XMLS sel --recover -T -t -m "//host/address[../ports/port[state/@state='open']]" -v "@addr" -m "../ports/port[state/@state='open']" -o "," -v "@portid" -n $FILE
#	xmlstarlet sel -t -m "//address@addr" -s "substring-before(., '.')" -s "substring-before(substring-after(., '.'), '.')" -s "substring-before(substring-after(substring-after(., '.'), '.'), '.')" -s "substring-after(substring-after(substring-after(., '.'), '.'), '.')" -v . -n $FILE

	#$XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -o "," -m "ports/port" -v "@portid" -n $FILE
	
	
	##first extract IPs and sort them
	#$XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -n $FILE | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | while read a; do
	#	$XMLS sel --recover -T -t -m "//address[@addr='$a']" -m "../ports/port[state/@state='open']" -v "@portid" -n $FILE
	#done


fi

exit 0
