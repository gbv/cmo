<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="mods mei xlink">
  <xsl:import href="xslImport:solr-document:solr/searchfields-solr.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />

    <field name="hasFiles">
      <xsl:value-of select="count(structure/derobjects/derobject)&gt;0" />
    </field>

    <xsl:apply-templates select="//meiContainer/*/mei:classification/mei:termList/mei:term" />
  </xsl:template>

  <xsl:template match="mei:term">
    <xsl:variable name="uri" xmlns:mcrmei="xalan://org.mycore.mei.classification.MCRMEIClassificationSupport" select="mcrmei:getClassificationLinkFromTerm(.)" />
    <xsl:if test="string-length($uri) &gt; 0">
      <xsl:variable name="topField" select="true()" /> <!-- TODO: not(ancestor::mods:relatedItem) -->
      <xsl:variable name="classdoc" select="document($uri)" />
      <xsl:variable name="classid" select="$classdoc/mycoreclass/@ID" />
      <xsl:apply-templates select="$classdoc//category" mode="category">
        <xsl:with-param name="classid" select="$classid" />
        <xsl:with-param name="withTopField" select="$topField" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>