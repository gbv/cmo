<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:FilenameUtils="xalan://org.apache.commons.io.FilenameUtils"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:iview2="xalan://org.mycore.iview2.services.MCRIView2Tools"
                xmlns:iview2xsl="xalan://org.mycore.iview2.frontend.MCRIView2XSLFunctionsAdapter"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="xalan i18n xlink FilenameUtils iview2 iview2xsl mcrxsl">

  <xsl:param name="UserAgent" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template match="structure" mode="showViewer">
    <xsl:if test="derobjects/derobject">
      <div id="cmo-viewer">
          <xsl:if test="count(derobjects/derobject[key('rights', @xlink:href)/@read]) > 0">
            <div class="row cmo-preview">
              <div class="col-md-12">
                <h3 class="cmo-viewer">Vorschau</h3>
                <!-- show one viewer for each derivate -->
                <xsl:for-each select="derobjects/derobject[key('rights', @xlink:href)/@read]">
                  <xsl:call-template name="createViewer" />
                </xsl:for-each>
              </div>
            </div>
          </xsl:if>
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="createViewer">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="mainFile" select="mcrxsl:getMainDocName($derId)" />
    <xsl:variable name="viewerId" select="concat($derId, ':', $mainFile)" />


    <xsl:choose>
      <xsl:when test="iview2:getSupportedMainFile($derId)">
        <xsl:choose>
          <xsl:when test="iview2:isCompletelyTiled($derId)">
            <!-- The file will be displayed with mets -->

            <xsl:call-template name="createViewerContainer">
              <xsl:with-param name="viewerId" select="$viewerId" />
              <xsl:with-param name="viewerType" select="'mets'" />
              <xsl:with-param name="derId" select="$derId" />
            </xsl:call-template>
            <xsl:call-template name="loadViewer">
              <xsl:with-param name="derivate" select="$derId" />
              <xsl:with-param name="file" select="$mainFile" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <div class="well no-viewer">
              <xsl:value-of select="i18n:translate('metaData.previewInProcessing', $derId)" />
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mcrxsl:getMimeType($mainFile) = 'application/pdf' and not(mcrxsl:isMobileDevice($UserAgent))">
        <xsl:call-template name="createViewerContainer">
          <xsl:with-param name="viewerId" select="$viewerId" />
          <xsl:with-param name="viewerType" select="'pdf'" />
          <xsl:with-param name="derId" select="$derId" />
        </xsl:call-template>
        <xsl:call-template name="loadViewer">
          <xsl:with-param name="derivate" select="$derId" />
          <xsl:with-param name="file" select="$mainFile" />
        </xsl:call-template>
        <noscript>
          <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$derId}/{$mainFile}">
            <xsl:value-of select="$mainFile" />
          </a>
        </noscript>
      </xsl:when>
      <xsl:otherwise>
        <!-- The file cannot be displayed -->
        <xsl:comment>The Viewer doesnt support the file
          <xsl:value-of select="$mainFile" />
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="loadViewer">
    <xsl:param name="derivate" />
    <xsl:param name="file" />
    <xsl:variable name="viewerJS" select="concat($WebApplicationBaseURL, 'rsc/viewer/', $derivate, '/', $file, '?embedded=true&amp;XSL.Style=js')" />
    <script src="{$viewerJS}">
    </script>
  </xsl:template>


  <xsl:template name="createViewerContainer">
    <xsl:param name="viewerId" />
    <xsl:param name="viewerType" />
    <xsl:param name="derId" />

    <!-- TODO: added .mycoreViewer and some styles, but embedded viewer still does not work -->
    <div data-viewer="{$viewerId}" class="viewer {$viewerType} mycoreViewer" style="height: 550px;position: relative;margin-bottom: 30px;overflow: hidden;">
    </div>

  </xsl:template>


</xsl:stylesheet>
