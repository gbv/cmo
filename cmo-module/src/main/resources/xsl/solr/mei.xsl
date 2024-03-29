<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:meiDate="xalan://org.mycore.mei.MCRDateHelper"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods mei xlink">
  <xsl:import href="xslImport:solr-document:solr/mei.xsl" />

  <xsl:include href="mei-utils.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />

    <xsl:for-each select="metadata/def.meiContainer/meiContainer/mei:work/mei:biblList/mei:bibl">
      <xsl:variable name="biblID" select="@target" />
      <field name="mei.biblList">
        <xsl:value-of select="$biblID" />
      </field>

    </xsl:for-each>

    <xsl:for-each select="metadata/def.meiContainer/meiContainer/mei:work/mei:expressionList/mei:expression">
      <xsl:variable name="expressionID" select="@data" />
      <field name="mei.expressionList">
        <xsl:value-of select="$expressionID" />
      </field>
    </xsl:for-each>

    <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/*" mode="solrIndex" />

    <field name="allMeta"><xsl:value-of select="@ID" /></field>

  </xsl:template>

  <xsl:template match="mei:expression" mode="solrIndex">
    <field name="displayTitle">
      <xsl:choose>
        <xsl:when test="mei:title[@type='main']">
          <xsl:value-of select="mei:title[@type='main']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="printStandardizedHitListTitle" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
    <xsl:apply-templates mode="solrIndex" />
  </xsl:template>

  <xsl:template match="meiContainer/mei:persName" mode="solrIndex">
    <field name="displayTitle">
      <xsl:value-of select="mei:name[@type='CMO']" />
    </field>
    <xsl:apply-templates mode="solrIndex" />

    <xsl:if test="mei:date">
      <xsl:call-template name="birthDate">
        <xsl:with-param name="dateNodes" select="mei:date" />
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="@*|*" mode="solrIndex" />
  </xsl:template>

  <xsl:template match="meiContainer/mei:manifestation" mode="solrIndex">
    <field name="displayTitle">
      <xsl:choose>
        <xsl:when test="mei:titleStmt/mei:title[@type='main']">
          <xsl:value-of select="mei:titleStmt/mei:title[@type='main']" />
        </xsl:when>
        <xsl:when test="mei:identifier[@type='CMO']">
          <xsl:value-of select="mei:identifier[@type='CMO']" />
        </xsl:when>
      </xsl:choose>
    </field>

    <xsl:apply-templates select="@*|*" mode="solrIndex" />
  </xsl:template>

  <xsl:template match="*|@*" mode="solrIndex">
    <xsl:apply-templates mode="solrIndex" />
  </xsl:template>

  <!--
  <xsl:template match="mei:titleStmt/mei:title" mode="solrIndex">
    <xsl:if test="not(ancestor-or-self::mei:componentList)">
      <field name="title">
        <xsl:value-of select="text()" />
      </field>
    </xsl:if>
  </xsl:template>
-->
  <xsl:template match="mei:respStmt" mode="solrIndex">
    <field name="resp">
      <xsl:value-of select="mei:resp" />
    </field>

    <field name="resp.{mei:resp/text()}">
      <xsl:value-of select="mei:corpName" />
    </field>
  </xsl:template>

  <xsl:template match="mei:physDesc/mei:handList/mei:hand" mode="solrIndex">
    <xsl:if test="@resp">
      <xsl:variable name="person" select="document(concat('mcrobject:', @resp))" />
      <xsl:for-each select="$person/.//mei:persName/mei:name">
        <field name="hand.name">
          <xsl:value-of select="text()" />
        </field>
      </xsl:for-each>
      <xsl:for-each select="$person/.//mei:persName/mei:identifier">
        <field name="hand.name">
          <xsl:value-of select="text()" />
        </field>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:physLoc/mei:repository" mode="solrIndex">
    <xsl:for-each select="mei:corpName">
      <field name="repo.corpName">
        <xsl:value-of select="text()" />
      </field>
      <xsl:if test="@type">
        <field name="repo.corpName.{@type}">
          <xsl:value-of select="text()" />
        </field>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="mei:identifier">
      <field name="repo.identifier">
        <xsl:value-of select="text()" />
      </field>
      <xsl:if test="@type">
        <field name="repo.identifier.{@type}">
          <xsl:value-of select="text()" />
        </field>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="mei:geogName">
      <field name="repo.geogName">
        <xsl:for-each select="mei:geogName/mei:geogName">
          <xsl:if test="position()&gt;0">
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="text()" />
        </xsl:for-each>
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:history/mei:eventList" mode="solrIndex">
    <xsl:for-each select="mei:event">
      <xsl:if test="mei:geogName">
        <field name="history.event.eventGeogName">
          <xsl:value-of select="mei:geogName/text()" />
        </field>
        <field name="history.{mei:head/text()}.geogName">
          <xsl:value-of select="mei:geogName/text()" />
        </field>
      </xsl:if>
      <xsl:if test="mei:persName">
        <field name="history.{mei:head/text()}.persName">
          <xsl:value-of select="mei:persName/text()" />
        </field>
      </xsl:if>
      <xsl:if test="mei:date">
        <xsl:call-template name="date">
          <xsl:with-param name="dateNode" select="mei:date" />
          <xsl:with-param name="fieldName" select="concat('history.', mei:head/text(), '.date')" />
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mei:incip" mode="solrIndex">
    <xsl:for-each select="mei:incipText">
      <field name="incip">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mei:incipText[@label]">
      <field name="incip.{@label}">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mei:identifier" mode="solrIndex">
    <field name="identifier">
      <xsl:value-of select="." />
    </field>
    <xsl:if test="@type">
      <field name="identifier.type.{@type}">
        <xsl:value-of select="." />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:composer/mei:persName" mode="solrIndex">
    <field name="composer">
      <xsl:value-of select="." />
    </field>

    <xsl:choose>
      <xsl:when test="@nymref">
        <field name="composer.display.ref">
          <xsl:value-of select="concat(.,'|',@nymref)"/>
        </field>
        <field name="composer.ref">
          <xsl:value-of select="concat(.,'|',@nymref)"/>
        </field>
        <field name="composer.ref.pure">
          <xsl:value-of select="@nymref"/>
        </field>
      </xsl:when>
      <xsl:otherwise>
        <field name="composer.display.ref">
          <xsl:value-of select="text()"/>
        </field>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="mei:lyricist/mei:persName" mode="solrIndex">
    <field name="lyricist">
      <xsl:value-of select="." />
    </field>

    <xsl:if test="@nymref">
      <field name="lyricist.ref">
        <xsl:value-of select="concat(.,'|',@nymref)" />
      </field>
      <field name="lyricist.ref.pure">
        <xsl:value-of select="@nymref" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:author" mode="solrIndex">
    <xsl:if test="not(mei:persName)">
      <field name="author">
        <xsl:value-of select="text()" />
      </field>
    </xsl:if>
    <xsl:if test="not(mei:persName/@nymref)">
      <field name="author.display.ref">
        <xsl:value-of select="text()"/>
      </field>
    </xsl:if>
    <xsl:apply-templates mode="solrIndex"/>
  </xsl:template>

  <xsl:template match="mei:author/mei:persName" mode="solrIndex">
    <field name="author">
      <xsl:value-of select="."/>
    </field>
    <xsl:if test="@nymref">
      <field name="author.ref">
        <xsl:value-of select="concat(.,'|', @nymref)"/>
      </field>
    </xsl:if>
    <field name="author.display.ref">
      <xsl:choose>
        <xsl:when test="@nymref">
          <xsl:value-of select="concat('mcrobject:', @nymref)"/>
          <xsl:copy-of select="document(concat('mcrobject:', @nymref))"/>
          <xsl:variable name="displayName"
                        select="document(concat('mcrobject:', @nymref))/mycoreobject/metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='CMO']"/>
          <xsl:value-of select="concat($displayName,'|',@nymref)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template match="mei:editor" mode="solrIndex">
    <xsl:if test="not(mei:persName)">
      <field name="editor">
        <xsl:value-of select="text()"/>
      </field>
    </xsl:if>
    <xsl:if test="not(mei:persName/@nymref)">
      <field name="editor.display.ref">
        <xsl:value-of select="text()"/>
      </field>
    </xsl:if>
    <xsl:apply-templates mode="solrIndex"/>
  </xsl:template>

  <xsl:template match="mei:editor/mei:persName" mode="solrIndex">
    <field name="editor">
      <xsl:value-of select="."/>
    </field>
    <xsl:if test="@nymref">
      <field name="editor.ref">
        <xsl:value-of select="concat(.,'|', @nymref)"/>
      </field>
      <field name="editor.display.ref">
        <xsl:value-of select="concat('mcrobject:', @nymref)"/>
        <xsl:copy-of select="document(concat('mcrobject:', @nymref))"/>
        <xsl:variable name="displayName"
                      select="document(concat('mcrobject:', @nymref))/mycoreobject/metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='CMO']"/>
        <xsl:value-of select="concat($displayName,'|',@nymref)"/>
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:title" mode="solrIndex">
    <xsl:if test="not(ancestor-or-self::mei:componentList)">
      <xsl:comment>mei.xsl -> mei:title</xsl:comment>
      <xsl:if test="@type">
        <field name="title.type.{@type}">
          <xsl:value-of select="." />
        </field>
      </xsl:if>
      <xsl:if test="@xml:lang">
        <field name="title.lang.{@xml:lang}">
          <xsl:value-of select="." />
        </field>
      </xsl:if>
      <xsl:if test="@xml:lang and @type">
        <field name="title.typelang.{@type}.{@xml:lang}">
          <xsl:value-of select="." />
        </field>
      </xsl:if>
      <field name="title">
        <xsl:value-of select="." />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:pubStmt/mei:publisher" mode="solrIndex">
    <field name="publisher">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mei:pubStmt/mei:pubPlace/mei:geogName" mode="solrIndex">
    <field name="publisher.place">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mei:pubStmt/mei:date" mode="solrIndex">
    <xsl:call-template name="date">
      <xsl:with-param name="dateNode" select="." />
      <xsl:with-param name="fieldName" select="'publish.date'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:creation/mei:date" mode="solrIndex">
    <xsl:call-template name="date">
      <xsl:with-param name="dateNode" select="." />
      <xsl:with-param name="fieldName" select="'creation.date'" />
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="mei:persName/mei:date" mode="solrIndex">

  </xsl:template>

  <xsl:template match="mei:relationList/mei:relation" mode="solrIndex">
    <field name="reference">
      <xsl:value-of select="@target" />
    </field>
  </xsl:template>

  <xsl:template match="mei:persName/mei:name" mode="solrIndex">
    <field name="name">
      <xsl:value-of select="text()" />
    </field>

    <field name="name.general">
      <xsl:value-of select="text()" />
    </field>

    <xsl:if test="@type">
      <field name="name.{@type}">
        <xsl:value-of select="text()" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:seriesStmt/mei:title" mode="solrIndex">
    <field name="series">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mei:seriesStmt/mei:biblScope" mode="solrIndex">
    <field name="biblScope">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template name="date">
    <xsl:param name="dateNode" />
    <xsl:param name="fieldName" />

    <xsl:if
      test="$dateNode/@startdate or $dateNode/@enddate or $dateNode/@notbefore or $dateNode/@notafter or $dateNode/@isodate">
      <field name="{$fieldName}.range">
        <xsl:value-of select="meiDate:getSolrDateFieldContent($dateNode)" />
      </field>
    </xsl:if>
    <field name="{$fieldName}.content">
      <xsl:value-of select="$dateNode/text()" />
    </field>
  </xsl:template>


  <xsl:template name="birthDate">
    <xsl:param name="dateNodes" />

    <field name="date.range">
      <xsl:value-of select="meiDate:getSolrDateFieldContentBirth($dateNodes)" />
    </field>

    <xsl:for-each select="$dateNodes">
      <field name="{@type}.date.content">
        <xsl:choose>
          <xsl:when test="string-length(text()) &gt; 0">
            <xsl:value-of select="text()" />
          </xsl:when>
          <xsl:when test="@startdate and @enddate and @startdate!=@enddate">
            <xsl:value-of select="concat(@startdate, '-', @enddate)" />
          </xsl:when>
          <xsl:when test="@notbefore and @notafter and @notbefore!=@notafter">
            <xsl:value-of select="concat(@notbefore, '-', @notafter)" />
          </xsl:when>
          <xsl:when test="@isodate">
            <xsl:value-of select="@isodate" />
          </xsl:when>
          <xsl:when test="@startdate">
            <xsl:value-of select="@startdate" />
          </xsl:when>
          <xsl:when test="@enddate">
            <xsl:value-of select="@enddate" />
          </xsl:when>
          <xsl:when test="@notbefore">
            <xsl:value-of select="@notbefore" />
          </xsl:when>
          <xsl:when test="@notafter">
            <xsl:value-of select="@notafter" />
          </xsl:when>
        </xsl:choose>

      </field>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
