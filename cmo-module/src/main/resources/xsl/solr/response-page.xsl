<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:str="http://exslt.org/strings" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="i18n mods str mcr acl mcrxsl encoder">

  <!-- retain the original query and parameters, for attaching them to a url -->
  <xsl:variable name="query">
    <xsl:if test="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q'] != '*'">
      <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q']" />
    </xsl:if>
  </xsl:variable>

  <xsl:template match="/response/result|lst[@name='grouped']/lst[@name='returnId']" priority="10">
    <xsl:variable name="ResultPages">
      <xsl:if test="$hits &gt; 0">
        <xsl:call-template name="solr.Pagination">
          <xsl:with-param name="size" select="$rows" />
          <xsl:with-param name="currentpage" select="$currentPage" />
          <xsl:with-param name="totalpage" select="$totalPages" />
          <xsl:with-param name="class" select="'pagination-sm'" />
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <div class="row result_head">
      <div class="col-xs-12 result_headline">
        <h1><small>
          <xsl:choose>
            <xsl:when test="$hits=0">
              <xsl:value-of select="i18n:translate('results.noObject')" />
            </xsl:when>
            <xsl:when test="$hits=1">
              <xsl:value-of select="i18n:translate('results.oneObject')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="i18n:translate('results.nObjects',$hits)" />
            </xsl:otherwise>
          </xsl:choose>
        </small></h1>
      </div>
    </div>

<!-- Pagination & Trefferliste -->
    <div class="row result_body">
      <div class="cols-xs-12 col-sm-8 col-lg-9 result_list">
        <div id="hit_list" class="list-group">
          <xsl:apply-templates select="doc|arr[@name='groups']/lst/str[@name='groupValue']" />
        </div>
        <xsl:copy-of select="$ResultPages" />
      </div>

    </div>
  </xsl:template>

  <xsl:template match="doc" priority="10" mode="resultList">
    <xsl:param name="hitNumberOnPage" select="count(preceding-sibling::*[name()=name(.)])+1" />
    <!--
      Do not read MyCoRe object at this time
    -->
    <xsl:variable name="identifier" select="@id" />
    <xsl:variable name="mcrobj" select="." />
    <xsl:variable name="hitItemClass">
      <xsl:choose>
        <xsl:when test="$hitNumberOnPage mod 2 = 1">odd</xsl:when>
        <xsl:otherwise>even</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- generate browsing url -->
    <xsl:variable name="href" select="concat($proxyBaseURL,$HttpSession,$solrParams)" />
    <xsl:variable name="startPosition" select="$hitNumberOnPage - 1 + (($currentPage) -1) * $rows" />
    <xsl:variable name="hitHref">
      <xsl:value-of select="concat($href, '&amp;start=',$startPosition, '&amp;fl=id&amp;rows=1&amp;origrows=', $rows, '&amp;XSL.Style=browse')" />
    </xsl:variable>

<!-- hit entry -->
    <div class="row list-group-item {$hitItemClass}">
      <div class="col-md-1">
        <xsl:value-of select="$hitNumberOnPage" />
      </div>
      <div class="col-md-9">

        <dl class="dl-horizontal">

<!-- hit title and link to git -->
          <dt>Objekt-Link:</dt>
          <dd>
            <a href="{$hitHref}">
              <!-- show title if searchfield "title" is defined -->
              <xsl:attribute name="title"><xsl:value-of select="./str[@name='title']" /></xsl:attribute>
              <xsl:choose>
                <xsl:when test="./str[@name='search_result_link_text']">
                  <xsl:value-of select="./str[@name='search_result_link_text']" />
                </xsl:when>
                <xsl:when test="./str[@name='fileName']">
                  <xsl:value-of select="./str[@name='fileName']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$identifier" />
                  </xsl:otherwise>
                </xsl:choose>
              </a>
            </dd>

<!-- hit parent -->
          <xsl:if test="./str[@name='parent']">
            <dt>aus:</dt>
            <dd>
             <xsl:choose>
               <xsl:when test="./str[@name='parentLinkText']">
                 <xsl:variable name="linkTo" select="concat($WebApplicationBaseURL, 'receive/',./str[@name='parent'])" />
                 <a href="{$linkTo}">
                   <xsl:value-of select="./str[@name='parentLinkText']" />
                 </a>
               </xsl:when>
               <xsl:otherwise>
                 <xsl:call-template name="objectLink">
                   <xsl:with-param select="./str[@name='parent']" name="obj_id" />
                   </xsl:call-template>
                 </xsl:otherwise>
               </xsl:choose>
             </dd>
            </xsl:if>

<!-- creation date -->
          <dt>Erstellt am:</dt>
          <dd>
            <xsl:value-of select="./date[@name='created']" />
            </dd>

<!-- user who has created this document -->
          <dt>von:</dt>
          <dd>
            <xsl:value-of select="./str[@name='createdby']" />
          </dd>
        </dl>
      </div>

    </div><!-- end hit item -->
  </xsl:template>

</xsl:stylesheet>