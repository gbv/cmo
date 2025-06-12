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
                <xsl:call-template name="printCreatorAndUpdater" />

                <xsl:call-template name="expressionContainer" />
              </xsl:with-param>
            </xsl:call-template>

          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="expressionContainer">
    <xsl:call-template name="metadataSoloContent">
      <xsl:with-param name="label" select="'editor.label.expressionList'" />
      <xsl:with-param name="content">
        <xsl:call-template name="listExpressions" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="mei:expressionList/mei:expression" mode="buildLink">
    <xsl:if test="not(position()=1)">
      <xsl:value-of select="','" />
    </xsl:if>
    <xsl:value-of select="@codedval" />
  </xsl:template>

  <xsl:template name="listExpressions">
    <xsl:variable name="id" select="/mycoreobject/@ID" />
    <xsl:variable name="canWriteExpression" select="acl:checkPermission($id,'writedb')" />
    <div class="nav">
      <xsl:if test="$canWriteExpression">
        <li class="nav-item">
          <a class="nav-link" href="#action=add-expression2work&amp;work={$id}&amp;q=(category.top%3A%22cmo_kindOfData%3Asource%22%20OR%20cmoType%3Aperson)&amp;fq=cmoType%3Aexpression">
            <xsl:value-of select="i18n:translate('editor.label.expression.list.add')" />
          </a>
        </li>
      </xsl:if>
      <li class="nav-item">
        <xsl:element name="a">
          <xsl:attribute name="class">
            cmo_addToBasket nav-link
          </xsl:attribute>
          <xsl:attribute name="data-basket">
            <xsl:apply-templates select="metadata/def.meiContainer/meiContainer/mei:work/mei:expressionList/mei:expression" mode="buildLink" />
          </xsl:attribute>
          <xsl:value-of select="'Add all to Basket!'" />
        </xsl:element>
      </li>

    </div>

    <ol class="cmo_clear">
      <xsl:for-each select="metadata/def.meiContainer/meiContainer/mei:work/mei:expressionList/mei:expression">
        <li>
          <xsl:variable name="expression" select="document(concat('mcrobject:', @codedval))" />
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
  
          <a href="{concat($WebApplicationBaseURL, 'receive/',@codedval)}">
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
            <xsl:choose>
              <xsl:when test="$pageNumber">
                <xsl:value-of select="$pageNumber" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$expression//mei:expression/mei:identifier[@type='CMO']" />
              </xsl:otherwise>
            </xsl:choose>
          </span>
          <xsl:if test="$expressionElement/mei:composer/mei:persName/@nymref">
            <xsl:text>, </xsl:text>
            <xsl:call-template name="objectLink">
              <xsl:with-param name="obj_id" select="$expressionElement/mei:composer/mei:persName/@nymref" />
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="$canWriteExpression">
            <a data-link-action="remove" data-link-from="{$id}" data-link-to="{@codedval}" href="#" title="{i18n:translate('editor.label.expression.list.remove')}">
              <span class="fa fa-unlink text-danger ml-2"> </span>
            </a>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_work_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:work/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
