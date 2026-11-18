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

        <xsl:choose>
          <xsl:when test="metadata/def.meiContainer/meiContainer/*[local-name()='source' or local-name()='manifestation']/mei:identifier[@type='RISM']">
            <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/*[local-name()='source' or local-name()='manifestation']/mei:identifier[@type='RISM']"
                                 mode="metadataHeader" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/*[local-name()='source' or local-name()='manifestation']/mei:identifier[@type='CMO']"
                                 mode="metadataHeader" />
          </xsl:otherwise>
        </xsl:choose>


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
    <xsl:apply-templates select="mei:identifier[@type='RISM']" mode="metadataView" />
    <xsl:apply-templates select="mei:classification" mode="metadataView" />
    <xsl:apply-templates select="mei:physLoc/mei:repository" mode="metadataView" />
    <xsl:apply-templates select="mei:creation/mei:date " mode="metadataView" />
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
  

  <!-- the library, the location and the identifiers of the repository, listed below one label like the description -->
  <xsl:template match="mei:physLoc/mei:repository" mode="metadataView">
    <xsl:comment>source.xsl > mei:repository</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.repository'" />
      <xsl:with-param name="content">
        <dl>
          <xsl:for-each select="mei:corpName[@type='library'][string-length(normalize-space(.)) &gt; 0]">
            <dt><xsl:value-of select="concat(i18n:translate('editor.label.corpName'), ':')" /></dt>
            <dd><xsl:value-of select="." /></dd>
          </xsl:for-each>
          <xsl:for-each select="mei:geogName[mei:geogName[string-length(normalize-space(.)) &gt; 0]]">
            <dt><xsl:value-of select="concat(i18n:translate('editor.label.geogName'), ':')" /></dt>
            <dd>
              <xsl:choose>
                <xsl:when test="mei:geogName[@type='country'] and mei:geogName[@type='city']">
                  <xsl:value-of select="concat(mei:geogName[@type='city'], ', ', mei:geogName[@type='country'])" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="mei:geogName">
                    <xsl:value-of select="." />
                    <xsl:if test="position() != last()">
                      <xsl:text> </xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </dd>
          </xsl:for-each>
          <xsl:for-each select="mei:identifier[string-length(normalize-space(.)) &gt; 0]">
            <dt>
              <xsl:choose>
                <xsl:when test="@type">
                  <xsl:value-of select="concat(i18n:translate(concat('editor.label.identifier.', @type)), ':')" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat(i18n:translate('editor.label.identifier'), ':')" />
                </xsl:otherwise>
              </xsl:choose>
            </dt>
            <dd><xsl:value-of select="." /></dd>
          </xsl:for-each>
        </dl>
      </xsl:with-param>
    </xsl:call-template>
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
  
  <xsl:template priority="1" mode="pageTitle" match="/mycoreobject[contains(@ID,'_source_')]" >
    <xsl:choose>
      <xsl:when test="metadata/def.meiContainer/meiContainer/*[local-name()='source' or local-name()='manifestation']/mei:identifier[@type='RISM']">
        <xsl:value-of select="metadata/def.meiContainer/meiContainer/*[local-name()='source' or local-name()='manifestation']/mei:identifier[@type='RISM']" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="metadata/def.meiContainer/meiContainer/*[local-name()='source' or local-name()='manifestation']/mei:identifier[@type='CMO']" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
