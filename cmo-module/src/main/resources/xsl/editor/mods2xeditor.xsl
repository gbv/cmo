<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:cmo="http://cmo.gbv.de/cmo"
    exclude-result-prefixes="mcrmods xlink i18n cmo"
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

  <xsl:template match="mods:originInfo">
    <xsl:copy>
      <xsl:apply-templates select="*[not(local-name() ='dateIssued')] | @*"/>
      <xsl:choose>
        <xsl:when
            test="mods:dateIssued[@point='start'] or mods:dateIssued[@point='end']">
          <date approx="true">
            <xsl:if test="mods:dateIssued[@qualifier='approximate']">
              <xsl:attribute name="text">
                <xsl:value-of select="mods:dateIssued[@qualifier='approximate']/text()"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="start">
              <xsl:value-of select="mods:dateIssued[@point='start']/text()"/>
            </xsl:attribute>
            <xsl:attribute name="end">
              <xsl:value-of select="mods:dateIssued[@point='end']/text()"/>
            </xsl:attribute>
          </date>
        </xsl:when>
        <xsl:when test="mods:dateIssued[@encoding='w3cdtf']">
          <date approx="false">
            <xsl:attribute name="iso">
              <xsl:value-of select="mods:dateIssued[@encoding='w3cdtf']/text()"/>
            </xsl:attribute>
          </date>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>