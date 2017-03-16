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

    <xsl:apply-templates select="//meiContainer/*/mei:classification"/>
  </xsl:template>


  <xsl:template match="mei:classification">
    <xsl:for-each select="mei:classCode">
      <xsl:variable name="classid" select="@authority" />
      <xsl:variable name="linkID" select="concat('#', @xml:id)" />
      <xsl:for-each select="../mei:termList[@classcode=$linkID]/mei:term">
        <field name="category">
          <xsl:value-of select="concat($classid, ':', .)" />
        </field>
        <field name="category.top">
          <xsl:value-of select="concat($classid, ':', .)" />
        </field>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>