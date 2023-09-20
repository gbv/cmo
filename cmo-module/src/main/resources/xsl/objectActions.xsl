<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mcr="http://www.mycore.org/"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:pi="xalan://org.mycore.pi.frontend.MCRIdentifierXSLUtils"
  xmlns:dateUtil="xalan://de.vzg.cmo.CMODateUtil"
  exclude-result-prefixes="xalan xlink mcr i18n acl mcrxsl mods mei encoder" version="1.0">
  <xsl:param name="MCR.Users.Superuser.UserName" />

  <xsl:template name="objectActions">
    <xsl:param name="id" select="./@ID" />
    <xsl:param name="accessedit" select="acl:checkPermission($id,'writedb')" />
    <xsl:param name="accessdelete" select="acl:checkPermission($id,'deletedb')" />

      <div class="dropdown float-right">
        <button class="btn btn-light dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-expanded="true">
          <span class="fas fa-cog" aria-hidden="true"></span> Aktionen
        </button>
        <ul class="dropdown-menu cmo-dropdown" role="menu" aria-labelledby="dropdownMenu1">
          <li class="dropdown-item" role="presentation">
            <a class="dropdown-link" href="#" role="menuitem" data-basket="{$id}"></a>
          </li>
          <xsl:if test="$accessedit or $accessdelete">
            <li class="dropdown-item" role="presentation">
              <xsl:variable name="type">
                <xsl:choose>
                  <xsl:when test="substring-before(substring-after($id, '_'), '_') = 'mods' and
                  substring-after(//mods:mods/mods:classification/@valueURI, 'cmo_kindOfData#') = 'source'">
                    <!-- source mods = bibliography -->
                    <xsl:value-of select="'bibliography'" />
                  </xsl:when>
                  <xsl:when test="substring-before(substring-after($id, '_'), '_') = 'mods'">
                    <!-- edition mods = edition -->
                    <xsl:value-of select="'edition'" />
                  </xsl:when>
                  <xsl:when test="//mei:classification/mei:termList/mei:term = 'Manuscript'">
                    <xsl:value-of select="'manuscript'" />
                  </xsl:when>
                  <xsl:when test="//mei:classification/mei:termList/mei:term = 'Printed_source'">
                    <xsl:value-of select="'print'" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="substring-before(substring-after($id, '_'), '_')" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <a class="dropdown-link" role="menuitem" tabindex="-1" href="{$WebApplicationBaseURL}editor/{$type}.xed?id={$id}">
                <xsl:value-of select="i18n:translate('object.editObject')" />
              </a>
            </li>
            <xsl:variable name="objType" select="substring-before(substring-after($id, '_'), '_')"/>
            <xsl:if test="contains('expression,source,mods', $objType)">
              <li class="dropdown-item">
              <a class="dropdown-link" href="#" onclick="javascript: $('.drop-to-object-optional').toggle(); window.setTimeout(function(){{ window.scrollTo(0, $('.drop-to-object-optional,.drop-to-object').offset().top-50);}}, 100);">
                <xsl:value-of select="i18n:translate('cmo.upload.addDerivate')" />
              </a>
            </li>
            </xsl:if>
            <xsl:if test="substring-before(substring-after($id, '_'), '_') = 'expression'">
              <!-- expression component actions -->
              <li class="dropdown-item" role="presentation">
                <a class="dropdown-link" role="menuitem" tabindex="-1"
                   href="#action=set-parent&amp;of={$id}&amp;q=(category.top%3A%22cmo_kindOfData%3Asource%22%20OR%20cmoType%3Aperson)&amp;fq=cmoType%3Aexpression">
                  <xsl:value-of select="i18n:translate('cmo.replace.parent')" />
                </a>
              </li>
              <li class="dropdown-item" role="presentation">
                <a  class="dropdown-link" role="menuitem" tabindex="-1"
                   href="#action=add-child&amp;to={$id}&amp;q=(category.top%3A%22cmo_kindOfData%3Asource%22%20OR%20cmoType%3Aperson)&amp;fq=cmoType%3Aexpression">
                  <xsl:value-of select="i18n:translate('cmo.add.child')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="substring-before(substring-after($id, '_'), '_') = 'work'">
              <!-- work component actions -->
              <li class="dropdown-item" role="presentation">
                <a class="dropdown-link" role="menuitem" tabindex="-1"
                  href="#action=set-parent&amp;of={$id}&amp;q=(category.top%3A%22cmo_kindOfData%3Asource%22%20OR%20cmoType%3Aperson)&amp;fq=cmoType%3Awork">
                  <xsl:value-of select="i18n:translate('cmo.replace.parent')" />
                </a>
              </li>
              <li class="dropdown-item" role="presentation">
                <a class="dropdown-link" role="menuitem" tabindex="-1"
                  href="#action=add-child&amp;to={$id}&amp;q=(category.top%3A%22cmo_kindOfData%3Asource%22%20OR%20cmoType%3Aperson)&amp;fq=cmoType%3Awork">
                  <xsl:value-of select="i18n:translate('cmo.add.child')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$accessdelete">
              <li class="dropdown-item" role="presentation">
                <a class="confirm_deletion dropdown-link" href="{$ServletsBaseURL}object/delete{$HttpSession}?id={$id}" data-text="{i18n:translate('cmo.confirm.text')}" role="menuitem" tabindex="-1">
                  <xsl:value-of select="i18n:translate('object.delObject')" />
                </a>
              </li>
            </xsl:if>

            <!-- Register PI -->
            <xsl:variable name="piServiceInformation" select="pi:getPIServiceInformation($id)" />
            <xsl:for-each select="$piServiceInformation">
              <xsl:if test="@permission='true'">
                <li class="dropdown-item">
                  <xsl:if test="@inscribed='true'">
                    <xsl:attribute name="class">
                      <xsl:text>disabled</xsl:text>
                    </xsl:attribute>
                  </xsl:if>

                  <!-- data-type is just used for translation -->
                  <a class="dropdown-link" href="#" data-type="{@type}"
                     data-mycoreID="{$id}"
                     data-baseURL="{$WebApplicationBaseURL}">
                    <xsl:if test="@inscribed='false'">
                      <xsl:attribute name="data-register-pi">
                        <xsl:value-of select="@id" />
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="i18n:translate(concat('component.pi.register.',@id))" />
                  </a>
                </li>
              </xsl:if>
            </xsl:for-each>
          </xsl:if>
        </ul>
      </div>

    <div class="modal fade" id="modal-pi" tabindex="-1" role="dialog" data-backdrop="static">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title" data-i18n="component.pi.register."></h4>
          </div>
          <div class="modal-body">
            <div class="row">
              <div class="col-md-2">
                <i class="fas fa-question-circle"></i>
              </div>
              <div class="col-md-10" data-i18n="component.pi.register.modal.text."></div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-light modal-pi-cancel" data-dismiss="modal">
              <xsl:value-of select="i18n:translate('component.pi.register.modal.abort')" />
            </button>
            <button type="button" class="btn btn-danger" id="modal-pi-add"
                    data-i18n="component.pi.register.">
            </button>
          </div>
        </div>
      </div>
    </div>

  </xsl:template>


  <xsl:template match="derobject">
    <xsl:param name="objID" />
    <xsl:variable name="derId" select="@xlink:href" />

    <xsl:if test="(key('rights', $derId)/@read and mcrxsl:isDisplayedEnabledDerivate($derId)) or key('rights', $derId)/@write">

    <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />

    <!-- TODO: use http://www.verovio.org for mei presentation -->
    <!-- script src="{$WebApplicationBaseURL}js/verovio-toolkit.js"></script>
    <div id="output"/>
    <script type="text/javascript">
        var vrvToolkit = new verovio.toolkit();
        /* Load the file using HTTP GET */
        $.get( "../servlets/MCRFileNodeServlet/cmo_derivate_00000001/NE203__p._1-1_1.0.mei", function( data ) {
            var svg = vrvToolkit.renderData(data, {});
            $("#output").html(svg);
        }, 'text');
    </script -->

    <div id="files{@xlink:href}" class="file_box">
      <div class="row header">
        <div class="col-12">
          <div class="headline">
            <div class="title">
              <a class="btn btn-primary btn-sm file_toggle" data-toggle="collapse" href="#collapse{@xlink:href}" aria-expanded="false" aria-controls="collapse{@xlink:href}">
                <span>
                  <xsl:choose>
                    <xsl:when test="$derivateXML//titles/title[@xml:lang=$CurrentLang]">
                      <xsl:value-of select="$derivateXML//titles/title[@xml:lang=$CurrentLang]" />
                    </xsl:when>
                    <xsl:otherwise>
                      <!-- xsl:value-of select="i18n:translate('metadata.files.file')" / -->
                      Dateien
                    </xsl:otherwise>
                  </xsl:choose>
                </span>
                <xsl:if test="position() > 1">
                  <span class="set_number">
                    <xsl:value-of select="position()" />
                  </span>
                </xsl:if>
              </a>
            </div>
            <xsl:apply-templates select="." mode="derivateActions">
              <xsl:with-param name="deriv" select="@xlink:href" />
              <xsl:with-param name="parentObjID" select="$objID" />
            </xsl:apply-templates>
            <div class="clearfix" />
          </div>
        </div>
      </div>

      <div id="collapse{@xlink:href}" class="row body collapse show">
        <xsl:variable name="ifsDirectory" select="document(concat('ifs:',$derId,'/'))" />
        <xsl:variable name="numOfFiles" select="count($ifsDirectory/mcr_directory/children/child)" />
        <xsl:variable name="maindoc" select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
        <xsl:variable name="path" select="$ifsDirectory/mcr_directory/path" />

        <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
          <xsl:variable name="fileNameExt" select="concat($path,./name)" />
          <xsl:apply-templates select="." >
            <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
            <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
            <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
          </xsl:apply-templates>
        </xsl:for-each>
      </div>

    </div>
    </xsl:if>
  </xsl:template>


  <xsl:template match="child[@type='directory']" >
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="maindoc" />

    <xsl:apply-templates select="." mode="childWriter">
      <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
      <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
      <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
    </xsl:apply-templates>

    <xsl:variable name="dirName" select="./name" />
    <xsl:variable name="directory" select="document(concat('ifs:',$derId,'/',mcrxsl:encodeURIPath($dirName)))" />
    <xsl:for-each select="$directory/mcr_directory/children/child">
      <xsl:apply-templates select="." mode="childWriter">
        <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
        <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
        <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="child[@type='file']">
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="maindoc" />

    <xsl:apply-templates select="." mode="childWriter">
      <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
      <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
      <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="child" mode="childWriter">
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="maindoc" />

    <xsl:variable name="path" select="../../path" />
    <xsl:variable name="fileName" >
      <xsl:choose>
        <xsl:when test="$path != '/' and $path != ''">
          <xsl:value-of select="substring(concat($path,./name),2)" ></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="./name" ></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="filePath" select="concat($derId,'/',mcrxsl:encodeURIPath($fileName),$HttpSession)" />
    <xsl:variable name="fileCss">
      <xsl:choose>
        <xsl:when test="$maindoc = $fileName">
          <xsl:text>active_file</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>file</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="col-12">
      <div class="file_set {$fileCss}" data-upload-target="/">
        <xsl:if test="(acl:checkPermission($derId,'writedb') or acl:checkPermission($derId,'deletedb'))">
          <xsl:attribute name="data-upload-object">
            <xsl:value-of select="$derId" />
          </xsl:attribute>
          <xsl:attribute name="data-upload-target">
            <xsl:choose>
              <xsl:when test="@type='directory'">
                <xsl:value-of select="concat($path, $fileName, '/')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$path" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <div class="options float-right">
            <div class="btn-group">
              <a href="#" class="btn btn-light dropdown-toggle" data-toggle="dropdown">
                <i class="fas fa-cog"></i>
              </a>
              <ul class="dropdown-menu dropdown-menu-right">
                <xsl:if test="acl:checkPermission($derId,'writedb') and @type!='directory'">
                  <li class="dropdown-item">
                    <a title="{i18n:translate('IFS.mainFile')}"
                      href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=ssetfile&amp;file={$fileName}"
                      class="dropdown-link option" >
                      <span class="fas fa-star"></span>
                      <xsl:value-of select="i18n:translate('IFS.mainFile')" />
                    </a>
                  </li>
                </xsl:if>
                <xsl:if test="acl:checkPermission($derId,'deletedb')">
                  <li class="dropdown-item">
                    <a href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=sdelfile&amp;file={$fileName}"
                      class="option dropdown-link confirm_deletion">
                      <xsl:attribute name="data-text">
                        <xsl:value-of select="i18n:translate(concat('confirm.',@type,'.text'))" />
                      </xsl:attribute>
                      <xsl:attribute name="title">
                        <xsl:value-of select="i18n:translate(concat('IFS.',@type,'Delete'))" />
                      </xsl:attribute>
                      <span class="fas fa-trash-alt"></span>
                      <xsl:value-of select="i18n:translate(concat('IFS.',@type,'Delete'))" />
                    </a>
                  </li>
                </xsl:if>
              </ul>
            </div>
          </div>
        </xsl:if>
        <span class="file_size">
          <xsl:text>[ </xsl:text>
          <xsl:call-template name="formatFileSize">
            <xsl:with-param name="size" select="size" />
          </xsl:call-template>
          <xsl:text> ]</xsl:text>
        </span>
        <span class="file_date">
            <xsl:value-of select="dateUtil:formatDate(date[@type='lastModified']/text())" />
        </span>
        <span class="file_preview">
          <img src="{$WebApplicationBaseURL}content/images/misc_icons/icon_common_disabled.png" alt="">
            <xsl:if test="'.pdf' = translate(substring($fileName, string-length($fileName) - 3),'PDF','pdf')">
              <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
              <xsl:attribute name="data-placement">top</xsl:attribute>
              <xsl:attribute name="data-html">true</xsl:attribute>
              <xsl:attribute name="data-title">
                  <xsl:text>&lt;img src="</xsl:text>
                  <xsl:value-of select="concat($WebApplicationBaseURL,'img/pdfthumb/',$filePath,'?centerThumb=no')" />
                  <xsl:text>"&gt;</xsl:text>
                </xsl:attribute>
            </xsl:if>
          </img>
        </span>
        <span class="file_name">
          <xsl:choose>
            <xsl:when test="@type!='directory'" >
             <a>
               <xsl:attribute name="href" >
                 <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$filePath)" />
               </xsl:attribute>
               <xsl:value-of select="$fileName" />
             </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$fileName" />
            </xsl:otherwise>
          </xsl:choose>
        </span>
        <xsl:if test="concat($derId,'/',$maindoc) = $filePath">
          <span class="{$fileCss} fas fa-star" style="margin-left:10px"></span>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="derobject" mode="derivateActions">
    <xsl:param name="deriv" />
    <xsl:param name="parentObjID" />
    <xsl:param name="suffix" select="''" />

    <xsl:variable select="concat('mcrobject:',$deriv)" name="derivlink" />
    <xsl:variable select="document($derivlink)" name="derivate" />

    <div class="options float-right">
      <div class="btn-group">
        <a href="#" class="btn btn-light dropdown-toggle" data-toggle="dropdown">
          <i class="fas fa-cog"></i>
          <xsl:value-of select="i18n:translate('cmo.derivate.action')" />
        </a>
        <ul class="dropdown-menu dropdown-menu-right">
          <!-- TODO: fix derivate editor -->
          <!-- xsl:if test="key('rights', $deriv)/@write">
            <li>
              <a href="{$WebApplicationBaseURL}editor/editor-derivate.xed{$HttpSession}?derivateid={$deriv}" class="option">
                <xsl:value-of select="i18n:translate('component.mods.metaData.options.updateDerivateName')" />
              </a>
            </li>
          </xsl:if -->
          <xsl:if test="key('rights', $deriv)/@write">
            <li class="dropdown-item">
              <a href="{$ServletsBaseURL}MCRDisplayHideDerivateServlet?derivate={$deriv}" class="option dropdown-link">
                <xsl:value-of select="i18n:translate(concat('cmo.derivate.display.', $derivate//derivate/@display))" />
              </a>
            </li>
          </xsl:if>
          <xsl:if test="key('rights', $deriv)/@read">
            <li class="dropdown-item">
              <a href="{$ServletsBaseURL}MCRZipServlet/{$deriv}" class="option dropdown-link">
                <xsl:value-of select="i18n:translate('component.mods.metaData.options.zip')" />
              </a>
            </li>
          </xsl:if>
          <xsl:if test="key('rights', $deriv)/@delete">
            <li class="last dropdown-item">
              <a href="{$ServletsBaseURL}derivate/delete{$HttpSession}?id={$deriv}" class="confirm_deletion option dropdown-link" data-text="{i18n:translate('cmo.confirm.derivate.text')}">
                <xsl:value-of select="i18n:translate('component.mods.metaData.options.delDerivate')" />
              </a>
            </li>
          </xsl:if>
        </ul>
      </div>
    </div>
  </xsl:template>


</xsl:stylesheet>
