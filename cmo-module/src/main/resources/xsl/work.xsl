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
    <xsl:variable name="objectId" select="@ID"/>
    <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">
        <xsl:apply-templates select="response" />
        
        <!--Show metadata -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">
            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>

            <xsl:apply-templates select="//mei:identifier" mode="metadataHeader" />

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">
                <xsl:apply-templates select="//mei:identifier" mode="metadataView" />
                <xsl:apply-templates select="//mei:composer" mode="metadataView" />
                <xsl:apply-templates select="//mei:lyricist" mode="metadataView" />
                <xsl:apply-templates select="//mei:biblList" mode="metadataView" />
                <xsl:apply-templates select="//mei:classification" mode="metadataView" />
                <xsl:apply-templates select="//mei:notesStmt" mode="printAnnot" />
                <xsl:call-template name="license"/>

                <xsl:call-template name="expressionContainer" >
                  <xsl:with-param name="objectId" select="$objectId" />
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>

          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="expressionContainer">
    <xsl:param name="objectId"/>

    <xsl:call-template name="metadataSoloContent">
      <xsl:with-param name="label" select="'editor.label.expressionList'" />
      <xsl:with-param name="content">
        <xsl:call-template name="listExpressions">
          <xsl:with-param name="objectId" select="$objectId" />
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="doc" mode="buildLink">
    <xsl:if test="not(position()=1)">
      <xsl:value-of select="','" />
    </xsl:if>
    <xsl:value-of select="str[@name='id']/text()" />
  </xsl:template>

  <xsl:template name="listExpressions">
    <xsl:param name="objectId" />

    <xsl:variable name="query" select="concat('reference:', $objectId)" />
    <xsl:variable name="hits" xmlns:encoder="xalan://java.net.URLEncoder" select="document(concat('solr:q=',encoder:encode($query), '&amp;rows=1000'))" />


    <xsl:element name="a">
      <xsl:attribute name="class">
        cmo_addToBasket
      </xsl:attribute>
      <xsl:attribute name="data-basket">
        <xsl:apply-templates select="$hits/response/result[@name='response']/doc" mode="buildLink" />
      </xsl:attribute>
      <xsl:value-of select="'Add all to Basket!'" />
    </xsl:element>
    <ol class="cmo_clear">
      <xsl:for-each select="$hits/response/result[@name='response']/doc">
        <li>
          <xsl:variable name="expressionId" select="str[@name='id']/text()" />
          <xsl:variable name="expression" select="document(concat('mcrobject:', $expressionId))" />
          <xsl:variable name="expressionElement"
                        select="$expression/mycoreobject/metadata/def.meiContainer/meiContainer/mei:expression" />
          <!-- <xsl:variable name="pageNumber" select="@n" /> i can not find this in the data, there is no expression/@n -->
  
  
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
  
          <a href="{concat($WebApplicationBaseURL, 'receive/', $expressionId)}">
            <xsl:choose>
              <xsl:when test="$expression//mei:expression/mei:title[@type='main']">
                <xsl:value-of select="$expression//mei:expression/mei:title[@type='main']" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="string-length($makam) &gt; 0">
                  <xsl:value-of select="concat($makam,' ')" />
                </xsl:if>
                <xsl:if test="string-length($musictype) &gt; 0">
                  <xsl:value-of select="concat($musictype,' ')" />
                </xsl:if>
                <xsl:if test="string-length($usuler) &gt; 0">
                  <xsl:value-of select="$usuler" />
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </a>
          <span class="standardized">
            <!-- see comment above for pageNumber<xsl:choose>
              <xsl:when test="$pageNumber">
                <xsl:value-of select="$pageNumber" />
              </xsl:when>
              <xsl:otherwise> -->
                <xsl:value-of select="$expression//mei:expression/mei:identifier[@type='CMO']" />
              <!--</xsl:otherwise>
            </xsl:choose> -->
          </span>
          <xsl:if test="$expressionElement/mei:composer/mei:persName/@nymref">
            <xsl:text>, </xsl:text>
            <xsl:call-template name="objectLink">
              <xsl:with-param name="obj_id" select="$expressionElement/mei:composer/mei:persName/@nymref" />
            </xsl:call-template>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_work_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:work/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
