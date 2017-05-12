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
  </xsl:template>


</xsl:stylesheet>
