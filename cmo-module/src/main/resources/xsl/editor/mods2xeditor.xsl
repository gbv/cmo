<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mirmapper="xalan://org.mycore.mir.impexp.MIRClassificationMapper" xmlns:mirdateconverter="xalan://org.mycore.mir.date.MIRDateConverter"
  xmlns:mirvalidationhelper="xalan://org.mycore.mir.validation.MIRValidationHelper"
  exclude-result-prefixes="mcrmods xlink mirmapper i18n mirdateconverter mirvalidationhelper" version="1.0"
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
  
</xsl:stylesheet>