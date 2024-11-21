<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                exclude-result-prefixes="marc mei"
                version="3.0">

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="mycoreobject" mode="source2marc21">
        <xsl:variable name="CMO_ID" select="./@ID"/>
        <xsl:for-each select="metadata/def.meiContainer/meiContainer">
            <marc:record>
                <xsl:if test="mei:manifestation/mei:classification/mei:termList/mei:term='Manuscript'">
                    <marc:leader>00000ndc a2200000 u 4500</marc:leader>
                </xsl:if>
                <xsl:if test="mei:manifestation/mei:classification/mei:termList/mei:term='Printed_source'">
                    <marc:leader>00000ncc a2200000 u 4500</marc:leader>
                </xsl:if>
                <marc:controlfield tag="001">
                    <xsl:value-of select="$CMO_ID"/>
                </marc:controlfield>

                <!-- ID -->

                <marc:datafield tag="035" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="mei:manifestation/mei:identifier" />
                    </marc:subfield>
                </marc:datafield>


                <!-- Language -->

                <xsl:for-each select="mei:manifestation/mei:langUsage/mei:language">
                    <marc:datafield tag="041" ind1=" " ind2="7">
                        <marc:subfield code="a">
                            <xsl:value-of select="./@xml:id" />
                        </marc:subfield>
                        <marc:subfield code="2">
                            <xsl:value-of select="./@auth" />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <!-- Author -->

                <xsl:if test="mei:manifestation/mei:titleStmt/mei:author">
                    <marc:datafield tag="100" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:author/mei:persName" />
                        </marc:subfield>
                        <xsl:if test="mei:manifestation/mei:titleStmt/mei:author/mei:persName/@nymref">
                            <marc:subfield code="0">
                                <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:author/mei:persName/@nymref" />
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>
                </xsl:if>


                <!-- Title -->
                <xsl:if test="mei:manifestation/mei:titleStmt/mei:title[@type='main']">
                    <marc:datafield tag="240" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:title[@type='main']" />
                        </marc:subfield>
                        <xsl:if test="mei:manifestation/mei:titleStmt/mei:title[@type='desc']">
                            <marc:subfield code="b">
                                <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:title[@type='desc']" />
                            </marc:subfield>
                        </xsl:if>
                        <xsl:for-each select="mei:manifestation/mei:titleStmt/mei:title[@type='main'][@xml:lang]">
                            <marc:subfield code="y">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:for-each>
                    </marc:datafield>
                </xsl:if>


                <xsl:if test="mei:manifestation/mei:titleStmt/mei:title[@type='index']">
                    <marc:datafield tag="242" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:title[@type='index']" />
                        </marc:subfield>
                        <xsl:for-each select="mei:manifestation/mei:titleStmt/mei:title[@type='index'][@xml:lang]">
                            <marc:subfield code="y">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:for-each>

                    </marc:datafield>
                </xsl:if>


                <xsl:if test="mei:manifestation/mei:titleStmt/mei:title[@type='orig_index']">
                    <marc:datafield tag="242" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:title[@type='orig_index']" />
                        </marc:subfield>
                        <xsl:for-each select="mei:manifestation/mei:titleStmt/mei:title[@type='orig_index'][@xml:lang]">
                            <marc:subfield code="y">
                                <xsl:value-of select="./@xml:lang" />
                            </marc:subfield>
                        </xsl:for-each>

                    </marc:datafield>
                </xsl:if>


                <xsl:if test="mei:manifestation/mei:titleStmt/mei:title[@type='orig']">
                    <marc:datafield tag="245" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:title[@type='orig']" />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>

                <xsl:for-each select="mei:manifestation/mei:titleStmt/mei:title[@type='alt']">
                    <marc:datafield tag="246" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="." />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <xsl:for-each select="mei:manifestation/mei:titleStmt/mei:title[@type='sub']">
                    <marc:datafield tag="246" ind1="1" ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="." />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>


                <!-- Publication Statement -->

                <xsl:if test="mei:manifestation/mei:pubStmt">
                    <marc:datafield tag="260" ind1=" " ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:manifestation/mei:pubStmt/mei:pubPlace/mei:geogName" />
                        </marc:subfield>
                        <xsl:if test="mei:manifestation/mei:pubStmt/mei:publisher">
                            <marc:subfield code="b">
                                <xsl:value-of select="mei:manifestation/mei:pubStmt/mei:publisher" />
                            </marc:subfield>
                        </xsl:if>
                        <xsl:if test="mei:manifestation/mei:pubStmt/mei:date">
                            <marc:subfield code="c">
                                <xsl:value-of select="mei:manifestation/mei:pubStmt/mei:date" />
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>
                </xsl:if>


                <!-- Notes -->

                <xsl:for-each select="mei:manifestation/mei:notesStmt/mei:annot">
                    <marc:datafield tag="500" ind1=" " ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="./@type" />
                            <xsl:text>:</xsl:text>
                            <xsl:value-of select="." />
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <!-- Classification -->

                <xsl:for-each select="mei:manifestation/mei:classification/mei:termList">
                    <marc:datafield tag="650" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="./mei:term"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>


                <!-- Editor -->

                <xsl:if test="mei:manifestation/mei:titleStmt/mei:editor">
                    <marc:datafield tag="700" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:editor/mei:persName" />
                        </marc:subfield>
                        <xsl:if test="mei:manifestation/mei:titleStmt/mei:editor/mei:persName/@nymref">
                            <marc:subfield code="0">
                                <xsl:value-of select="mei:manifestation/mei:titleStmt/mei:editor/mei:persName/@nymref" />
                            </marc:subfield>
                        </xsl:if>
                    </marc:datafield>
                </xsl:if>


                <!-- Relation to Expression records -->

                <xsl:for-each select="mei:manifestation/mei:relationList/mei:relation">
                    <marc:datafield tag="774" ind1="0" ind2=" ">
                        <marc:subfield code="4">
                            <xsl:value-of select="./@rel"/>
                        </marc:subfield>
                        <marc:subfield code="w">
                            <xsl:value-of select="./@target"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>

                <!-- Holdings Information -->

                <xsl:if test="mei:manifestation/mei:physLoc/mei:repository">
                    <marc:datafield tag="852" ind1=" " ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of
                                    select="mei:manifestation/mei:physLoc/mei:repository/mei:geogName/mei:geogName[@type='country']"/>
                        </marc:subfield>
                        <marc:subfield code="b">
                            <xsl:value-of
                                    select="mei:manifestation/mei:physLoc/mei:repository/mei:geogName/mei:geogName[@type='city']"/>
                        </marc:subfield>
                        <marc:subfield code="c">
                            <xsl:value-of
                                    select="mei:manifestation/mei:physLoc/mei:repository/mei:identifier[@type='shelfmark']"/>
                        </marc:subfield>
                        <marc:subfield code="d">
                            <xsl:value-of
                                    select="mei:manifestation/mei:physLoc/mei:repository/mei:identifier[@type='collection']"/>
                        </marc:subfield>
                        <marc:subfield code="e">
                            <xsl:value-of
                                    select="mei:manifestation/mei:physLoc/mei:repository/mei:corpName[@type='library']"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>

                <!-- Holdings -->

                <xsl:for-each select="mei:manifestation/mei:identifier">
                    <xsl:if test="@type='CMO'">
                        <marc:datafield tag="852" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="." />
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
                        <xsl:value-of select="'https://sigel.staatsbibliothek-berlin.de/suche/?isil=DE-4353'" />
                    </marc:subfield>
                </marc:datafield>


            </marc:record>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>