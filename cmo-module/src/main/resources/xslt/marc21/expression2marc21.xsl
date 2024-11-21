<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                exclude-result-prefixes="marc mei"
                version="3.0">

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Root Element -->
    <xsl:template match="mycoreobject" mode="expression2marc21">
        <xsl:variable name="CMO_ID" select="./@ID"/>
        <xsl:for-each select="metadata/def.meiContainer/meiContainer">
            <marc:record>
                <marc:leader>00000ndc a2200000 u 4500</marc:leader>

                <marc:controlfield tag="001">
                    <xsl:value-of select="$CMO_ID"/>
                </marc:controlfield>


                <!-- Incipit -->
                <xsl:for-each select="mei:expression/mei:incip/mei:incipText">
                    <marc:datafield tag="031" ind1=" " ind2=" ">
                        <marc:subfield code="t">
                            <xsl:value-of select="./mei:p" />
                        </marc:subfield>
                        <xsl:if test="./@xml:lang">
                            <marc:subfield code="q">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:if>
                        <xsl:if test="./@label">
                            <marc:subfield code="q">
                                <xsl:value-of select="./@label" />
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>
                </xsl:for-each>


                <!-- Language -->
                <xsl:for-each select="mei:expression/mei:title[@type='orig']">
                    <marc:datafield tag="041" ind1=" " ind2="7">
                        <marc:subfield code="a">
                            <xsl:value-of select="./@xml:lang" />
                        </marc:subfield>
                        <marc:subfield code="2">
                            <xsl:value-of select="'rfc5646'" />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <!-- Composer -->
                <xsl:if test="mei:expression/mei:composer">
                    <marc:datafield tag="100" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:expression/mei:composer/mei:persName" />
                        </marc:subfield>
                        <xsl:if test="mei:expression/mei:composer/mei:persName/@nymref">
                            <marc:subfield code="0">
                                <xsl:value-of select="mei:expression/mei:composer/mei:persName/@nymref" />
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>
                </xsl:if>


                <!-- Title -->
                <xsl:if test="mei:expression/mei:title[@type='uniform']">
                    <marc:datafield tag="240" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:expression/mei:title[@type='uniform']" />
                        </marc:subfield>
                        <xsl:for-each select="mei:expression/mei:title[@type='uniform'][@xml:lang]">
                            <marc:subfield code="y">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:for-each>
                    </marc:datafield>
                </xsl:if>

                <xsl:if test="mei:expression/mei:title[@type='main']">
                    <marc:datafield tag="242" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:expression/mei:title[@type='main']" />
                        </marc:subfield>
                        <xsl:for-each select="mei:expression/mei:title[@type='main'][@xml:lang]">
                            <marc:subfield code="y">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:for-each>

                    </marc:datafield>
                </xsl:if>

                <xsl:if test="mei:expression/mei:title[@type='index']">
                    <marc:datafield tag="242" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:expression/mei:title[@type='index']" />
                        </marc:subfield>
                        <xsl:for-each select="mei:expression/mei:title[@type='index'][@xml:lang]">
                            <marc:subfield code="y">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:for-each>

                    </marc:datafield>
                </xsl:if>


                <xsl:if test="mei:expression/mei:title[@type='orig_index']">
                    <marc:datafield tag="242" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:expression/mei:title[@type='orig_index']" />
                        </marc:subfield>
                        <xsl:for-each select="mei:expression/mei:title[@type='orig_index'][@xml:lang]">
                            <marc:subfield code="y">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:for-each>

                    </marc:datafield>
                </xsl:if>


                <xsl:if test="mei:expression/mei:title[@type='orig']">
                    <marc:datafield tag="245" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:expression/mei:title[@type='orig']" />
                        </marc:subfield>
                        <xsl:if test="mei:expression/mei:title[@type='sub']">
                            <marc:subfield code="b">
                                <xsl:value-of select="mei:expression/mei:title[@type='sub']" />
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>
                </xsl:if>

                <xsl:for-each select="mei:expression/mei:title[@type='alt']">
                    <marc:datafield tag="246" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="." />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>


                <!-- Notes -->
                <xsl:for-each select="mei:expression/mei:notesStmt/mei:annot">
                    <marc:datafield tag="500" ind1=" " ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="./@type" />
                            <xsl:text>:</xsl:text>
                            <xsl:value-of select="." />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <!-- Classification -->
                <xsl:for-each select="mei:expression/mei:classification/mei:termList">
                    <marc:datafield tag="650" ind1="1" ind2="7">
                        <marc:subfield code="a">
                            <xsl:value-of select="./mei:term" />
                        </marc:subfield>
                        <xsl:if test="@class='https://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_kindOfData'">
                            <marc:subfield code="v">
                                <xsl:text>Kind of data</xsl:text>
                            </marc:subfield>
                            <marc:subfield code="2">
                                <xsl:value-of select="./@class"/>
                            </marc:subfield>
                        </xsl:if>
                        <xsl:if test="@class='https://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_usuler'">
                            <marc:subfield code="v">
                                <xsl:text>Usuler</xsl:text>
                            </marc:subfield>
                            <marc:subfield code="2">
                                <xsl:value-of select="./@class"/>
                            </marc:subfield>
                        </xsl:if>
                        <xsl:if test="@class='https://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_musictype'">
                            <marc:subfield code="v">
                                <xsl:text>Music type</xsl:text>
                            </marc:subfield>
                            <marc:subfield code="2">
                                <xsl:value-of select="./@class"/>
                            </marc:subfield>
                        </xsl:if>
                        <xsl:if test="@class='https://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_makamler'">
                            <marc:subfield code="v">
                                <xsl:text>Makamler</xsl:text>
                            </marc:subfield>
                            <marc:subfield code="2">
                                <xsl:value-of select="./@class"/>
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>
                </xsl:for-each>


                <!-- Lyricist -->
                <xsl:if test="mei:expression/mei:lyricist">
                    <marc:datafield tag="700" ind1="1" ind2=" ">
                        <xsl:choose>
                            <xsl:when test="mei:expression/mei:lyricist/mei:persName">
                                <marc:subfield code="a">
                                    <xsl:value-of select="mei:expression/mei:lyricist/mei:persName" />
                                </marc:subfield>
                                <marc:subfield code="e">
                                    <xsl:value-of select="'lyr'" />
                                </marc:subfield>
                                <marc:subfield code="0">
                                    <xsl:value-of select="mei:expression/mei:lyricist/mei:persName/@nymref" />
                                </marc:subfield>
                            </xsl:when>
                            <xsl:when test="mei:expression/mei:lyricist">
                                <marc:subfield code="a">
                                    <xsl:value-of select="mei:expression/mei:lyricist" />
                                </marc:subfield>
                                <marc:subfield code="e">
                                    <xsl:value-of select="'lyr'" />
                                </marc:subfield>
                            </xsl:when>

                        </xsl:choose>
                    </marc:datafield>
                </xsl:if>

                <!-- Relation to Source record -->
                <marc:datafield tag="773" ind1="0" ind2=" ">
                    <xsl:variable name="firstLinkedSource" select="document(concat('cmo_relation:sourcesByLinkToExpression:', $CMO_ID))/objects/object[1]/@id" />
                    <xsl:if test="$firstLinkedSource">
                        <marc:subfield code="w">
                            <xsl:value-of select="$firstLinkedSource" />
                        </marc:subfield>
                    </xsl:if>
                </marc:datafield>


                <!-- Relation List -->
                <xsl:if test="mei:expression/mei:relationList/mei:relation">
                    <marc:datafield tag="787" ind1="0" ind2=" ">
                        <marc:subfield code="i">
                            <xsl:value-of select="mei:expression/mei:relationList/mei:relation/@rel"/>
                        </marc:subfield>
                        <marc:subfield code="n">
                            <xsl:value-of select="mei:expression/mei:relationList/mei:relation/@label"/>
                        </marc:subfield>
                        <marc:subfield code="w">
                            <xsl:value-of select="mei:expression/mei:relationList/mei:relation/@target"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>


                <!-- Holdings -->
                <xsl:for-each select="mei:expression/mei:identifier">
                    <xsl:if test="@type='CMO'">
                        <marc:datafield tag="852" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="substring-before(., ' ')" />
                            </marc:subfield>
                            <marc:subfield code="c">
                                <xsl:value-of select="substring-after(., ' ')" />
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:if>
                    <xsl:if test="@type='RISM'">
                        <marc:datafield tag="852" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="substring-before(., ' ')" />
                            </marc:subfield>
                            <marc:subfield code="c">
                                <xsl:value-of select="substring-after(., ' ')" />
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:if>

                </xsl:for-each>

                <!-- ISIL -->
                <marc:datafield tag="910" ind1="2" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="'Corpus Musicae Ottomanicae'" />
                    </marc:subfield>
                    <marc:subfield code="1">
                        <xsl:value-of
                                select="'https://sigel.staatsbibliothek-berlin.de/suche/?isil=DE-4353'" />
                    </marc:subfield>
                </marc:datafield>

            </marc:record>
        </xsl:for-each>
    </xsl:template>



</xsl:stylesheet>