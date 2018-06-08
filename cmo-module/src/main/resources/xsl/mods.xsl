<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="xalan xlink acl i18n mods" version="1.0">
  
  <xsl:include href="mods-utils.xsl" />

  <xsl:key use="@id" name="rights" match="/mycoreobject/rights/right" />
  <xsl:key use="mods:role/mods:roleTerm" name="name-by-role" match="mods:mods/mods:name" />

  <xsl:template match="/mycoreobject[contains(@ID,'_mods_')]">
  <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">

        <xsl:apply-templates select="response" />

        <h1>
          <xsl:apply-templates select="//mods:mods" mode="mods.title">
            <xsl:with-param name="asHTML" select="true()" />
            <xsl:with-param name="withSubtitle" select="true()" />
          </xsl:apply-templates>
        </h1>

        <!--Show metadata -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">
            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">
                <xsl:apply-templates select="//mods:mods/mods:identifier[@type='CMO']" mode="metadataView" />
                <xsl:apply-templates select="//mods:mods/mods:relatedItem[@type='host']" mode="metadataView" />
                <xsl:apply-templates select="//mods:mods" mode="metadataViewName" />
                <xsl:apply-templates select="//mods:mods/mods:genre" mode="metadataView" />
                <xsl:apply-templates select="//mods:mods/mods:classification[@displayLabel='cmo_editionTypes']" mode="metadataView" />
                <xsl:apply-templates select="//mods:originInfo[@eventType='publication']/mods:publisher" mode="metadataView" />
                <xsl:if test="//mods:originInfo[@eventType='publication']/mods:dateIssued">
                  <xsl:call-template name="printDateIssued" />
                </xsl:if>
                <xsl:apply-templates select="//mods:originInfo[@eventType='publication']/mods:place/mods:placeTerm" mode="metadataView" />
                <xsl:apply-templates select="//mods:mods/mods:physicalDescription/mods:extent" mode="metadataView" />
                <xsl:apply-templates select="//mods:mods/mods:relatedItem[@type='series']" mode="metadataView" />
                <xsl:apply-templates select="//mods:mods/mods:note" mode="metadataView" />
                <xsl:apply-templates select="//mods:mods/mods:relatedItem[@type='original']" mode="metadataView" />
                <xsl:apply-templates select="structure/children" mode="metadataView" />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:apply-templates select="structure" mode="showViewer" />
        <xsl:call-template name="displayUploadBox" />
        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
