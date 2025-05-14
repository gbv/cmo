<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:table="http://www.corpus-musicae-ottomanicae.de/ns/table"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="3.0">

    <xsl:param name="CurrentLang"/>

    <xsl:template match="table:tables">
        <fo:root font-family="Carlito" font-size="8pt" language="{$CurrentLang}" hyphenate="true">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="tables"
                                       page-width="297mm" page-height="210mm">
                    <fo:region-body region-name="xsl-region-body" margin="1cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>

            <fo:page-sequence master-reference="tables">   <!-- (in Versionen < 2.0 "master-name") -->
                <fo:flow flow-name="xsl-region-body">
                    <xsl:apply-templates/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <xsl:attribute-set name="Ueberschrift1">
        <xsl:attribute name="font-size">18pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="text-align">center</xsl:attribute>
        <xsl:attribute name="space-before">30mm</xsl:attribute>
        <xsl:attribute name="space-after">10mm</xsl:attribute>
        <xsl:attribute name="keep-with-next">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template match="table:table">
        <xsl:if test=".//table:td">
            <xsl:if test="table:h1">
                <fo:block xsl:use-attribute-sets="Ueberschrift1" hyphenate="false">
                    <xsl:value-of select="table:h1/text()"/>
                </fo:block>
            </xsl:if>
            <fo:table break-after="page" border-color="#000000" border-style="inset" border-width="1pt">
                <xsl:apply-templates/>
            </fo:table>
        </xsl:if>
    </xsl:template>

    <xsl:template match="table:h1">
    </xsl:template>

    <xsl:template match="table:thead">
        <fo:table-header>
            <fo:table-row>
                <xsl:apply-templates/>
            </fo:table-row>
        </fo:table-header>
    </xsl:template>

    <xsl:template match="table:tbody">
        <fo:table-body>
            <xsl:apply-templates/>
        </fo:table-body>
    </xsl:template>


    <xsl:template match="table:a">
        <xsl:value-of select="text()"/>
    </xsl:template>

    <xsl:template match="table:th|table:td">
        <fo:table-cell border-color="#000000" padding="0.097cm" border-style="inset" border-width="1pt">
            <fo:block  wrap-option="wrap" overflow="hidden">
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>

    <xsl:template match="table:th/text()|table:td/text()|a/text()">
        <xsl:value-of select="replace(.,'([a-zA-Z0-9])','$1&#8203;')" />
    </xsl:template>

    <xsl:template match="table:tr">
        <fo:table-row>
            <xsl:apply-templates/>
        </fo:table-row>
    </xsl:template>


</xsl:stylesheet>
