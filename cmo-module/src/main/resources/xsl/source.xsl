<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_source_')]">
    <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">
        <!--Show metadata -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">
            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>

            <xsl:apply-templates select="structure/parents/parent" mode="metadataView">
              <xsl:with-param name="type" select="'source'" />
            </xsl:apply-templates>

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">
                <xsl:call-template name="displayIdWithOldLink">
                  <xsl:with-param name="id" select="//mei:source/@xml:id" />
                </xsl:call-template>
                <xsl:apply-templates select="//mei:source/mei:identifier[@type='CMO']" mode="metadataView" />
                <xsl:apply-templates select="//mei:physLoc/mei:repository/mei:corpName[@type='library']" mode="metadataView" />
                <xsl:apply-templates select="//mei:physLoc/mei:repository/mei:geogName" mode="metadataView" />
                <xsl:apply-templates select="//mei:physLoc/mei:repository/mei:identifier " mode="metadataView" />
                <xsl:apply-templates select="//mei:source/mei:identifier[@type='RISM']" mode="metadataView" />

                <xsl:apply-templates select="//mei:titleStmt" mode="metadataView" />
                <xsl:apply-templates select="//mei:seriesStmt" mode="metadataView" />
                <xsl:apply-templates select="//mei:pubStmt" mode="metadataView" />

                <xsl:apply-templates select="//mei:physDesc" mode="metadataView" />
                <xsl:apply-templates select="//mei:contents" mode="metadataView" />

                <xsl:apply-templates select="//mei:langUsage" mode="metadataView" />
                <xsl:apply-templates select="//mei:notesStmt" mode="metadataView" />
                <xsl:apply-templates select="//mei:classification" mode="metadataView" />

                <xsl:apply-templates select="structure/children" mode="metadataView" />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_source_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:source/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
