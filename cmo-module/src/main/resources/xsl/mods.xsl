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
        <!-- TODO: exclude template calls and make complete -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">
            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">
              
                <xsl:call-template name="metadataLabelContent">
                  <xsl:with-param name="label" select="'editor.label.identifier.CMO'" />
                  <xsl:with-param name="content">
                    <xsl:value-of select="//mods:mods/mods:identifier[@type='CMO']" />
                  </xsl:with-param>
                </xsl:call-template>
                
                <xsl:if test="//mods:mods/mods:name[mods:role/mods:roleTerm/text()='trc']">
                  <xsl:call-template name="metadataLabelContent">
                    <xsl:with-param name="label" select="'editor.label.transcriber'" />
                    <xsl:with-param name="content">
                        <xsl:for-each select="//mods:mods/mods:name[mods:role/mods:roleTerm/text()='trc']">
                          <xsl:if test="position()!=1">
                            <xsl:value-of select="'; '" />
                          </xsl:if>
                          <xsl:apply-templates select="." mode="nameLink" />
                          <xsl:if test="mods:etal">
                            <em>et.al.</em>
                          </xsl:if>
                        </xsl:for-each>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:if>
                
                <xsl:call-template name="metadataLabelContent">
                  <xsl:with-param name="label" select="'editor.label.originalLink'" />
                  <xsl:with-param name="content">
                    <xsl:call-template name="objectLink">
                      <xsl:with-param select="//mods:mods/mods:relatedItem[@type='original']/@xlink:href" name="obj_id" />
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
                
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:apply-templates select="structure" mode="showViewer" />


        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
