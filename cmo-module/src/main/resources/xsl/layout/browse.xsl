<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:encoder="xalan://java.net.URLEncoder"
  exclude-result-prefixes="xlink mcr i18n xsl">

  <xsl:include href="response-utils.xsl" />


  <xsl:template match="response">
    <xsl:variable name="ResultPages">
      <xsl:if test="($hits &gt; 0)">
        <xsl:call-template name="browse.Pagination">
          <xsl:with-param name="id" select="'solr-browse'" />
          <xsl:with-param name="page" select="$currentPage" />
          <xsl:with-param name="pages" select="$totalPages" />
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="params">
      <xsl:for-each select="lst[@name='responseHeader']/lst[@name='params']/str">
        <xsl:choose>
          <xsl:when test="@name='rows' or @name='XSL.Style' or @name='fl' or @name='start'">
        <!-- skip them -->
          </xsl:when>
          <xsl:when test="@name='origrows' or @name='origXSL.Style' or @name='origfl'">
        <!-- ParameterName=origParameterValue -->
            <xsl:value-of select="concat(substring-after(@name, 'orig'),'=', encoder:encode(., 'UTF-8'))" />
            <xsl:if test="not (position() = last())">
              <xsl:value-of select="'&amp;'" />
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
        <!-- parameterName=parameterValue -->
            <xsl:value-of select="concat(@name,'=', encoder:encode(., 'UTF-8'))" />
            <xsl:if test="not (position() = last())">
              <xsl:value-of select="'&amp;'" />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <div id="search_browsing">
      <div id="search_options">
        <!-- TODO: add functionality to refine search bottons, before display them again -->
        <!-- a href="#" type="button" class="btn btn-default btn-sm">Suche verfeinern</a -->
        <xsl:copy-of select="$ResultPages" />

        <!-- xsl:variable name="origRows" select="lst[@name='responseHeader']/lst[@name='params']/str[@name='origrows']" />
        <xsl:variable name="newStart" select="$start - ($start mod $origRows)" />
        <xsl:variable name="href" select="concat($proxyBaseURL,'?', $HttpSession, $params, '&amp;start=', $newStart)" />

        <a href="{$href}" class="btn btn-default btn-sm" role="button">
          <xsl:value-of select="i18n:translate('component.solr.searchresult.back')" />
        </a -->
      </div>


      <xsl:variable name="objId" select="/mycoreobject/@ID" />
      <xsl:variable name="staticUrl" select="concat($WebApplicationBaseURL, 'receive/', $objId)" />
      <div id="permalink">
        <span class="linklabel">
          <xsl:value-of select="concat(i18n:translate('component.solr.searchresult.objectlink'), ' : ')" />
        </span>
        <span class="linktext">
          <xsl:variable name="linkToDocument">
            <xsl:value-of select="$staticUrl" />
          </xsl:variable>
          <a href="{concat($staticUrl,$HttpSession)}">
            <xsl:value-of select="$staticUrl" />
          </a>
        </span>
      </div>

      <!-- change url in browser -->
      <script type="text/javascript">
        <xsl:value-of select="concat('var pageurl = &quot;', $staticUrl, '&quot;;')" />
        if(typeof window.history.replaceState == &quot;function&quot;){
          var originalPage = {title: document.title, url: document.location.toString()};
          window.history.replaceState({path:pageurl},&quot; <xsl:value-of select="i18n:translate('component.solr.searchresult.resultList')" /> &quot;,pageurl);
          document.getElementById(&quot;permalink&quot;).style.display = &quot;none&quot;;
          window.onbeforeunload = function(){
            window.history.replaceState({path:originalPage.url}, originalPage.title, originalPage.url);
          }
        }
      </script>
    </div>
  </xsl:template>
  
  <xsl:template name="browse.Pagination">
    <xsl:param name="id" select="'pagination'" />
    <xsl:param name="i18nprefix" select="'cmo.pagination.hits'" />
    <xsl:param name="class" select="''" />

    <xsl:param name="href" select="concat($proxyBaseURL,$HttpSession,$solrParams)" />

    <xsl:param name="page" />
    <xsl:param name="pages" />

    <xsl:variable name="label.previousHit" select="i18n:translate(concat($i18nprefix, '.previous'), $page - 1)" />
    <xsl:variable name="label.nextHit" select="i18n:translate(concat($i18nprefix, '.next'), $page + 1)" />

    <div id="{$id}" class="row {$class}">
      <xsl:if test="$page &gt; 1">
        <xsl:variable name="link">
          <xsl:call-template name="paginateLink">
            <xsl:with-param name="href" select="$href" />
            <xsl:with-param name="page" select="$page - 1" />
            <xsl:with-param name="numPerPage" select="1" />
          </xsl:call-template>
        </xsl:variable>
        <div class="col-xs-12 col-md-5 text-left">
          <a tabindex="0" class="previous" href="{$link}" data-pagination=".caption:mods.title.main">
            <span class="fa fa-chevron-left icon" />
            <span class="caption">
              <xsl:value-of select="$label.previousHit" />
            </span>
          </a>
        </div>
      </xsl:if>
      <div class="col-xs-12 col-md-2 text-center">
        <xsl:attribute name="class">
          <xsl:text>col-xs-12 col-md-2 text-center</xsl:text>
          <xsl:if test="$page = 1">
            <xsl:text> col-md-offset-5</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <a title="{i18n:translate(concat($i18nprefix, '.back'))}">
          <xsl:variable name="origRows" select="lst[@name='responseHeader']/lst[@name='params']/str[@name='origrows']" />
          <xsl:variable name="newStart" select="$start - ($start mod $origRows)" />
          <xsl:attribute name="href">
            <xsl:variable name="params">
              <xsl:variable name="tmp">
                <xsl:for-each select="lst[@name='responseHeader']/lst[@name='params']/str">
                  <xsl:if test="not(contains('fl|start|origrows|rows|XSL.Style', @name))">
                    <xsl:value-of select="concat('&amp;', @name, '=', encoder:encode(., 'UTF-8'))" />
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="concat('#', substring-after($tmp, '&amp;'))" />
            </xsl:variable>
            <xsl:value-of select="concat($proxyBaseURL, $HttpSession, $params, '&amp;start=', $newStart)" />
          </xsl:attribute>
          <span class="fa fa-chevron-up" />
        </a>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="i18n:translate(concat($i18nprefix, '.entriesInfo'), concat($page, ';', $pages))" />
      </div>
      <xsl:if test="$page &lt; $pages">
        <xsl:variable name="link">
          <xsl:call-template name="paginateLink">
            <xsl:with-param name="href" select="$href" />
            <xsl:with-param name="page" select="$page + 1" />
            <xsl:with-param name="numPerPage" select="1" />
          </xsl:call-template>
        </xsl:variable>
        <div class="col-xs-12 col-md-5 text-right">
          <a tabindex="0" class="next" href="{$link}" data-pagination=".caption:mods.title.main">
            <span class="fa fa-chevron-right icon" />
            <span class="caption">
              <xsl:value-of select="$label.nextHit" />
            </span>
          </a>
        </div>
      </xsl:if>
    </div>

    <script type="text/javascript">
      <![CDATA[
        $(document).ready(function() {
          var replaceUrlParam = function(url, paramName, paramValue) {
            var pattern = new RegExp('\\b(' + paramName + '=).*?(&|$)')
            if (url.search(pattern) >= 0) {
              return url.replace(pattern, '$1' + paramValue + '$2');
            }
            return url + (url.indexOf('?') > 0 ? '&' : '?') + paramName + '=' + paramValue
          }
        
          $("*[data-pagination]").each(function() {
            var $this = $(this);
            var sel = /([^\:]*)\:(.*)/.exec($(this).data("pagination")).slice(1);
        
            if (sel && sel.length > 1) {
              var url = replaceUrlParam(replaceUrlParam($(this).attr("href"), "XSL.Style", "xml"), "fl", sel[1]);
              $.ajax(url).done(function(data) {
                var $xml = $(data);
                var title = $xml.find("*[name='" + sel[1] + "']").text();
                if (title) {
                  $this.attr("title", title);
                  $(sel[0], $this).text(title);
                }
              });
            }
          });
        });
      ]]>
    </script>
  </xsl:template>
  
  <xsl:template name="paginateLink">
    <xsl:param name="href" />
    <xsl:param name="page" select="1" />
    <xsl:param name="numPerPage" />

    <xsl:value-of select="concat($href, '&amp;start=',(($page -1) * $numPerPage), '&amp;rows=', $numPerPage)" />
  </xsl:template>
</xsl:stylesheet>