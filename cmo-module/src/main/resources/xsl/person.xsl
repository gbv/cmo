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
                <xsl:apply-templates select="//mei:persName[mei:name]" mode="metadataView" />
                <xsl:apply-templates select="//mei:persName/mei:identifier[not(@type='cmo_intern')]" mode="metadataView" />
                <xsl:if test="//mei:date">
                  <xsl:call-template name="showPersonDates" />
                </xsl:if>
                <xsl:apply-templates select="//mei:persName" mode="printAnnot" />
                <xsl:call-template name="license"/>
                <xsl:call-template name="printCreatorAndUpdater" />
                <!-- composer.ref.pure -->
                <xsl:call-template name="metadataLabelContent">
                  <xsl:with-param name="label" select="'editor.label.composerOf'"/>
                  <xsl:with-param name="content">
                    <xsl:variable name="personID" select="@ID"/>
                    <xsl:variable name="query" select="concat('composer.ref.pure:', $personID)"/>
                    <xsl:variable name="hits" xmlns:encoder="xalan://java.net.URLEncoder"
                                  select="document(concat('solr:q=',encoder:encode($query), '&amp;sort=identifier%20asc', '&amp;rows=1000'))"/>

                    <xsl:element name="button">
                      <xsl:attribute name="class">cmo_addToBasket btn btn-light btn-sm mb-2</xsl:attribute>
                      <xsl:attribute name="data-basket">
                        <xsl:for-each select="$hits/response/result/doc">
                          <xsl:if test="position() > 1">,</xsl:if>
                            <xsl:value-of select="str[@name='id']"/>
                        </xsl:for-each>
                      </xsl:attribute>
                      <xsl:value-of select="'Add all to Basket!'"/>
                    </xsl:element>
                    <ol class="cmo_clear">
                      <xsl:for-each select="$hits/response/result/doc">
                        <xsl:variable name="expressionId" select="str[@name='id']"/>
                      <xsl:for-each select="arr[@name='composer.display.ref']/str[substring(text(), string-length(text()) - string-length($personID) + 1) = $personID]">
                        <li>
                          <xsl:variable name="expressionXML" select="document(concat('mcrobject:', $expressionId))" />

                          <xsl:variable name="title">
                            <xsl:choose>
                              <xsl:when test="$expressionXML/.//mei:title[@type='main']">
                                <xsl:value-of select="$expressionXML/.//mei:title[@type='main']" />
                                <xsl:if test="$expressionXML/.//mei:title[@type='sub']">
                                  <xsl:text> : </xsl:text>
                                  <xsl:value-of select="$expressionXML/.//mei:title[@type='sub']" />
                                </xsl:if>
                              </xsl:when>
                              <xsl:when test="$expressionXML/.//mei:title[@type='uniform']">
                                <xsl:value-of select="$expressionXML/.//mei:title[@type='uniform']" />
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:for-each select="$expressionXML/.//mei:expression">
                                  <xsl:call-template name="printStandardizedTerm" />
                                </xsl:for-each>
                              </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="$expressionXML/.//mei:identifier[@type='CMO']">
                              <xsl:text> (</xsl:text>
                              <xsl:value-of select="$expressionXML/.//mei:identifier[@type='CMO']" />
                              <xsl:text>)</xsl:text>
                            </xsl:if>
                          </xsl:variable>

                          <a href="{concat($WebApplicationBaseURL, 'receive/', $expressionId)}">
                            <xsl:value-of select="$title" />
                          </a>
                        </li>
                      </xsl:for-each>
                      </xsl:for-each>
                    </ol>
                  </xsl:with-param>
                </xsl:call-template>
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
