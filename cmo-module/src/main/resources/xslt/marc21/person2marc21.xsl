<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="marc mei"
                version="3.0">

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="mycoreobject" mode="person2marc21">
        <xsl:variable name="CMO_ID" select="./@ID"/>
        <xsl:for-each select="metadata/def.meiContainer/meiContainer">
            <xsl:variable name="gnd" select="string(mei:persName/mei:identifier[@type='GND']/text())"/>
            <xsl:variable name="json" select="document(concat('notnull:cmo_gnd_lobid:', $gnd))"/>
            <xsl:variable name="gnd_date">
                <xsl:variable name="gnd_xml" select="fn:json-to-xml($json)"/>
                <xsl:if test="$gnd_xml">
                    <xsl:variable name="deathElementCount"
                                  select="count($gnd_xml/fn:map/fn:array[@key='dateOfDeath']/fn:string)"/>
                    <xsl:variable name="birthElementCount"
                                  select="count($gnd_xml/fn:map/fn:array[@key='dateOfBirth']/fn:string)"/>
                    <xsl:variable name="largerElement"
                                  select="if ($deathElementCount &gt; $birthElementCount) then $gnd_xml/fn:map/fn:array[@key='dateOfDeath'] else $gnd_xml/fn:map/fn:array[@key='dateOfBirth']"/>
                    <xsl:for-each select="$largerElement">
                        <xsl:variable name="birthDate"
                                      select="$gnd_xml/fn:map/fn:array[@key='dateOfBirth']/fn:string[position()]"/>
                        <xsl:variable name="deathDate"
                                      select="$gnd_xml/fn:map/fn:array[@key='dateOfDeath']/fn:string[position()]"/>
                        <xsl:choose>
                            <xsl:when test="$birthDate and $deathDate">
                                <xsl:value-of select="$birthDate"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="$deathDate"/>
                            </xsl:when>
                            <xsl:when test="$deathDate">
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="$deathDate"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$birthDate"/>
                                <xsl:text>-</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position() != last()">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:variable>
            <marc:record>
                <marc:leader>00000nz 2200000nu 4500</marc:leader>
                <marc:controlfield tag="001">
                    <xsl:value-of select="$CMO_ID"/>
                </marc:controlfield>

                <!-- ID -->

                <marc:datafield tag="024" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="mei:persName/mei:identifier"></xsl:value-of>
                    </marc:subfield>
                    <marc:subfield code="2">
                        <xsl:value-of select="'DNB'"></xsl:value-of>
                    </marc:subfield>

                </marc:datafield>


                <!-- Name Type CMO in 100? -->


                <xsl:if test="mei:persName/mei:name[@type='CMO'] or mei:persName/mei:date[@type='CMO']">
                    <marc:datafield tag="100" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:persName/mei:name[@type='CMO']"/>
                        </marc:subfield>
                        <xsl:choose>
                            <xsl:when test="mei:persName/mei:name/mei:date or mei:persName/mei:date">
                                <xsl:choose>
                                    <xsl:when test="mei:persName/mei:name/mei:date or mei:persName/mei:date">
                                        <marc:subfield code="d">
                                            <xsl:value-of select="$gnd_date"/>
                                        </marc:subfield>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>

                            <xsl:otherwise>
                                <marc:subfield code="d">
                                    <xsl:value-of select="'19.sc'"/>
                                </marc:subfield>
                            </xsl:otherwise>
                        </xsl:choose>
                        <marc:subfield code="0">
                            <xsl:value-of select="'CMO'"></xsl:value-of>
                        </marc:subfield>
                        <xsl:choose>
                            <xsl:when test="mei:persName/mei:name/mei:date or mei:persName/mei:date">
                                <marc:subfield code="y">
                                    <xsl:value-of select="//mei:date"/>
                                </marc:subfield>
                            </xsl:when>
                            <xsl:otherwise></xsl:otherwise>
                        </xsl:choose>
                    </marc:datafield>
                </xsl:if>


                <!-- Weitere Namensformen -->

                <xsl:for-each select="mei:persName[not (@type='CMO')]">

                    <marc:datafield tag="400" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:name"/>
                        </marc:subfield>
                        <xsl:choose>
                            <xsl:when test="mei:name/mei:date or mei:date">
                                <marc:subfield code="d">
                                    <xsl:value-of select="$gnd_date"/>
                                </marc:subfield>
                            </xsl:when>

                            <xsl:otherwise>
                                <marc:subfield code="d">
                                    <xsl:value-of select="'19.sc'"/>
                                </marc:subfield>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="./@source">
                            <marc:subfield code="w">
                                <xsl:value-of select="./@source"/>
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>


                </xsl:for-each>


                <!-- Notes -->

                <xsl:for-each select="mei:persName/mei:date">
                    <marc:datafield tag="678" ind1=" " ind2=" ">
                        <marc:subfield code="b">
                            <xsl:value-of select="./@calendar"></xsl:value-of>
                            <xsl:text> : </xsl:text>

                            <xsl:value-of select="."></xsl:value-of>
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="./@type"></xsl:value-of>
                            <xsl:text>)</xsl:text>
                            <xsl:if test="./@notbefore">
                                <xsl:text> (Not before: </xsl:text>
                                <xsl:value-of select="./@notbefore"></xsl:value-of>
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                            <xsl:if test="./@notafter">
                                <xsl:text> (Not after: </xsl:text>
                                <xsl:value-of select="./@notafter"></xsl:value-of>
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <xsl:for-each select="mei:persName/mei:annot">
                    <marc:datafield tag="678" ind1=" " ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="./@label"></xsl:value-of>
                        </marc:subfield>
                        <marc:subfield code="b">
                            <xsl:value-of select="."></xsl:value-of>
                        </marc:subfield>
                        <marc:subfield code="w">
                            <xsl:value-of select="./@source"></xsl:value-of>
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