#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> <nmap xml output file>"
	echo "- parse open sockets (port state='open')"
	echo "<options>:"
	echo "-i = live IPs only, no ports, DEFAULT"
	echo "-s = sort IP addresses"
	echo "-c = IP/port as CSV format, sorts by IPs by default"
	exit 2
}

############################################
# OPTIONS
############################################
MODE="i"
SORT="0"
while getopts "ics" opt; do
	case "$opt" in
		i)
			MODE="i"
            ;;
		c)
			MODE="c"
			;;
		s)
			SORT="1"
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
	#fixXML nmaprun $FILE | $XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -n
	#fixXML nmaprun $FILE | $XMLS sel --recover -T -t -m "//host[ports/port/state/@state='open']" -v "address/@addr" -n
	#both above cause memory overflow
	#this is SAX stream parser
	fixXML nmaprun $FILE | /usr/bin/python	<(cat <<EOF
import xml.sax
import sys

class MyHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.in_target_element = False
        self.in_host_element = False
        self.addr = ""

    def startElement(self, name, attrs):
        if name == "host":
            self.in_host_element = True
        elif self.in_host_element and name == "state" and attrs.get("state") == "open":
            #print(attrs.get("state"))
            self.in_target_element = True
        elif self.in_host_element and name == "address":
            self.addr=attrs.get("addr")
        #print(name)

    def endElement(self, name):
        if name == "host":
            if self.in_target_element:
                print(self.addr)
            self.in_host_element = False
            self.in_target_element = False

xml.sax.parse(sys.stdin, MyHandler())
EOF
) | sortIP $SORT

elif [ "$MODE" == "c" ]; then
	#$XMLS sel --recover -T -t -m "//host" -v "address/@addr" -o "," -m "ports/port" -v "@portid" -n input.xml > output.csv
	fixXML nmaprun $FILE | $XMLS sel --recover -T -t -m "//host/address[../ports/port[state/@state='open']]" -v "@addr" -m "../ports/port[state/@state='open']" -o "," -v "@portid" -n
#	xmlstarlet sel -t -m "//address@addr" -s "substring-before(., '.')" -s "substring-before(substring-after(., '.'), '.')" -s "substring-before(substring-after(substring-after(., '.'), '.'), '.')" -s "substring-after(substring-after(substring-after(., '.'), '.'), '.')" -v . -n $FILE

	#$XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -o "," -m "ports/port" -v "@portid" -n $FILE
	
	
	##first extract IPs and sort them
	#$XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -n $FILE | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | while read a; do
	#	$XMLS sel --recover -T -t -m "//address[@addr='$a']" -m "../ports/port[state/@state='open']" -v "@portid" -n $FILE
	#done

elif [ "$MODE" == "s" ]; then
	#/usr/bin/xsltproc <(cat <<'EOF'
	fixXML nmaprun $FILE | $XMLS tr --recover <(cat <<'EOF'
<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" version="1.0" extension-element-prefixes="exslt">
	<xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
	<xsl:template match="/">
		<xsl:for-each select="//host/address">
			<xsl:sort select="substring-before(@addr, '.')" data-type="number"/>
			<xsl:sort select="substring-before(substring-after(@addr, '.'), '.')" data-type="number"/>
			<xsl:sort select="substring-before(substring-after(substring-after(@addr, '.'), '.'), '.')" data-type="number"/>
			<xsl:sort select="substring-after(substring-after(substring-after(@addr, '.'), '.'), '.')" data-type="number"/>
			<!--			<xsl:call-template name="value-of-template">
				<xsl:with-param name="select" select="@addr"/>
			</xsl:call-template> -->
			<xsl:variable name="ip" select="@addr"/>
			<xsl:for-each select="../ports/port[state/@state='open']">
				<xsl:value-of select="$ip"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="@portid"/>
				<xsl:text>&#10;</xsl:text>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	<!--
	<xsl:template name="value-of-template">
		<xsl:param name="select"/>
		<xsl:value-of select="$select"/>
		<xsl:for-each select="exslt:node-set($select)[position()&gt;1]">
			<xsl:value-of select="'&#10;'"/>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:template> -->
</xsl:stylesheet>
EOF
)
fi

exit 0
