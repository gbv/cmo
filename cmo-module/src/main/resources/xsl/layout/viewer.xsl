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
    <!-- only derivates that are readable and actually have a main file get a tab -->
    <xsl:variable name="readableDerivates"
      select="derobjects/derobject[key('rights', @xlink:href)/@read
                                   and string(mcrxsl:getMainDocName(@xlink:href)) != '']" />
    <!-- the tei/xml edition is shown by default; only if none exists the first derivate wins -->
    <xsl:variable name="teiDerivates"
      select="$readableDerivates[
                translate(FilenameUtils:getExtension(mcrxsl:getMainDocName(@xlink:href)),
                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'xml'
             or translate(FilenameUtils:getExtension(mcrxsl:getMainDocName(@xlink:href)),
                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'tei']" />
    <xsl:variable name="defaultHref">
      <xsl:choose>
        <xsl:when test="$teiDerivates">
          <xsl:value-of select="$teiDerivates[1]/@xlink:href" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$readableDerivates[1]/@xlink:href" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="count($readableDerivates) &gt; 0">
      <div id="cmo-viewer">
        <div class="row cmo-preview">
          <div class="col-md-12">
            <!-- one tab per readable derivate; the tab title is the derivate_types label.
                 xml/tei main files get an extra "<label> (XML)" tab with the raw source -->
            <ul class="nav nav-tabs cmo-viewer-tabs" role="tablist">
              <xsl:for-each select="$readableDerivates">
                <xsl:variable name="tabId" select="concat('cmo-tab-', @xlink:href)" />
                <xsl:variable name="ext"
                  select="translate(FilenameUtils:getExtension(mcrxsl:getMainDocName(@xlink:href)),
                                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
                <xsl:variable name="label">
                  <xsl:call-template name="viewerTabLabel">
                    <xsl:with-param name="categid"
                      select="classification[@classid='derivate_types']/@categid" />
                  </xsl:call-template>
                </xsl:variable>
                <li class="nav-item" role="presentation">
                  <a class="nav-link" role="tab" data-toggle="tab" href="#{$tabId}"
                     id="{$tabId}-label" aria-controls="{$tabId}">
                    <xsl:if test="@xlink:href = $defaultHref">
                      <xsl:attribute name="class">nav-link active</xsl:attribute>
                      <xsl:attribute name="aria-selected">true</xsl:attribute>
                    </xsl:if>
                    <xsl:copy-of select="$label" />
                  </a>
                </li>
                <xsl:if test="$ext = 'xml' or $ext = 'tei'">
                  <xsl:variable name="xmlTabId" select="concat('cmo-tab-', @xlink:href, '-xml')" />
                  <li class="nav-item" role="presentation">
                    <a class="nav-link" role="tab" data-toggle="tab" href="#{$xmlTabId}"
                       id="{$xmlTabId}-label" aria-controls="{$xmlTabId}">
                      <xsl:copy-of select="$label" />
                      <xsl:text> (XML)</xsl:text>
                    </a>
                  </li>
                </xsl:if>
              </xsl:for-each>
            </ul>
            <div class="tab-content cmo-viewer-tab-content">
              <xsl:for-each select="$readableDerivates">
                <xsl:variable name="tabId" select="concat('cmo-tab-', @xlink:href)" />
                <xsl:variable name="ext"
                  select="translate(FilenameUtils:getExtension(mcrxsl:getMainDocName(@xlink:href)),
                                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
                <div class="tab-pane fade" id="{$tabId}" role="tabpanel"
                     aria-labelledby="{$tabId}-label">
                  <xsl:if test="@xlink:href = $defaultHref">
                    <xsl:attribute name="class">tab-pane fade show active</xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="viewerTabPane" />
                </div>
                <xsl:if test="$ext = 'xml' or $ext = 'tei'">
                  <xsl:variable name="xmlTabId" select="concat('cmo-tab-', @xlink:href, '-xml')" />
                  <div class="tab-pane fade" id="{$xmlTabId}" role="tabpanel"
                       aria-labelledby="{$xmlTabId}-label">
                    <xsl:call-template name="viewerXmlPane" />
                  </div>
                </xsl:if>
              </xsl:for-each>
            </div>
          </div>
        </div>
        <xsl:call-template name="loadTeiScript" />
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>

  <!-- resolves the tab title from the derivate_types classification label -->
  <xsl:template name="viewerTabLabel">
    <xsl:param name="categid" />
    <xsl:choose>
      <xsl:when test="string($categid) != ''">
        <xsl:variable name="cat"
          select="document(concat('classification:metadata:0:children:derivate_types:', $categid))//category[@ID=$categid]" />
        <xsl:choose>
          <xsl:when test="$cat/label[@xml:lang=$CurrentLang]">
            <xsl:value-of select="$cat/label[@xml:lang=$CurrentLang]/@text" />
          </xsl:when>
          <xsl:when test="$cat/label[@xml:lang='en']">
            <xsl:value-of select="$cat/label[@xml:lang='en']/@text" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$categid" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="i18n:translate('cmo.viewer.preview')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Renders the content of a single viewer tab. The rendering is chosen by the file
    extension of the main file, not by the derivate type: an xml/tei main file is shown
    as a TEI edition, everything else (pdf, images, ...) uses the mycore image viewer.
    The derivate type is only used for the tab title.
  -->
  <xsl:template name="viewerTabPane">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="mainFile" select="mcrxsl:getMainDocName($derId)" />
    <xsl:variable name="ext"
      select="translate(FilenameUtils:getExtension($mainFile),
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
    <xsl:choose>
      <xsl:when test="$ext = 'xml' or $ext = 'tei'">
        <xsl:variable name="teiSrc"
          select="concat($ServletsBaseURL, 'MCRDerivateContentTransformerServlet/', $derId, '/',
                         mcrxsl:encodeURIPath($mainFile), '?XSL.Style=cmoedition')" />
        <!-- the actual TEI html is loaded lazily by loadTeiScript when the tab is shown -->
        <div class="cmo-tei" data-tei-src="{$teiSrc}">
          <div class="cmo-tei-loading text-muted">
            <span class="fas fa-spinner fa-spin"></span>
            <xsl:text> </xsl:text>
            <xsl:value-of select="i18n:translate('cmo.viewer.tei.loading')" />
          </div>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="createViewer" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Renders the "(XML)" tab: the raw main file is transformed to a pretty printed and
    syntax highlighted html fragment (XSL.Style=cmosource) and loaded lazily, reusing
    the same mechanism as the TEI edition tab (see loadTeiScript).
  -->
  <xsl:template name="viewerXmlPane">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="mainFile" select="mcrxsl:getMainDocName($derId)" />
    <xsl:variable name="xmlSrc"
      select="concat($ServletsBaseURL, 'MCRDerivateContentTransformerServlet/', $derId, '/',
                     mcrxsl:encodeURIPath($mainFile), '?XSL.Style=cmosource')" />
    <div class="cmo-tei" data-tei-src="{$xmlSrc}">
      <div class="cmo-tei-loading text-muted">
        <span class="fas fa-spinner fa-spin"></span>
        <xsl:text> </xsl:text>
        <xsl:value-of select="i18n:translate('cmo.viewer.xml.loading')" />
      </div>
    </div>
  </xsl:template>

  <!--
    Lazily loads the TEI edition into its tab, relayouts image viewers on tab change
    and wires up the annotation interaction: hovering a marked text span (.cmo-tei-anno)
    highlights and shows a popover with the matching critical apparatus entries, and
    hovering an apparatus entry highlights the marked span in the text. Because the TEI
    html is loaded lazily, all handlers are delegated from the static #cmo-viewer.
  -->
  <xsl:template name="loadTeiScript">
    <script type="text/javascript">
      (function() {
        function loadTei(el) {
          if (el.getAttribute('data-loaded')) {
            return;
          }
          el.setAttribute('data-loaded', '1');
          $(el).load(el.getAttribute('data-tei-src'));
        }

        var popover = null;
        var hideTimer = null;

        function getPopover() {
          if (!popover) {
            popover = document.createElement('div');
            popover.className = 'cmo-tei-popover';
            popover.style.display = 'none';
            document.body.appendChild(popover);
            popover.addEventListener('mouseenter', function() {
              clearTimeout(hideTimer);
            });
            popover.addEventListener('mouseleave', hidePopover);
          }
          return popover;
        }

        function hidePopover() {
          if (popover) {
            popover.style.display = 'none';
          }
        }

        function clearActive(edition) {
          $(edition).find('.is-active').removeClass('is-active');
        }

        function positionPopover(pop, span) {
          pop.style.left = '0px';
          pop.style.top = '0px';
          pop.style.display = 'block';
          var rect = span.getBoundingClientRect();
          var pw = pop.offsetWidth;
          var docW = document.documentElement.clientWidth;
          var left = rect.left + window.pageXOffset;
          left = Math.max(8, Math.min(left, docW - pw - 8));
          var top = rect.bottom + window.pageYOffset + 6;
          pop.style.left = left + 'px';
          pop.style.top = top + 'px';
        }

        function showAnno(span) {
          clearTimeout(hideTimer);
          var edition = span.closest('.cmo-tei-edition');
          if (!edition) {
            return;
          }
          var id = span.getAttribute('data-anno');
          clearActive(edition);
          span.classList.add('is-active');
          var entries = edition.querySelectorAll('.cmo-tei-app-entry[data-anno="' + id + '"]');
          if (!entries.length) {
            hidePopover();
            return;
          }
          var pop = getPopover();
          pop.innerHTML = '';
          entries.forEach(function(entry) {
            entry.classList.add('is-active');
            var item = document.createElement('div');
            item.className = 'cmo-tei-pop-item';
            var group = entry.closest('.cmo-tei-app-group');
            var heading = group ? group.querySelector('.cmo-tei-app-heading') : null;
            if (heading) {
              var kind = document.createElement('span');
              kind.className = 'cmo-tei-pop-kind';
              kind.textContent = heading.textContent;
              item.appendChild(kind);
            }
            var body = document.createElement('div');
            body.innerHTML = entry.innerHTML;
            item.appendChild(body);
            pop.appendChild(item);
          });
          positionPopover(pop, span);
          pop.style.display = 'block';
        }

        function scheduleHide(span) {
          hideTimer = setTimeout(function() {
            hidePopover();
            var edition = span.closest('.cmo-tei-edition');
            if (edition) {
              clearActive(edition);
            }
          }, 200);
        }

        function toggleSpans(entry, on) {
          var edition = entry.closest('.cmo-tei-edition');
          if (!edition) {
            return;
          }
          var id = entry.getAttribute('data-anno');
          edition.querySelectorAll('.cmo-tei-anno[data-anno="' + id + '"]').forEach(function(s) {
            s.classList.toggle('is-active', on);
          });
        }

        $(function() {
          $('#cmo-viewer .tab-pane.active .cmo-tei[data-tei-src]').each(function() {
            loadTei(this);
          });
          $('#cmo-viewer a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
            var pane = $($(e.target).attr('href'));
            pane.find('.cmo-tei[data-tei-src]').each(function() {
              loadTei(this);
            });
            hidePopover();
            // image viewers that were initialised while hidden need a relayout
            $(window).trigger('resize');
          });

          var viewer = $('#cmo-viewer');
          viewer.on('mouseenter focusin', '.cmo-tei-anno', function() {
            showAnno(this);
          });
          viewer.on('mouseleave focusout', '.cmo-tei-anno', function() {
            scheduleHide(this);
          });
          viewer.on('click', '.cmo-tei-anno', function() {
            var edition = this.closest('.cmo-tei-edition');
            if (!edition) {
              return;
            }
            var entry = edition.querySelector('.cmo-tei-app-entry[data-anno="' + this.getAttribute('data-anno') + '"]');
            if (entry) {
              entry.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
          });
          viewer.on('mouseenter', '.cmo-tei-app-entry', function() {
            toggleSpans(this, true);
          });
          viewer.on('mouseleave', '.cmo-tei-app-entry', function() {
            toggleSpans(this, false);
          });
        });
      })();
    </script>
  </xsl:template>

  <xsl:template name="createViewer">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="mainFile_" select="mcrxsl:getMainDocName($derId)" />
    <xsl:variable name="mainFile">
      <xsl:choose>
        <xsl:when test="not(starts-with($mainFile_, '/'))">
          <xsl:value-of select="concat('/',$mainFile_)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$mainFile_" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


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
            <div class="card no-viewer">
              <div class="card-body">
                <xsl:value-of select="i18n:translate('metaData.previewInProcessing', $derId)" />
              </div>
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
          <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$derId}{$mainFile}">
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
    <xsl:variable name="viewerJS" select="concat($WebApplicationBaseURL, 'rsc/viewer/', $derivate, $file, '?embedded=true&amp;XSL.Style=js')" />
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
