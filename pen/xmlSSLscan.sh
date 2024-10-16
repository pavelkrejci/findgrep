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

if [ "$MODE" == "c" ]; then
#	CMD="fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[certificates/certificate[@type=\"short\"]/subject]' -v '@host' -m 'certificates/certificate' -o ',' -v 'subject' -o ',' -v 'altnames' -n"
	fixXML document $FILE | $XMLS tr --recover <(cat <<'EOF'
<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" version="1.0" extension-element-prefixes="exslt">
	<xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
	<xsl:template match="/">
		<xsl:for-each select="//ssltest[certificates/certificate/subject]">
			<xsl:variable name="ip" select="@host"/>
			<xsl:for-each select="certificates/certificate[@type='short']">
				<xsl:value-of select="$ip"/>
				<xsl:text>,</xsl:text>
				<xsl:value-of select="subject"/>
				<xsl:for-each select="altnames">
					<xsl:text>,</xsl:text>
					<xsl:value-of select="."/>
				</xsl:for-each>
				<xsl:text>&#10;</xsl:text>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
EOF
) | dedupDNS | sortIP $SORT
elif [ "$MODE" == "d" ]; then
	fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[certificates/certificate/subject]' -m 'certificates/certificate[@type="short"]'  -v 'subject' -n -v 'altnames' -n | parseSAN | matchDNSonly | sort -u | sortTLD1st
elif [ "$MODE" == "r" ]; then
	#fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[certificates/certificate/subject]' -n -v '@host' -o ';' -m 'protocol[@enabled="1"]' -v 'translate(@type,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")' -v '@version' -o ' ' -m '../certificates/certificate[@type="short"]' -o ';' -v 'pk/@type' -v 'pk/@bits' -o ';' -v 'self-signed' -o ';' -v 'expired' -o ';' -m '../../certificates/certificate[@type="full"]' -v 'issuer' -o ';' -v 'serial' -o ';' -v 'not-valid-before' -o ';' -v 'not-valid-after' | emptyLines | sortIP $SORT
#	fixXML document $FILE | $XMLS sel -C --recover -T -t -m '//ssltest[certificates/certificate/subject]' -n -v '@host' -o ';' -m 'protocol[@enabled="1"]' -v 'translate(@type,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")' -v '@version' -o ' ' -m '../certificates/certificate[@type="short"]' -o ';' -v 'pk/@type' -v 'pk/@bits' -o ';' -v 'self-signed' -o ';' -v 'expired' -o ';' -m '../../certificates/certificate[@type="full"]' -v 'issuer' -o ';' -v 'serial' -o ';' -v 'not-valid-before' -o ';' -v 'not-valid-after'

	fixXML document $FILE | $XMLS tr --recover <(cat <<'EOF'
<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" version="1.0" extension-element-prefixes="exslt">
  <xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
  <xsl:template match="/">
  <xsl:for-each select="//ssltest[certificates/certificate/subject]">
	<xsl:value-of select="@host"/>
	<xsl:text>:</xsl:text>
	<xsl:value-of select="@port"/>
	<xsl:text>;</xsl:text>
	<xsl:for-each select="protocol[@enabled='1']">
	  <xsl:value-of select="translate(@type,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
	  <xsl:value-of select="@version"/>
	  <xsl:if test="position() != last()">
	    <xsl:text> </xsl:text>
	  </xsl:if>
	</xsl:for-each>
	<xsl:text>;</xsl:text>
	<xsl:for-each select="cipher[not(@strength='strong') and not(@strength='acceptable')]">
	  <xsl:value-of select="@sslversion"/>
	  <xsl:text> </xsl:text>
	  <xsl:value-of select="@cipher"/>
	  <xsl:if test="position() != last()">
	    <xsl:text>,</xsl:text>
	  </xsl:if>
	</xsl:for-each>
	<xsl:text>;</xsl:text>
	<xsl:for-each select="certificates/certificate[@type='short']">
	  <xsl:value-of select="pk/@type"/>
	  <xsl:value-of select="pk/@bits"/>
	  <xsl:text>;</xsl:text>
	  <xsl:value-of select="self-signed"/>
	  <xsl:text>;</xsl:text>
	  <xsl:value-of select="expired"/>
	</xsl:for-each>
	<xsl:text>;</xsl:text>
	<xsl:for-each select="certificates/certificate[@type='full']">
      <xsl:value-of select="issuer"/>
	  <xsl:text>;</xsl:text>
	  <xsl:value-of select="serial"/>
	  <xsl:text>;</xsl:text>
	  <xsl:value-of select="not-valid-before"/>
	  <xsl:text>;</xsl:text>
	  <xsl:value-of select="not-valid-after"/>
	</xsl:for-each>
	<xsl:text>&#10;</xsl:text>
  </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
EOF
) | sortIP $SORT
elif [ "$MODE" == "t" ]; then
	fixXML document $FILE | $XMLS sel --recover -T -t -m '//ssltest[cipher]' -n -v '@host' -o ':' -v '@port' -m 'cipher' -o ',' -v '@cipher' | sortIP $SORT
fi

exit 0
