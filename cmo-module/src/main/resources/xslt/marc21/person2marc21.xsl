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


            <xsl:variable name="gnd_date">
                <xsl:variable name="gnd" select="string(mei:persName/mei:identifier[@type='GND']/text())"/>
                <xsl:if test="$gnd">
                    <xsl:variable name="json" select="document(concat('notnull:cmo_gnd_lobid:', $gnd))"/>
                    <xsl:if test="$json">
                        <xsl:variable name="gnd_xml" select="fn:json-to-xml($json)"/>
                        <xsl:variable name="gnd_date_birth"
                                      select="$gnd_xml/fn:map/fn:array[@key='dateOfBirth']/fn:string[1]"/>
                        <xsl:variable name="gnd_date_death"
                                      select="$gnd_xml/fn:map/fn:array[@key='dateOfDeath']/fn:string[1]"/>
                        <xsl:choose>
                            <xsl:when test="$gnd_date_birth and $gnd_date_death">
                                <xsl:variable name="gnd_short_birth"
                                              select="if (contains($gnd_date_birth, '-')) then substring-before($gnd_date_birth, '-') else $gnd_date_birth"/>
                                <xsl:variable name="gnd_short_death"
                                              select="if (contains($gnd_date_death, '-')) then substring-before($gnd_date_death, '-') else $gnd_date_death"/>
                                <xsl:value-of select="$gnd_short_birth"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="$gnd_short_death"/>
                            </xsl:when>
                            <xsl:when test="$gnd_date_death">
                                <xsl:variable name="gnd_short_death"
                                              select="if (contains($gnd_date_death, '-')) then substring-before($gnd_date_death, '-') else $gnd_date_death"/>
                                <xsl:value-of select="$gnd_short_death"/>
                                <xsl:text>a</xsl:text>
                            </xsl:when>
                            <xsl:when test="$gnd_date_birth">
                                <xsl:variable name="gnd_short_birth"
                                              select="if (contains($gnd_date_birth, '-')) then substring-before($gnd_date_birth, '-') else $gnd_date_birth"/>
                                <xsl:value-of select="$gnd_short_birth"/>
                                <xsl:text>p</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
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
                        <marc:subfield code="d">
                          <xsl:choose>
                              <xsl:when test="string-length($gnd_date) &gt; 0">
                                      <xsl:value-of select="$gnd_date"/>
                              </xsl:when>
                              <xsl:when
                                      test="mei:persName/mei:date[@type='birth'][@isodate] and mei:persName/mei:date[@type='death'][@isodate]">
                                      <xsl:value-of select="substring(mei:persName/mei:date[@type='birth']/@isodate, 1, 4)"/>
                                      <xsl:text>-</xsl:text>
                                      <xsl:value-of select="substring(mei:persName/mei:date[@type='death']/@isodate, 1, 4)"/>
                              </xsl:when>
                              <xsl:when test="mei:persName/mei:date[@type='birth'][@isodate]">
                                      <xsl:value-of select="substring(mei:persName/mei:date[@type='birth']/@isodate, 1, 4)"/>
                                      <xsl:text>p</xsl:text>
                              </xsl:when>
                              <xsl:when test="mei:persName/mei:date[@type='death'][@isodate]">
                                      <xsl:value-of select="substring(mei:persName/mei:date[@type='death']/@isodate, 1, 4)"/>
                                      <xsl:text>a</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                      <xsl:value-of select="'19.sc'"/>
                              </xsl:otherwise>
                          </xsl:choose>
                        </marc:subfield>
                        <marc:subfield code="0">
                            <xsl:value-of select="'CMO'"></xsl:value-of>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>


                <!-- Weitere Namensformen -->
                <xsl:variable name="mei" select="."/>
                <xsl:for-each
                        select="distinct-values(mei:persName/mei:name[not (@type='CMO') and not(fn:lower-case(text()) = ../mei:name[@type='CMO']/fn:lower-case(text()))]/lower-case(text()))">
                    <xsl:variable name="name" select="."/>
                    <xsl:variable name="matchingName"
                                  select="$mei/mei:persName/mei:name[not (@type='CMO') and lower-case(text())=$name][1]"/>

                    <marc:datafield tag="400" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="$matchingName"/>
                        </marc:subfield>
                        <marc:subfield code="j">
                            <xsl:text>xx</xsl:text>
                        </marc:subfield>
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