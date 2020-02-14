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
    <xsl:if test="mei:classification[mei:termList[contains(@class,'cmo_makamler')]]">
      <xsl:call-template name="printParentClassLabel">
        <xsl:with-param name="classId" select="'cmo_makamler'" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="mei:classification[mei:termList[contains(@class,'cmo_musictype')]]">
      <xsl:call-template name="printClassLabel">
        <xsl:with-param name="classId" select="'cmo_musictype'" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <!-- alternative title for hit list (expression): <Makam> <Music Genre> <Usul> 
       used only, if no title available -->
  <xsl:template name="printStandardizedHitListTitle">
    <xsl:comment>mei-utils.xsl > printStandardizedHitListTitle </xsl:comment>
    <xsl:if test="mei:classification[mei:termList[contains(@class,'cmo_makamler')]]">
      <xsl:call-template name="printParentClassLabel">
        <xsl:with-param name="classId" select="'cmo_makamler'" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="mei:classification[mei:termList[contains(@class,'cmo_musictype')]]">
      <xsl:call-template name="printClassLabel">
        <xsl:with-param name="classId" select="'cmo_musictype'" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  
  <!-- prints first category label found for given classification ID -->
  <xsl:template name="printClassLabel">
    <xsl:param name="classId" />
    <xsl:variable name="termList" select="mei:classification/mei:termList[contains(@class, $classId)]" />
    <xsl:if test="count($termList/mei:term)&gt;0">
      <xsl:value-of select="classification:getClassLabel($termList/@class, $termList/mei:term[1]/text())" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="printParentClassLabel">
    <xsl:param name="classId" />
    <xsl:variable name="termList" select="mei:classification/mei:termList[contains(@class, $classId)]" />
    <xsl:if test="count($termList/mei:term)&gt;0">
      <xsl:value-of select="classification:getParentClassLabel($termList/@class, $termList/mei:term[1]/text())" />
    </xsl:if>
  </xsl:template>


  <xsl:template name="printClassLabel2">
    <xsl:param name="classID" />
    <xsl:param name="categID" />
    <xsl:variable name="classification" select="document(concat('classification:metadata:all:children:',$classID))/mycoreclass/categories" />

    <xsl:choose>
      <xsl:when test="$classification//category[@ID=$categID]/label[@xml:lang=$CurrentLang]">
        <xsl:value-of select="$classification//category[@ID=$categID]/label[@xml:lang=$CurrentLang]/@text" />
      </xsl:when>
      <xsl:when test="$classification//category[@ID=$categID]/label[@xml:lang=$DefaultLang]">
        <xsl:value-of select="$classification//category[@ID=$categID]/label[@xml:lang=$CurrentLang]/@text" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$classification//category[@ID=$categID]/label[1]/@text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
