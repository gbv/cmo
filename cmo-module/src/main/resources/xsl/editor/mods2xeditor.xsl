<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="mcrmods xlink i18n"
  version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <!-- put value string (after authority URI) in attribute valueURIxEditor -->
  <xsl:template match="@valueURI">
    <xsl:variable name="classification" select="substring-after(.,'classifications/')" />
    <xsl:attribute name="valueURIxEditor">
      <xsl:value-of select="concat(substring-before($classification,'#'), ':', substring-after($classification,'#'))" />
    </xsl:attribute>
  </xsl:template>
  
  <!-- In editor, all variants of page numbers are edited in a single text field -->
  <xsl:template match="mods:extent[@unit='pages']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <mods:list>
        <xsl:apply-templates select="mods:*" />
      </mods:list>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:start">
    <xsl:value-of select="i18n:translate('cmo.pages.abbreviated.multiple')" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:end">
    <xsl:text> - </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:total[../mods:start]">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="text()" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="i18n:translate('cmo.pages')" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="mods:total">
    <xsl:value-of select="text()" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="i18n:translate('cmo.pages')" />
  </xsl:template>

  <xsl:template match="mods:list">
    <xsl:value-of select="text()" />
  </xsl:template>

</xsl:stylesheet>