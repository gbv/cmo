<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:classification="xalan://org.mycore.mei.classification.MCRMEIClassificationSupport"
  exclude-result-prefixes="xalan xlink acl i18n mei classification" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_source_')]">
    <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">

        <xsl:apply-templates select="response" />

        <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/*[local-name()='source' or local-name()='manifestation']/mei:identifier[@type='CMO']"
                             mode="metadataHeader" />

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
                <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/mei:source|metadata/def.meiContainer/meiContainer/mei:manifestation" mode="metadataView" />
                <xsl:apply-templates select="structure/children" mode="metadataView" />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="displayUploadBox" />
        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:source|mei:manifestation" mode="metadataView">
    <xsl:apply-templates select="mei:identifier[@type='CMO']" mode="metadataView" />
    <xsl:apply-templates select="mei:classification" mode="metadataView" />
    <xsl:apply-templates select="mei:physLoc/mei:repository/mei:corpName[@type='library']" mode="metadataView" />
    <xsl:apply-templates select="mei:physLoc/mei:repository/mei:geogName" mode="metadataView" />
    <xsl:apply-templates select="mei:physLoc/mei:repository/mei:identifier " mode="metadataView" />
    <xsl:apply-templates select="mei:creation/mei:date " mode="metadataView" />
    <xsl:apply-templates select="mei:identifier[@type='RISM']" mode="metadataView" />
    <xsl:apply-templates select="mei:titleStmt" mode="metadataView" />
    <xsl:apply-templates select="mei:seriesStmt" mode="metadataView" />
    <xsl:apply-templates select="mei:pubStmt" mode="metadataView" />
    <xsl:apply-templates select="mei:physDesc" mode="metadataView" />
    <xsl:apply-templates select="mei:contents" mode="metadataView" />
    <xsl:apply-templates select="mei:history" mode="metadataView" />
    <xsl:apply-templates select="mei:langUsage" mode="metadataView" />
    <xsl:call-template name="printEdition">
      <xsl:with-param name="objectId" select="/mycoreobject/@ID" />
    </xsl:call-template>
    <xsl:apply-templates select="mei:notesStmt" mode="printAnnot" />
    <xsl:call-template name="license"/>
    <xsl:call-template name="printCreatorAndUpdater" />

    <xsl:call-template name="contentContainer" />
  </xsl:template>
  

  <xsl:template name="contentContainer">
    <xsl:if test="mei:componentList|mei:relationList">
      <xsl:call-template name="metadataSoloContent">
        <xsl:with-param name="label" select="'editor.label.contents'" />
        <xsl:with-param name="content">
          <xsl:call-template name="displaySourceComponent" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="displaySourceComponent">
    <xsl:if test="count(ancestor::mei:componentList)&gt;0">
      <xsl:value-of select="mei:identifier/text()" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="mei:titleStmt/mei:title" />
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:call-template name="displayBasketOptions"/>
    <ol class="cmo_clear">
      <xsl:for-each select="mei:componentList/mei:source|mei:componentList/mei:manifestation">
        <li>
          <xsl:call-template name="displaySourceComponent" />
        </li>
      </xsl:for-each>
      <xsl:call-template name="listRelations" />
    </ol>
  </xsl:template>

  <xsl:template name="displayBasketOptions">
    <xsl:if test="count(mei:relationList/mei:relation)&gt;0">
      <xsl:element name="button">
        <xsl:attribute name="class">cmo_addToBasket btn btn-light btn-sm mb-2</xsl:attribute>
        <xsl:attribute name="data-basket">
          <xsl:apply-templates select="mei:relationList/mei:relation" mode="buildLink"/>
        </xsl:attribute>
        <xsl:value-of select="'Add all to Basket!'"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:relationList/mei:relation" mode="buildLink">
    <xsl:if test="not(position()=1)">
      <xsl:value-of select="','"/>
    </xsl:if>
    <xsl:value-of select=" @target"/>
  </xsl:template>

  <xsl:template name="listRelations">
    <xsl:for-each select="mei:relationList/mei:relation">
      <li>
        <xsl:variable name="expression" select="document(concat('mcrobject:', @target))" />
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

        <a href="{concat($WebApplicationBaseURL, 'receive/',@target)}">
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

  <xsl:template name="getClassLabel">
    <xsl:param name="class" />
    <xsl:param name="meiElement" />

    <xsl:variable name="termList" select="$meiElement/mei:classification/mei:termList[contains(@class, $class)]" />
    <xsl:if test="count($termList/mei:term)&gt;0">
      <xsl:value-of select="classification:getClassLabel($termList/@class, $termList/mei:term[1]/text())" />
    </xsl:if>
  </xsl:template>

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_source_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:manifestation/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
