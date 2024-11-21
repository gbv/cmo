<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                exclude-result-prefixes="mei marc"
                version="3.0">


    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:include href="resource:xslt/marc21/expression2marc21.xsl" />
    <xsl:include href="resource:xslt/marc21/source2marc21.xsl" />
    <xsl:include href="resource:xslt/marc21/person2marc21.xsl" />
    <xsl:include href="resource:xslt/marc21/work2marc21.xsl" />

    <xsl:template match="/">
        <xsl:variable name="id" select="mycoreobject/@ID" />
        <xsl:variable name="type" select="substring-before(substring-after($id, '_'), '_')"/>

        <xsl:choose>
            <xsl:when test="$type ='expression'">
                <xsl:apply-templates select="mycoreobject" mode="expression2marc21"/>
            </xsl:when>
            <xsl:when test="$type='source'">
                <xsl:apply-templates select="mycoreobject" mode="source2marc21"/>
            </xsl:when>
            <xsl:when test="$type='person'">
                <xsl:apply-templates select="mycoreobject" mode="person2marc21"/>
            </xsl:when>
            <xsl:when test="$type='work'">
                <xsl:apply-templates select="mycoreobject" mode="work2marc21"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Unsupported type: <xsl:value-of select="$type"/></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>