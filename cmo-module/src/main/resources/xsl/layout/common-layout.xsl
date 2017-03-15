<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:layoutUtils="xalan:///org.mycore.frontend.MCRLayoutUtilities" xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="layoutUtils xlink basket actionmapping mcr mcrver mcrxsl i18n exslt">
  <xsl:strip-space elements="*" />
  <xsl:param name="CurrentLang" select="'en'" />
  <xsl:param name="CurrentUser" />
  <xsl:param name="numPerPage" />
  <xsl:param name="previousObject" />
  <xsl:param name="previousObjectHost" />
  <xsl:param name="nextObject" />
  <xsl:param name="nextObjectHost" />
  <xsl:param name="resultListEditorID" />
  <xsl:param name="page" />
  <xsl:param name="breadCrumb" />
  <xsl:param name="MCR.NameOfProject" />
  <xsl:param name="MCR.Metadata.Languages" select="'en'" />
  <xsl:include href="layout-utils.xsl" />
  <xsl:variable name="loaded_navigation_xml" select="layoutUtils:getPersonalNavigation()/navigation" />
  <xsl:variable name="browserAddress">
    <xsl:call-template name="getBrowserAddress" />
  </xsl:variable>
  <xsl:variable name="whiteList">
    <xsl:call-template name="get.whiteList" />
  </xsl:variable>
  <xsl:variable name="readAccess">
    <xsl:choose>
      <xsl:when test="starts-with($RequestURL, $whiteList)">
        <xsl:value-of select="'true'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="layoutUtils:readAccess($browserAddress)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ========== create login menu for current user ================================ -->

  <xsl:template name="loginMenu">
    <xsl:variable xmlns:encoder="xalan://java.net.URLEncoder" name="loginURL"
      select="concat( $ServletsBaseURL, 'MCRLoginServlet',$HttpSession,'?url=', encoder:encode( string( $RequestURL ) ) )" />
    <xsl:choose>
      <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
        <li>
          <a id="loginURL" href="{$loginURL}">
            <xsl:value-of select="i18n:translate('component.userlogin.button.login')" />
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="dropdown">
          <xsl:if test="$loaded_navigation_xml/menu[@id='user']//item[@href = $browserAddress ]">
            <xsl:attribute name="class">
              <xsl:value-of select="'active'" />
            </xsl:attribute>
          </xsl:if>
          <a id="currentUser" class="dropdown-toggle" data-toggle="dropdown" href="#">
            <strong>
              <xsl:value-of select="$CurrentUser" />
            </strong>
            <span class="caret" />
          </a>
          <ul class="dropdown-menu dropdown-menu-right" role="menu" aria-labelledby="dLabel">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='user']/*" />
          </ul>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ========== Check if given document has <site /> root tag ======================== -->
  <xsl:template match="/*[not(local-name()='site')]">
    <xsl:message terminate="yes">This is not a site document, fix your properties.</xsl:message>
  </xsl:template>


  <!-- ========== Check if current user has read access and show content if true ======= -->
  <xsl:template name="write.content">
    <xsl:call-template name="print.writeProtectionMessage" />
    <xsl:choose>
      <xsl:when test="$readAccess='true'">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="printNotLoggedIn" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ========== Create navigation for current user =================================== -->

  <xsl:template match="/navigation//label">
  </xsl:template>
  <xsl:template match="/navigation//menu[@id and (group[item] or item)]">
    <xsl:param name="active" select="descendant-or-self::item[@href = $browserAddress ]" />
    <xsl:variable name="menuId" select="generate-id(.)" />
    <li class="dropdown">
      <xsl:if test="$active">
        <xsl:attribute name="class">
          <xsl:value-of select="'active'" />
        </xsl:attribute>
      </xsl:if>
      <a id="{$menuId}" class="dropdown-toggle" data-toggle="dropdown" href="#">
        <xsl:apply-templates select="." mode="linkText" />
        <span class="caret"></span>
      </a>
      <ul class="dropdown-menu" role="menu" aria-labelledby="{$menuId}">
        <xsl:apply-templates select="item|group" />
      </ul>
    </li>
  </xsl:template>
  <xsl:template match="/navigation//group[@id and item]">
    <xsl:param name="rootNode" select="." />
    <xsl:if test="name(preceding-sibling::*[1])='item'">
      <li role="presentation" class="divider" />
    </xsl:if>
    <xsl:if test="label">
      <li role="presentation" class="dropdown-header">
        <xsl:apply-templates select="." mode="linkText" />
      </li>
    </xsl:if>
    <xsl:apply-templates />
    <li role="presentation" class="divider" />
  </xsl:template>

  <xsl:template match="/navigation//item[@href]">
    <xsl:param name="active" select="descendant-or-self::item[@href = $browserAddress ]" />
    <xsl:param name="url">
      <xsl:choose>
        <!-- item @type is "intern" -> add the web application path before the link -->
        <xsl:when test=" starts-with(@href,'http:') or starts-with(@href,'https:') or starts-with(@href,'mailto:') or starts-with(@href,'ftp:')">
          <xsl:value-of select="@href" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="UrlAddSession">
            <xsl:with-param name="url" select="concat($WebApplicationBaseURL,substring-after(@href,'/'))" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($url ) &gt; 0">
        <li>
          <xsl:if test="$active">
            <xsl:attribute name="class">
              <xsl:value-of select="'active'" />
            </xsl:attribute>
          </xsl:if>
          <a href="{$url}">
            <xsl:apply-templates select="." mode="linkText" />
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>
          <xsl:apply-templates select="." mode="linkText" />
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/navigation//*[label]" mode="linkText">
    <xsl:choose>
      <xsl:when test="label[lang($CurrentLang)] != ''">
        <xsl:value-of select="label[lang($CurrentLang)]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="label[lang($DefaultLang)]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="languageMenu">
    <li class="dropdown">
      <a data-toggle="dropdown" title="{i18n:translate('language.change')}">
        <xsl:value-of select="i18n:translate(concat('language.change.', $CurrentLang))" />
        <span class="caret" />
      </a>
      <ul class="dropdown-menu language-menu" role="menu">
        <xsl:variable name="availableLanguages">
          <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
            <xsl:with-param name="string" select="$MCR.Metadata.Languages" />
            <xsl:with-param name="delimiter" select="','" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="exslt:node-set($availableLanguages)/token">
          <xsl:variable name="lang"><xsl:value-of select="mcrxsl:trim(.)" /></xsl:variable>
          <xsl:if test="$lang!='' and $CurrentLang!=$lang">
            <li>
              <xsl:variable name="langURL">
                <xsl:call-template name="languageLink">
                  <xsl:with-param name="lang" select="$lang" />
                </xsl:call-template>
              </xsl:variable>
              <a href="{$langURL}" title="{i18n:translate(concat('language.', $lang))}">
                <xsl:value-of select="i18n:translate(concat('language.change.', $lang))" />
              </a>
            </li>
          </xsl:if>
        </xsl:for-each>
      </ul>
    </li>
  </xsl:template>
  <xsl:template name="languageLink">
    <xsl:param name="lang" />
    <xsl:variable name="langURL">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'lang'" />
        <xsl:with-param name="value" select="$lang" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="UrlAddSession">
      <xsl:with-param name="url" select="$langURL" />
    </xsl:call-template>
  </xsl:template>


</xsl:stylesheet>
