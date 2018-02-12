<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_work_')]">

    <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">
        <!--Show metadata -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">
            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>

            <xsl:apply-templates select="response" />

            <xsl:apply-templates select="//mei:identifier" mode="metadataHeader" />

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">

                <xsl:call-template name="displayIdWithOldLink">
                  <xsl:with-param name="id" select="//mei:work/@xml:id" />
                </xsl:call-template>

                <xsl:apply-templates select="//mei:identifier" mode="metadataView" />
                <xsl:apply-templates select="//mei:composer" mode="metadataView" />
                <xsl:apply-templates select="//mei:lyricist" mode="metadataView" />
                <xsl:apply-templates select="//mei:notesStmt" mode="metadataView" />
                <xsl:apply-templates select="//mei:biblList" mode="metadataView" />
                <xsl:apply-templates select="//mei:classification" mode="metadataView" />
              </xsl:with-param>
            </xsl:call-template>

            <ol>
              <xsl:call-template name="listExpressions" />
            </ol>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="listExpressions">
    <xsl:for-each select="metadata/def.meiContainer/meiContainer/mei:work/mei:expressionList/mei:expression">
      <li>
        <xsl:variable name="expression" select="document(concat('mcrobject:', @data))" />
        <xsl:variable name="expressionElement"
                      select="$expression/mycoreobject/metadata/def.meiContainer/meiContainer/mei:expression" />
        <xsl:variable name="pageNumber" select="@n" />


        <xsl:variable name="makam">
          <xsl:call-template name="getClassLabel">
            <xsl:with-param name="class" select="'cmo_makamler'" />
            <xsl:with-param name="meiElement" select="$expressionElement" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="musictype">
          <xsl:call-template name="getClassLabel">
            <xsl:with-param name="class" select="'cmo_musictype'" />
            <xsl:with-param name="meiElement" select="$expressionElement" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="usuler">
          <xsl:call-template name="getClassLabel">
            <xsl:with-param name="class" select="'cmo_usuler'" />
            <xsl:with-param name="meiElement" select="$expressionElement" />
          </xsl:call-template>
        </xsl:variable>

        <a href="{concat($WebApplicationBaseURL, 'receive/',@data)}">
          <xsl:if test="$pageNumber">
            <xsl:value-of select="concat($pageNumber, ', ')" />
          </xsl:if>
          <xsl:if test="string-length($makam)&gt;0">
            <xsl:value-of select="concat($makam,' ')" />
          </xsl:if>
          <xsl:if test="string-length($musictype)&gt;0">
            <xsl:value-of select="concat($musictype,' ')" />
          </xsl:if>
          <xsl:if test="string-length($usuler)&gt;0">
            <xsl:value-of select="concat($usuler,' ')" />
          </xsl:if>
        </a>
        <xsl:if test="$expressionElement/mei:titleStmt/mei:composer/mei:persName/@nymref">
          <a href="{$expressionElement/mei:titleStmt/mei:composer/mei:persName/@nymref}">
            <xsl:value-of select="$expressionElement/mei:titleStmt/mei:composer/mei:persName/text()" />
          </a>
        </xsl:if>
      </li>
    </xsl:for-each>
  </xsl:template>

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_work_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:work/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
