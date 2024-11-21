<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                exclude-result-prefixes="#all"
                version="3.0">

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>


    <xsl:template match="mycoreobject" mode="work2marc21">
        <xsl:variable name="CMO_ID" select="./@ID"/>
        <xsl:for-each select="metadata/def.meiContainer/meiContainer">
            <marc:record>
                <marc:leader>00000ndc a2200000 u 4500</marc:leader>
                <marc:controlfield tag="001">
                    <xsl:value-of select="$CMO_ID"/>
                </marc:controlfield>

                <!-- ID -->

                <marc:datafield tag="035" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="mei:work/mei:identifier"></xsl:value-of>
                    </marc:subfield>
                </marc:datafield>


                <!-- Title -->

                <xsl:if test="mei:work/mei:title">
                    <marc:datafield tag="245" ind1="1" ind2="0">
                        <xsl:choose>
                            <xsl:when test="mei:work/mei:title != ''">
                                <marc:subfield code="a">
                                    <xsl:value-of select="mei:work/mei:title"></xsl:value-of>
                                </marc:subfield>
                            </xsl:when>

                            <xsl:otherwise>
                                <marc:subfield code="a">
                                    <xsl:value-of select="'[without title]'"/>
                                </marc:subfield>
                            </xsl:otherwise>
                        </xsl:choose>
                    </marc:datafield>
                </xsl:if>

                <!-- Classification -->

                <xsl:for-each select="mei:work/mei:classification/mei:termList">
                    <marc:datafield tag="650" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="./mei:term"></xsl:value-of>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>


                <!-- Relation to Expression records -->
                <xsl:for-each select="mei:work/mei:expressionList/mei:expression">
                    <marc:datafield tag="774" ind1="0" ind2=" ">
                        <marc:subfield code="c">
                            <xsl:value-of select="./@label"/>
                        </marc:subfield>
                        <xsl:if test="./@auth.uri">
                            <marc:subfield code="n">
                                <xsl:value-of select="./@auth.uri"/>
                            </marc:subfield>
                        </xsl:if>
                        <marc:subfield code="w">
                            <xsl:value-of select="./@codedval"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <!-- ISIL -->
                <marc:datafield tag="910" ind1="2" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="'Corpus Musicae Ottomanicae'"></xsl:value-of>
                    </marc:subfield>
                    <marc:subfield code="1">
                        <xsl:value-of
                                select="'https://sigel.staatsbibliothek-berlin.de/suche/?isil=DE-4353'"></xsl:value-of>
                    </marc:subfield>
                </marc:datafield>

            </marc:record>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>