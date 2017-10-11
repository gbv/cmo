<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mcrmei="xalan://org.mycore.mei.classification.MCRMEIClassificationSupport"
                exclude-result-prefixes="mods mei xlink mcrmei">
  <xsl:import href="xslImport:solr-document:solr/searchfields-solr.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />

    <field name="hasFiles">
      <xsl:value-of select="count(structure/derobjects/derobject)&gt;0" />
    </field>

    <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/*/mei:classification/mei:termList/mei:term" />
    <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/*/mei:langUsage/mei:language" />

  </xsl:template>

  <xsl:template match="mei:term">
    <xsl:variable name="uri" select="mcrmei:getClassificationLinkFromTerm(.)" />
    <xsl:call-template name="indexClass">
      <xsl:with-param name="uri" select="$uri" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:*[@authority and @xml:id]">
    <xsl:variable name="uri" select="mcrmei:getClassificationLinkFromTerm(.)" />
    <xsl:call-template name="indexClass">
      <xsl:with-param name="uri" select="$uri" />
    </xsl:call-template>

    <xsl:if test="name()='mei:langUsage'">
      <field name="langugage.{@authority}"><xsl:value-of select="@xml:id" /></field>
    </xsl:if>
  </xsl:template>

  <xsl:template name="indexClass">
    <xsl:param name="uri" />
    <xsl:if
      test="string-length($uri) &gt; 0 and string-length(substring-after(substring-after($uri,'parents:'),':')) &gt; 0">
      <xsl:variable name="topField" select="true()" /> <!-- TODO: not(ancestor::mods:relatedItem) -->
      <xsl:variable name="classdoc" select="document($uri)" />
      <xsl:variable name="classid" select="$classdoc/mycoreclass/@ID" />
      <xsl:apply-templates select="$classdoc//category" mode="category">
        <xsl:with-param name="classid" select="$classid" />
        <xsl:with-param name="withTopField" select="$topField" />
      </xsl:apply-templates>

      <xsl:variable name="classes"
                    select="mcrmei:getIndexClassification()" />
      <xsl:if test="count($classes[@id=$classid])&gt;0">
        <field name="{$classid}">
          <xsl:value-of select="$classdoc//category/@ID" />
        </field>
      </xsl:if>
    </xsl:if>
  </xsl:template>



</xsl:stylesheet>
