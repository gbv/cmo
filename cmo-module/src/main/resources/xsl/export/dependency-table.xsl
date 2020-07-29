<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:export="http://www.corpus-musicae-ottomanicae.de/ns/export"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:table="http://www.corpus-musicae-ottomanicae.de/ns/table"
                xmlns:i18n="http://www.corpus-musicae-ottomanicae.de/ns/i18n"
                version="3.0"
>

    <xsl:variable name="i18n" select="document('i18n:editor.label.*,editor.cmo.select.*,cmo.*')"/>
    <xsl:param name="WebApplicationBaseURL"/>
    <xsl:param name="CurrentLang"/>

    <xsl:template match="/export:export">
        <table:tables>
            <!--<debug>
                <xsl:copy-of select="." />
            </debug> -->
            <xsl:call-template name="printEditionTable"/>
            <xsl:call-template name="printExpressionTable"/>
            <xsl:call-template name="printPersonTable"/>
            <xsl:call-template name="printManifestationTable"/>
            <xsl:call-template name="printWorkTable"/>
            <xsl:call-template name="printModsSourceTable"/>
        </table:tables>
    </xsl:template>

    <xsl:template name="printEditionTable">
        <table:table id="edition-mods">
            <table:h1>
                <xsl:value-of select="$i18n/i18n/translation[@key='editor.cmo.select.edition-mods']"/>
            </table:h1>
            <table:thead>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.identifier']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.title']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.pubPlace']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.publishingDate']"/>
                </table:th>
            </table:thead>
            <table:tbody>
                <xsl:for-each
                        select="export:dependency/mods:mods[count(mods:classification[contains(@valueURI, 'cmo_kindOfData#edition')])&gt;0]">
                    <table:tr>
                        <table:td>
                            <xsl:value-of select="mods:identifier[@type='CMO']/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:choose>
                                <xsl:when test="mods:titleInfo/mods:title and mods:titleInfo/mods:subTitle">
                                    <xsl:value-of
                                            select="concat(mods:titleInfo/mods:title, ' : ', mods:titleInfo/mods:subTitle)"/>
                                </xsl:when>
                                <xsl:when test="mods:titleInfo/mods:title">
                                    <xsl:value-of select="mods:titleInfo/mods:title"/>
                                </xsl:when>
                            </xsl:choose>
                        </table:td>
                        <table:td>
                            <xsl:for-each
                                    select=".//mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[not(@type='code')]">
                                <xsl:value-of select="."/>
                            </xsl:for-each>
                        </table:td>
                        <table:td>
                            <xsl:for-each
                                    select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
                                <xsl:sort data-type="number"
                                          select="count(ancestor::mods:originInfo[not(@eventType) or @eventType='publication'])"/>
                                <xsl:if test="position()=1">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </table:td>
                    </table:tr>
                </xsl:for-each>
            </table:tbody>
        </table:table>
    </xsl:template>

    <xsl:template name="printExpressionTable">
        <table:table id="expression">
            <table:h1>
                <xsl:value-of select="$i18n/i18n/translation[@key='editor.cmo.select.expression']"/>
            </table:h1>
            <table:thead>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.identifier']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.title']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.composer']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='cmo.genre']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='cmo.makam']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='cmo.usul']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.incip']"/>
                </table:th>
            </table:thead>

            <table:tbody>
                <xsl:for-each
                        select="export:dependency/mei:expression">
                    <table:tr>
                        <table:td>
                            <xsl:value-of select="mei:identifier[@type='CMO']/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:choose>
                                <xsl:when test="mei:title[@type='main']">
                                    <xsl:value-of select="mei:title[@type='main']"/>
                                </xsl:when>
                                <xsl:when test="mei:title[@type='uniform']">
                                    <xsl:value-of select="mei:title[@type='uniform']"/>
                                </xsl:when>
                            </xsl:choose>
                        </table:td>
                        <table:td>
                            <xsl:for-each select="mei:composer/mei:persName">
                                <xsl:if test="position()>1">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                                <xsl:call-template name="displayPerson"/>
                            </xsl:for-each>
                        </table:td>
                        <table:td>
                            <xsl:call-template name="printTermList">
                                <xsl:with-param name="tl"
                                                select="mei:classification/mei:termList[contains(@class, 'cmo_musictype')]"/>
                            </xsl:call-template>
                        </table:td>
                        <table:td>
                            <xsl:call-template name="printTermList">
                                <xsl:with-param name="tl"
                                                select="mei:classification/mei:termList[contains(@class, 'cmo_makamler')]"/>
                            </xsl:call-template>
                        </table:td>
                        <table:td>
                            <xsl:call-template name="printTermList">
                                <xsl:with-param name="tl"
                                                select="mei:classification/mei:termList[contains(@class, 'cmo_usuler')]"/>
                            </xsl:call-template>
                        </table:td>
                        <table:td>
                            <xsl:for-each select="mei:incip/mei:incipText">
                                <xsl:if test="position()&gt;1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="mei:p/text()" />
                            </xsl:for-each>
                        </table:td>
                    </table:tr>
                </xsl:for-each>
            </table:tbody>
        </table:table>
    </xsl:template>

    <xsl:template name="printPersonTable">
        <table:table id="person">
            <table:h1>
                <xsl:value-of select="$i18n/i18n/translation[@key='editor.cmo.select.person']"/>
            </table:h1>
            <table:thead>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.name']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.lifeData.birth']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.lifeData.death']"/>
                </table:th>
            </table:thead>
            <table:tbody>
                <xsl:for-each select="export:dependency/mei:persName">
                    <table:tr>
                        <table:td>
                            <xsl:for-each select="mei:name">
                                <xsl:if test="position()&gt;1">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="text()"/>
                            </xsl:for-each>
                        </table:td>
                        <table:td>
                            <xsl:for-each select="mei:date[@type='birth']">
                                <xsl:if test="position()&gt;1">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="text()"/>
                            </xsl:for-each>
                        </table:td>
                        <table:td>
                            <xsl:for-each select="mei:date[@type='death']">
                                <xsl:if test="position()&gt;1">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="text()"/>
                            </xsl:for-each>
                        </table:td>
                    </table:tr>
                </xsl:for-each>
            </table:tbody>

        </table:table>
    </xsl:template>

    <xsl:template name="printManifestationTable">
        <table:table id="source">
            <table:h1>
                <xsl:value-of select="$i18n/i18n/translation[@key='editor.cmo.select.source']"/>
            </table:h1>
            <table:thead>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.identifier']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.identifier.shelfmark']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.corpName']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.title']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.publisher']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.creation.date']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.editorAndAuthor']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.pubPlace']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.publishingDate']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.series']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='cmo.sourceType']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='cmo.contentType']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='cmo.notationType']"/>
                </table:th>
            </table:thead>
            <table:tbody>
                <xsl:for-each select="export:dependency/mei:manifestation">
                    <table:tr>
                        <table:td>
                            <xsl:value-of select="mei:identifier[@type='CMO']/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:value-of select="mei:physLoc/mei:repository/mei:identifier[@type='shelfmark']/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:value-of select="mei:physLoc/mei:repository/mei:corpName[@type='library']/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:choose>
                                <xsl:when test="mei:titleStmt/mei:title[@type='main']">
                                    <xsl:value-of select="mei:titleStmt/mei:title[@type='main']/text()"/>
                                </xsl:when>
                                <xsl:when test="mei:identifier[@type='CMO']">
                                    <xsl:value-of select="mei:identifier[@type='CMO']/text()"/>
                                </xsl:when>
                            </xsl:choose>
                        </table:td>
                        <table:td>
                            <xsl:value-of select="mei:pubStmt/mei:publisher/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:value-of select="mei:creation/mei:date/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:for-each
                                    select="mei:titleStmt/mei:author/mei:persName|mei:titleStmt/mei:editor/mei:persName">
                                <xsl:if test="position()>1">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                                <xsl:call-template name="displayPerson"/>
                            </xsl:for-each>
                        </table:td>
                        <table:td>
                            <xsl:value-of select="mei:pubStmt/mei:pubPlace/mei:geogName/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:value-of select="mei:pubStmt/mei:date/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:value-of select="mei:seriesStmt/mei:title[@type='main']"/>
                            <xsl:if test="mei:seriesStmt/mei:biblScope">
                                <xsl:value-of select="mei:seriesStmt/mei:biblScope"/>
                                <xsl:value-of select="mei:seriesStmt/mei:biblScope/@unit"/>
                            </xsl:if>
                        </table:td>
                        <table:td>
                            <xsl:call-template name="printTermList">
                                <xsl:with-param name="tl"
                                                select="mei:classification/mei:termList[contains(@class, 'cmo_sourceType')]"/>
                            </xsl:call-template>
                        </table:td>
                        <table:td>
                            <xsl:call-template name="printTermList">
                                <xsl:with-param name="tl"
                                                select="mei:classification/mei:termList[contains(@class, 'cmo_contentType')]"/>
                            </xsl:call-template>
                        </table:td>
                        <table:td>
                            <xsl:call-template name="printTermList">
                                <xsl:with-param name="tl"
                                                select="mei:classification/mei:termList[contains(@class, 'cmo_notationType')]"/>
                            </xsl:call-template>
                        </table:td>
                    </table:tr>
                </xsl:for-each>
            </table:tbody>
        </table:table>
    </xsl:template>

    <xsl:template name="printModsSourceTable">
        <table:table id="source-mods">
            <table:h1>
                <xsl:value-of select="$i18n/i18n/translation[@key='editor.cmo.select.source-mods']"/>
            </table:h1>
            <table:thead>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.identifier']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.title']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.pubPlace']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.publishingDate']"/>
                </table:th>
            </table:thead>
            <table:tbody>
                <xsl:for-each
                        select="export:dependency/mods:mods[count(mods:classification[contains(@valueURI, 'cmo_kindOfData#source')])&gt;0]">
                    <table:tr>
                        <table:td>
                            <xsl:value-of select="mods:identifier[@type='CMO']/text()"/>
                        </table:td>
                        <table:td>
                            <xsl:choose>
                                <xsl:when test="mods:titleInfo/mods:title and mods:titleInfo/mods:subTitle">
                                    <xsl:value-of
                                            select="concat(mods:titleInfo/mods:title, ' : ', mods:titleInfo/mods:subTitle)"/>
                                </xsl:when>
                                <xsl:when test="mods:titleInfo/mods:title">
                                    <xsl:value-of select="mods:titleInfo/mods:title"/>
                                </xsl:when>
                            </xsl:choose>
                        </table:td>
                        <table:td>
                            <xsl:for-each
                                    select=".//mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[not(@type='code')]">
                                <xsl:value-of select="."/>
                            </xsl:for-each>
                        </table:td>
                        <table:td>
                            <xsl:for-each
                                    select=".//mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
                                <xsl:sort data-type="number"
                                          select="count(ancestor::mods:originInfo[not(@eventType) or @eventType='publication'])"/>
                                <xsl:if test="position()=1">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </table:td>
                    </table:tr>
                </xsl:for-each>
            </table:tbody>
        </table:table>
    </xsl:template>

    <xsl:template name="printWorkTable">
        <table:table id="work">
            <table:h1>
                <xsl:value-of select="$i18n/i18n/translation[@key='editor.cmo.select.work']"/>
            </table:h1>
            <table:thead>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='editor.label.identifier']"/>
                </table:th>
                <table:th>
                    <xsl:value-of select="$i18n/i18n/translation[@key='cmo.genre']"/>
                </table:th>
            </table:thead>
            <table:tbody>
                <xsl:for-each select="export:dependency/mei:work">
                    <table:tr>
                        <table:td>
                            <xsl:value-of select="mei:identifier[@type='CMO']"/>
                        </table:td>
                        <table:td>
                            <xsl:call-template name="printTermList">
                                <xsl:with-param name="tl"
                                                select="mei:classification/mei:termList[contains(@class, 'cmo_musictype')]"/>
                            </xsl:call-template>
                        </table:td>
                    </table:tr>
                </xsl:for-each>
            </table:tbody>
        </table:table>
    </xsl:template>

    <xsl:template name="printTermList">
        <xsl:param name="tl"/>
        <xsl:for-each select="$tl/mei:term">
            <xsl:if test="position()&gt;1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:call-template name="printClassification">
                <xsl:with-param name="uri" select="../@class"/>
                <xsl:with-param name="term" select="text()"/>
            </xsl:call-template>
        </xsl:for-each>

    </xsl:template>

    <xsl:template name="displayPerson">
        <xsl:choose>
            <xsl:when test="@nymref">
                <xsl:variable name="personObject" select="document(concat('mcrobject:', @nymref))"/>
                <xsl:variable name="persName" select="$personObject//mei:persName"/>
                <table:a href="{$WebApplicationBaseURL}receive/{@nymref}">
                    <xsl:value-of select="$persName/mei:name[@type='CMO']/text()"/>
                </table:a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="printClassification">
        <xsl:param name="uri"/>
        <xsl:param name="term"/>

        <xsl:variable name="url" select="concat('meiclassification:', $uri, '/', $term)" />
        <xsl:variable name="class"
                      select="document($url)//category[@ID=$term]"/>
        <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="count($class/label[@xml:lang=$CurrentLang])>0">
                    <xsl:value-of select="$class/label[@xml:lang=$CurrentLang]/@text"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$class/label/@text"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$label "/>
    </xsl:template>
</xsl:stylesheet>
