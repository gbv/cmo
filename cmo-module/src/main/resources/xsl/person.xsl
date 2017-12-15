<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:key name="dateByType" match="mei:date" use="@type" />

  <xsl:template match="/mycoreobject[contains(@ID,'_person_')]">
    <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">

        <xsl:apply-templates select="response" />

        <xsl:apply-templates select="//mei:persName/mei:name[@type='CMO']" mode="metadataHeader" />

        <!--Show metadata -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">
            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">
                <xsl:call-template name="displayIdWithOldLink">
                  <xsl:with-param name="id" select="//mei:identifier[@type='cmo_intern']/text()" />
                </xsl:call-template>
                <xsl:apply-templates select="//mei:persName[mei:name]" mode="metadataView" />
                <xsl:apply-templates select="//mei:persName/mei:identifier[not(@type='cmo_intern')]" mode="metadataView" />
                <xsl:call-template name="showPersonDates" />
                <xsl:apply-templates select="//mei:persName/mei:annot" mode="metadataView" />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_person_')]">
    <xsl:choose>
      <xsl:when test="./metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='CMO']">
        <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='CMO']" />
      </xsl:when>
      <xsl:when test="./metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='TMAS-main']">
        <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='TMAS-main']" />
      </xsl:when>
      <xsl:when test="./metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='TMAS-other']">
        <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:persName/mei:name[@type='TMAS-other']" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
