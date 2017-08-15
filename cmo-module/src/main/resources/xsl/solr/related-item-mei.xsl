<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods mei xlink">
  <xsl:import href="xslImport:solr-document:solr/related-item-mei.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem">
        <xsl:variable name="href" select="@xlink:href" />
        <xsl:variable name="meiDoc" select="document(concat('mcrobject:', $href))" />
        <xsl:variable name="id" select="$meiDoc/mycoreobject/@ID" />
        <xsl:variable name="type" select="@type" />

        <field name="mods.relatedItem">
          <xsl:value-of select="$id" />
        </field>

        <field name="mods.relatedItem.{$type}">
          <xsl:value-of select="$id" />
        </field>
    </xsl:for-each>

    <xsl:for-each select="structure/parents/parent">
      <xsl:variable name="parent" select="document(concat('mcrobject:',@xlink:href))/mycoreobject" />
      <field name="parentLinkText">
        <xsl:apply-templates select="$parent" mode="resulttitle" />
      </field>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="mycoreobject" mode="resulttitle">
    <xsl:choose>
      <xsl:when test="metadata/def.meiContainer/meiContainer/mei:source/mei:identifier">
        <xsl:value-of select="metadata/def.meiContainer/meiContainer/mei:source/mei:identifier"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@ID" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>
