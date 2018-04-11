<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:include href="mei-utils.xsl" />

  <xsl:template match="/mycoreobject[contains(@ID,'_expression_')]">
    <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">

        <xsl:apply-templates select="response" />
        
        <h1>
          <xsl:choose>
            <xsl:when test="//mei:titleStmt/mei:title[@type='main']">
              <xsl:value-of select="//mei:titleStmt/mei:title[@type='main']" />
              <xsl:if test="//mei:titleStmt/mei:title[@type='sub']">
                <xsl:text> : </xsl:text>
                <xsl:value-of select="//mei:titleStmt/mei:title[@type='sub']" />
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="printStandardizedTerm" />
            </xsl:otherwise>
          </xsl:choose>
        </h1>

        <!--Show metadata -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">
            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>
            <xsl:apply-templates select="structure/parents/parent" mode="metadataView">
              <xsl:with-param name="type" select="'expression'" />
            </xsl:apply-templates>

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">
                <xsl:call-template name="displayIdWithOldLink">
                  <xsl:with-param name="id" select="//mei:expression/@xml:id" />
                </xsl:call-template>
                <xsl:apply-templates select="//mei:identifier" mode="metadataView" />
                <xsl:apply-templates select="//mei:titleStmt" mode="metadataView" />
                <xsl:apply-templates select="//mei:incip" mode="metadataView" />
                <xsl:apply-templates select="//mei:langUsage" mode="metadataView" />
                <xsl:apply-templates select="//mei:relationList" mode="metadataView" />
                <xsl:apply-templates select="//mei:classification" mode="metadataView" />
                <xsl:apply-templates select="//mei:tempo" mode="metadataView" />
                <xsl:call-template name="sourceLink">
                  <xsl:with-param name="objectId" select="@ID" />
                </xsl:call-template>
                <xsl:call-template name="printEdition">
                  <xsl:with-param name="objectId" select="@ID" />
                </xsl:call-template>
                <xsl:apply-templates select="//mei:notesStmt" mode="printAnnot" />
                <xsl:apply-templates select="structure/children" mode="metadataView" />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!--Template for generated link names and result titles: see mycoreobject.xsl, results.xsl, MyCoReLayout.xsl -->
  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_expression_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:expression/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
