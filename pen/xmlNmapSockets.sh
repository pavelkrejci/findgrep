#!/bin/bash
XMLS="/usr/bin/xmlstarlet"

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

fixXML() {
	if grep -q -l -r "</nmaprun>" "$1"; then
		cat "$1"
	else
		echo "</nmaprun>" | cat "$1" -
	fi
}

############################################
# OPTIONS
############################################
MODE="i"
while getopts "ics" opt; do
	case "$opt" in
		i)
			MODE="i"
            ;;
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

if [ "$MODE" == "i" ]; then
	#echo "List of live IPs:"
	fixXML $FILE | $XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -n
elif [ "$MODE" == "c" ]; then
	#$XMLS sel --recover -T -t -m "//host" -v "address/@addr" -o "," -m "ports/port" -v "@portid" -n input.xml > output.csv
	fixXML $FILE | $XMLS sel --recover -T -t -m "//host/address[../ports/port[state/@state='open']]" -v "@addr" -m "../ports/port[state/@state='open']" -o "," -v "@portid" -n
#	xmlstarlet sel -t -m "//address@addr" -s "substring-before(., '.')" -s "substring-before(substring-after(., '.'), '.')" -s "substring-before(substring-after(substring-after(., '.'), '.'), '.')" -s "substring-after(substring-after(substring-after(., '.'), '.'), '.')" -v . -n $FILE

	#$XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -o "," -m "ports/port" -v "@portid" -n $FILE
	
	
	##first extract IPs and sort them
	#$XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -n $FILE | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | while read a; do
	#	$XMLS sel --recover -T -t -m "//address[@addr='$a']" -m "../ports/port[state/@state='open']" -v "@portid" -n $FILE
	#done

elif [ "$MODE" == "s" ]; then
	#/usr/bin/xsltproc <(cat <<'EOF'
	fixXML $FILE | $XMLS tr --recover <(cat <<'EOF'
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
