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
