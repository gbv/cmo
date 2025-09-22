<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~  This file is part of ***  M y C o R e  ***
  ~  See http://www.mycore.de/ for details.
  ~
  ~  This program is free software; you can use it, redistribute it
  ~  and / or modify it under the terms of the GNU General Public License
  ~  (GPL) as published by the Free Software Foundation; either version 2
  ~  of the License or (at your option) any later version.
  ~
  ~  This program is distributed in the hope that it will be useful, but
  ~  WITHOUT ANY WARRANTY; without even the implied warranty of
  ~  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~  GNU General Public License for more details.
  ~
  ~  You should have received a copy of the GNU General Public License
  ~  along with this program, in a file called gpl.txt or license.txt.
  ~  If not, write to the Free Software Foundation Inc.,
  ~  59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
  ~
  -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">


  <xsl:template match="mei:relationList" mode="metadataView">
    <xsl:comment>mei/relationList.xsl > mei:relationList</xsl:comment>

    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.relatedSources'" />
      <xsl:with-param name="content">
        <xsl:for-each select="mei:relation">
          <xsl:if test="@rel='isRealizationOf' and count(ancestor-or-self::mei:expression)=1 and contains(@target, '_work_')">
            <xsl:variable name="expressionId" select="ancestor-or-self::mycoreobject/@ID" />
            <xsl:variable name="canWriteExpression" select="acl:checkPermission($expressionId,'writedb')" />
            <xsl:if test="$canWriteExpression">
              <a class="text-info small mr-2" data-link-action="remove" data-link-from="{@target}"
                data-link-to="{$expressionId}"
                href="#" title="{i18n:translate('editor.label.expression.list.remove')}">
                <span class="fa fa-unlink"></span>
              </a>
            </xsl:if>
          </xsl:if>

          <xsl:call-template name="objectLink">
            <xsl:with-param select="./@target" name="obj_id" />
          </xsl:call-template>
          <br />
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


</xsl:stylesheet>
