<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mcr="http://www.mycore.org/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:encoder="xalan://java.net.URLEncoder" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"
  exclude-result-prefixes="xalan xlink mcr i18n acl mods mcrxsl mcrurn encoder" version="1.0">
  <xsl:param name="MCR.Users.Superuser.UserName" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" select="''" />


  <xsl:template match="/mycoreobject[contains(@ID,'_simpledoc_')]">

    <head>
      <link href="{$WebApplicationBaseURL}css/file.css" rel="stylesheet" />
    </head>

    <div class="row">

      <xsl:call-template name="objectActions">
        <xsl:with-param name="id" select="@ID" />
      </xsl:call-template>

      <h1>
        <xsl:value-of select="metadata/def.title/title" />
      </h1>

      <table class="table">
        <tr>
          <th>
            <xsl:value-of select="i18n:translate('docdetails.ID')" />
          </th>
          <td>
            <xsl:call-template name="objectLink">
              <xsl:with-param select="." name="mcrobj" />
            </xsl:call-template>
          </td>
        </tr>

        <xsl:if test="metadata/def.creator/creator">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.author')" />
            </th>
            <td>
              <xsl:for-each select="metadata/def.creator/creator">
                <xsl:value-of select="." />
                <br />
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="metadata/def.date/date">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.date')" />
            </th>
            <td>
              <xsl:value-of select="metadata/def.date/date" />
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="metadata/def.language/language">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.language')" />
            </th>
            <td>
              <xsl:for-each select="metadata/def.language/language">
                <xsl:variable name="classlink">
                  <xsl:call-template name="ClassCategLink">
                    <xsl:with-param name="classid">
                      <xsl:value-of select="./@classid" />
                    </xsl:with-param>
                    <xsl:with-param name="categid">
                      <xsl:value-of select="./@categid" />
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="document($classlink)/mycoreclass/categories/category">
                  <xsl:variable name="selectLang">
                    <xsl:call-template name="selectLang">
                      <xsl:with-param name="nodes" select="./label" />
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:for-each select="./label[lang($selectLang)]">
                    <xsl:value-of select="@text" />
                  </xsl:for-each>
                </xsl:for-each>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>
      </table>
    </div>

    <!-- show derivates if available and CurrentUser has read access -->
    <xsl:if test="structure/derobjects/derobject[acl:checkPermission(@xlink:href,'read')]">
      <div class="row">
        <xsl:apply-templates select="structure/derobjects/derobject[acl:checkPermission(@xlink:href,'read')]">
          <xsl:with-param name="objID" select="@ID" />
        </xsl:apply-templates>
      </div>
    </xsl:if>

  </xsl:template>


  <xsl:template name="objectActions">
    <xsl:param name="id" select="./@ID" />
    <xsl:param name="accessedit" select="acl:checkPermission($id,'writedb')" />
    <xsl:param name="accessdelete" select="acl:checkPermission($id,'deletedb')" />

    <xsl:if test="$accessedit or $accessdelete">
      <div class="dropdown pull-right">
        <button class="btn btn-default dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-expanded="true">
          <span class="glyphicon glyphicon-cog" aria-hidden="true"></span> Aktionen
          <span class="caret"></span>
        </button>
        <ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu1">
          <li role="presentation">
            <a role="menuitem" tabindex="-1" href="{$WebApplicationBaseURL}content/publish/simpledoc.xed?id={$id}">
              <xsl:value-of select="i18n:translate('object.editObject')" />
            </a>
          </li>
          <li role="presentation">
            <a href="{$ServletsBaseURL}derivate/create{$HttpSession}?id={$id}" role="menuitem" tabindex="-1">
              <xsl:value-of select="i18n:translate('derivate.addDerivate')" />
            </a>
          </li>
          <xsl:if test="$accessdelete">
            <li role="presentation">
              <a href="{$ServletsBaseURL}object/delete{$HttpSession}?id={$id}" role="menuitem" tabindex="-1">
                <xsl:value-of select="i18n:translate('object.delObject')" />
              </a>
            </li>
          </xsl:if>
        </ul>
      </div>

    </xsl:if>

  </xsl:template>


  <xsl:template match="derobject">
    <xsl:param name="objID" />
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />
    <xsl:variable name="derivateWithURN" select="mcrurn:hasURNDefined($derId)" />

    <div id="files{@xlink:href}" class="file_box">
      <div class="row header">
        <div class="col-xs-12">
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
                <span class="caret"></span>
              </a>

              <xsl:if test="$derivateWithURN=true()">
                <xsl:variable name="derivateURN" select="$derivateXML/mycorederivate/derivate/fileset/@urn" />
                <sup class="file_urn">
                  <a href="{$MCR.URN.Resolver.MasterURL}{$derivateURN}" title="{$derivateURN}">
                    URN
                  </a>
                </sup>
              </xsl:if>
            </div>
            <xsl:apply-templates select="." mode="derivateActions">
              <xsl:with-param name="deriv" select="@xlink:href" />
              <xsl:with-param name="parentObjID" select="$objID" />
            </xsl:apply-templates>
            <div class="clearfix" />
          </div>
        </div>
      </div>

      <div id="collapse{@xlink:href}" class="row body collapse in">
        <xsl:variable name="ifsDirectory" select="document(concat('ifs:',$derId,'/'))" />
        <xsl:variable name="numOfFiles" select="count($ifsDirectory/mcr_directory/children/child)" />
        <xsl:variable name="maindoc" select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
        <xsl:variable name="path" select="$ifsDirectory/mcr_directory/path" />

        <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
          <xsl:variable name="fileNameExt" select="concat($path,./name)" />
          <xsl:variable name="urn" select="$derivateXML/mycorederivate/derivate/fileset/file[@name=$fileNameExt]/urn" />
          <xsl:apply-templates select="." >
            <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
            <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
            <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
            <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
            <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
          </xsl:apply-templates>
        </xsl:for-each>
      </div>

    </div>
  </xsl:template>


  <xsl:template match="child[@type='directory']" >
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="derivateWithURN" />
    <xsl:param name="maindoc" />
    <xsl:param name="urn" />

    <xsl:apply-templates select="." mode="childWriter">
      <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
      <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
      <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
      <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
      <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
    </xsl:apply-templates>

    <xsl:variable name="dirName" select="./name" />
    <xsl:variable name="directory" select="document(concat('ifs:',$derId,'/',mcrxsl:encodeURIPath($dirName)))" />
    <xsl:for-each select="$directory/mcr_directory/children/child">
      <xsl:apply-templates select="." mode="childWriter">
        <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
        <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
        <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
        <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
        <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="child[@type='file']">
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="derivateWithURN" />
    <xsl:param name="maindoc" />
    <xsl:param name="urn" />

    <xsl:apply-templates select="." mode="childWriter">
      <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
      <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
      <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
      <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
      <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="child" mode="childWriter">
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="derivateWithURN" />
    <xsl:param name="maindoc" />
    <xsl:param name="urn" />

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
    <div class="col-xs-12">
      <div class="file_set {$fileCss}">
        <xsl:if test="(acl:checkPermission($derId,'writedb') or acl:checkPermission($derId,'deletedb')) and $derivateWithURN='false'">
          <div class="options pull-right">
            <div class="btn-group">
              <a href="#" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                <i class="fa fa-cog"></i>
                <span class="caret"></span>
              </a>
              <ul class="dropdown-menu dropdown-menu-right">
                <xsl:if test="acl:checkPermission($derId,'writedb') and @type!='directory'">
                  <li>
                    <a title="{i18n:translate('IFS.mainFile')}"
                      href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=ssetfile&amp;file={$fileName}"
                      class="option" >
                      <span class="glyphicon glyphicon-star"></span>
                      <xsl:value-of select="i18n:translate('IFS.mainFile')" />
                    </a>
                  </li>
                </xsl:if>
                <xsl:if test="acl:checkPermission($derId,'deletedb')">
                  <li>
                    <a href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=sdelfile&amp;file={$fileName}"
                      class="option confirm_deletion">
                      <xsl:attribute name="data-text">
                        <xsl:value-of select="i18n:translate(concat('mir.confirm.',@type,'.text'))" />
                      </xsl:attribute>
                      <xsl:attribute name="title">
                        <xsl:value-of select="i18n:translate(concat('IFS.',@type,'Delete'))" />
                      </xsl:attribute>
                      <span class="glyphicon glyphicon-trash"></span>
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
        <span class="{$fileCss} glyphicon glyphicon-star">
        </span>
        <span class="file_date">
          <xsl:call-template name="formatISODate">
            <xsl:with-param name="date" select="date[@type='lastModified']" />
            <xsl:with-param name="format" select="i18n:translate('metaData.date')" />
          </xsl:call-template>
        </span>
        <span class="file_preview">
          <img src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" alt="">
            <xsl:if test="'.pdf' = translate(substring($fileName, string-length($fileName) - 3),'PDF','pdf')">
              <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
              <xsl:attribute name="data-placement">top</xsl:attribute>
              <xsl:attribute name="data-html">true</xsl:attribute>
              <xsl:attribute name="data-title">
                  <xsl:text>&lt;img src="</xsl:text>
                  <xsl:value-of select="concat($WebApplicationBaseURL,'img/pdfthumb/',$filePath,'?centerThumb=no')" />
                  <xsl:text>"&gt;</xsl:text>
                </xsl:attribute>
              <xsl:message>
                PDF
              </xsl:message>
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
        <xsl:if test="string-length($urn)>0">
          <sup class="file_urn">
            <a href="{$MCR.URN.Resolver.MasterURL}{$urn}" title="{$urn}">
              URN
            </a>
          </sup>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="derobject" mode="derivateActions">
    <xsl:param name="deriv" />
    <xsl:param name="parentObjID" />
    <xsl:param name="suffix" select="''" />

    <xsl:if test="acl:checkPermission($deriv,'writedb')">
      <xsl:variable select="concat('mcrobject:',$deriv)" name="derivlink" />
      <xsl:variable select="document($derivlink)" name="derivate" />
      <xsl:variable name="derivateWithURN" select="mcrurn:hasURNDefined($deriv)" />


      <div class="options pull-right">
        <div class="btn-group">
          <a href="#" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
            <i class="fa fa-cog"></i>
            <xsl:value-of select="' Aktionen'" />
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu dropdown-menu-right">
            <li>
              <a href="{$ServletsBaseURL}derivate/update{$HttpSession}?id={$deriv}">
                <!-- xsl:value-of select="i18n:translate('component.swf.derivate.updateFile')" / -->
                Beschriftung bearbeiten
              </a>
            </li>
            <xsl:choose>
              <xsl:when test="$derivateWithURN=false()">
                <li>
                  <a href="{$ServletsBaseURL}derivate/update{$HttpSession}?objectid={../../../@ID}&amp;id={$deriv}{$suffix}" class="option">
                    <xsl:value-of select="i18n:translate('component.swf.derivate.addFile')" />
                  </a>
                </li>
              </xsl:when>
              <xsl:otherwise>
                <li><!-- xsl:value-of select="i18n:translate('component.swf.derivate.addFile')" /-->
                  Bearbeitung wg. URN gesperrt
                </li>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$derivateWithURN=false() and mcrxsl:isAllowedObjectForURNAssignment($parentObjID) and acl:checkPermission($deriv,'addurn')">
              <xsl:variable name="apos">
                <xsl:text>'</xsl:text>
              </xsl:variable>
              <li>
                <xsl:if test="not(acl:checkPermission($deriv,'deletedb'))">
                  <xsl:attribute name="class">last</xsl:attribute>
                </xsl:if>
                <a href="{$ServletsBaseURL}MCRAddURNToObjectServlet{$HttpSession}?object={$deriv}&amp;target=derivate" onclick="{concat('return confirm(',$apos, i18n:translate('component.mods.metaData.options.urn.confirm'), $apos, ');')}"
                  class="option"
                >
                  <xsl:value-of select="i18n:translate('component.mods.metaData.options.urn')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="acl:checkPermission($deriv,'deletedb') and $derivateWithURN=false()">
              <li class="last">
                <a href="{$ServletsBaseURL}derivate/delete{$HttpSession}?id={$deriv}" class="confirm_deletion option" data-text="{i18n:translate('mir.confirm.derivate.text')}">
                  <xsl:value-of select="i18n:translate('component.swf.derivate.delDerivate')" />
                </a>
              </li>
            </xsl:if>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>
