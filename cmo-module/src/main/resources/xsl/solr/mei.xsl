<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:meiDate="xalan://org.mycore.mei.MCRMEIDateHelper"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods mei xlink">
  <xsl:import href="xslImport:solr-document:solr/mei.xsl" />

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

  </xsl:template>

  <xsl:template match="*|@*" mode="solrIndex">
    <xsl:comment>Process:
      <xsl:value-of select="name()" />
    </xsl:comment>
    <xsl:apply-templates mode="solrIndex" />
  </xsl:template>

  <xsl:template match="mei:titleStmt/mei:title" mode="solrIndex">
    <field name="title">
      <xsl:value-of select="text()" />
    </field>
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

  <xsl:template match="mei:titleStmt/mei:composer/mei:persName" mode="solrIndex">
    <field name="composer">
      <xsl:value-of select="." />
    </field>

    <xsl:if test="@nymref">
      <field name="composer.ref">
        <xsl:value-of select="concat(.,'|',@nymref)" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:titleStmt/mei:lyricist" mode="solrIndex">
    <field name="lyricist">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="mei:titleStmt/mei:author" mode="solrIndex">
    <field name="author">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mei:titleStmt/mei:author/mei:persName" mode="solrIndex">
    <field name="author.ref">
      <xsl:value-of select="concat(.,'|', @nymref)" />
    </field>
  </xsl:template>

  <xsl:template match="mei:titleStmt/mei:editor" mode="solrIndex">
    <field name="editor">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mei:titleStmt/mei:editor/mei:persName" mode="solrIndex">
    <field name="editor.ref">
      <xsl:value-of select="concat(.,'|', @nymref)" />
    </field>
  </xsl:template>

  <xsl:template match="mei:titleStmt/mei:title" mode="solrIndex">
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

  <xsl:template match="mei:persName/mei:date" mode="solrIndex">
    <xsl:call-template name="date">
      <xsl:with-param name="dateNode" select="." />
      <xsl:with-param name="fieldName" select="concat(@type, '.date')"></xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="date">
    <xsl:param name="dateNode" />
    <xsl:param name="fieldName" />

    <field name="{$fieldName}.range">
      <xsl:value-of select="meiDate:getSolrDateFieldContent($dateNode)" />
    </field>
    <field name="{$fieldName}.content">
      <xsl:value-of select="$dateNode/text()" />
    </field>
  </xsl:template>

</xsl:stylesheet>
