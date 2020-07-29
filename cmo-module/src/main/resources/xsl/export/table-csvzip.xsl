<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:table="http://www.corpus-musicae-ottomanicae.de/ns/table"
                xmlns:zip="http://mycore.de/ns/zip"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                version="3.0">

    <xsl:template match="table:tables">
        <zip:zip>
            <xsl:apply-templates />
        </zip:zip>
    </xsl:template>

    <xsl:template match="table:table">
        <xsl:if test="count(.//table:td)&gt;0">
            <zip:entry fileName="{@id}.csv" type="text">
                <xsl:apply-templates />
            </zip:entry>
        </xsl:if>
    </xsl:template>

    <xsl:template match="table:tbody">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="table:h1">
    </xsl:template>

    <xsl:template match="table:a">
        <xsl:value-of select="text()" />
    </xsl:template>

    <xsl:template match="table:thead|table:tr">
        <xsl:for-each select="table:th|table:td">
            <xsl:variable name="computed">
                <xsl:apply-templates select="node()" />
            </xsl:variable>
            <xsl:if test="position()>1">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>&quot;</xsl:text><xsl:value-of select="$computed"/><xsl:text>&quot;</xsl:text>
        </xsl:for-each><xsl:text>&#xA;</xsl:text>
    </xsl:template>


</xsl:stylesheet>
