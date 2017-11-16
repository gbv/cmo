<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:classification="xalan://org.mycore.mei.classification.MCRMEIClassificationSupport"
  exclude-result-prefixes="xalan xlink i18n mei classification" version="1.0">


  <!-- standardized term (expression): <Makam> <Music Genre> -->
  <xsl:template name="printStandardizedTerm">
    <xsl:comment>mei-utils.xsl > printStandardizedTerm </xsl:comment>
    <xsl:if test="//mei:classification[mei:classCode[contains(@authURI,'cmo_makamler')]]">
      <xsl:call-template name="printClassLabel">
        <xsl:with-param name="classId" select="'cmo_makamler'" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="//mei:classification[mei:classCode[contains(@authURI,'cmo_musictype')]]">
      <xsl:call-template name="printClassLabel">
        <xsl:with-param name="classId" select="'cmo_musictype'" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <!-- alternative title for hit list (expression): <Makam> <Music Genre> <Usul> 
       used only, if no title available -->
  <xsl:template name="printStandardizedHitListTitle">
    <xsl:comment>mei-utils.xsl > printStandardizedHitListTitle </xsl:comment>
    <xsl:if test="//mei:classification[mei:classCode[contains(@authURI,'cmo_makamler')]]">
      <xsl:call-template name="printClassLabel">
        <xsl:with-param name="classId" select="'cmo_makamler'" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="//mei:classification[mei:classCode[contains(@authURI,'cmo_musictype')]]">
      <xsl:call-template name="printClassLabel">
        <xsl:with-param name="classId" select="'cmo_musictype'" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="//mei:classification[mei:classCode[contains(@authURI,'cmo_usuler')]]">
      <xsl:call-template name="printClassLabel">
        <xsl:with-param name="classId" select="'cmo_usuler'" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  
  <!-- prints first category label found for given classification ID -->
  <xsl:template name="printClassLabel">
    <xsl:param name="classId" />
    <xsl:variable name="classCodeId" select="//mei:classification/mei:classCode[contains(@authURI, $classId)]/@xml:id" />
    <xsl:value-of select="classification:getClassLabel(//mei:classification/mei:termList[@classcode=concat('#', $classCodeId)]/mei:term)" />
  </xsl:template>

</xsl:stylesheet>