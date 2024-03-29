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

  <xsl:key name="persTypes" match="mei:name" use="concat(@type, ' ')"/>
  <xsl:key name="persNames" match="mei:name" use="concat(@type, ' ', text())"/>

  <xsl:template match="mei:persName[@nymref]" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:persName[@nymref]</xsl:comment>
    <xsl:value-of select="concat(text(), ' ')"/>
    <xsl:call-template name="objectLink">
      <xsl:with-param name="obj_id" select="@nymref"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:persName[mei:name]" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:persName/mei:name</xsl:comment>
    <xsl:variable name="names" select="mei:name"/>
    <xsl:for-each select="mei:name[@type='CMO']">
      <xsl:call-template name="outputType">
        <xsl:with-param name="first" select="true()"/>
        <xsl:with-param name="names" select="$names"/>
        <xsl:with-param name="WebApplicationBaseURL" select="$WebApplicationBaseURL"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="mei:name[generate-id()=generate-id(key('persTypes', concat(@type, ' '))[1]) and not(@type='CMO')]">
      <xsl:sort select="@type" order="descending"/>
      <xsl:call-template name="outputType">
        <xsl:with-param name="first" select="false()"/>
        <xsl:with-param name="names" select="$names"/>
        <xsl:with-param name="WebApplicationBaseURL" select="$WebApplicationBaseURL"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="outputType">
    <xsl:param name="names"/>
    <xsl:param name="WebApplicationBaseURL"/>
    <xsl:param name="first" />
    <xsl:variable name="currentType" select="concat(@type, ' ')"/>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="style">
        <xsl:if test="$first">
          <xsl:value-of select="'cmo_border'"/>
        </xsl:if>
        <xsl:if test="not($first)">
          <xsl:value-of select="'cmo_noBorder'"/>
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="label">
        <xsl:if test="$first">
          <xsl:value-of select="'editor.label.nameVariants'"/>
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="type">
        <xsl:choose>
          <xsl:when test="@type">
            <xsl:value-of select="@type"/>
          </xsl:when>
          <xsl:otherwise>
            -
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:for-each select="$names[generate-id()=generate-id(key('persNames',concat($currentType, text()))[1])]">
          <xsl:variable name="currentText" select="text()"/>
          <xsl:value-of select="text()"/>
          <xsl:for-each select="$names[concat(@type,  ' ') = $currentType and text()=$currentText]">
            <xsl:choose>
              <xsl:when test="@source and @label">
                <small>[
                  <a href="{$WebApplicationBaseURL}receive/{@source}">
                    <xsl:value-of select="@label"/>
                  </a>
                  ]
                </small>
              </xsl:when>
              <xsl:when test="@source">
                <small>[
                  <xsl:call-template name="objectLink">
                    <xsl:with-param select="@source" name="obj_id"/>
                  </xsl:call-template>
                  ]
                </small>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
          <br/>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mei:author" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:author</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.author'" />
      <xsl:with-param name="content">
        <xsl:apply-templates mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mei:editor" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:editor</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.editor'" />
      <xsl:with-param name="content">
        <xsl:apply-templates mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mei:composer" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:composer</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.composer'" />
      <xsl:with-param name="content">
        <xsl:apply-templates mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mei:lyricist" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:lyricist</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.lyricist'" />
      <xsl:with-param name="content">
        <xsl:apply-templates mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template name="showPersonDates">
    <xsl:comment>mei/persName.xsl > mei:date</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.lifeData'" />
      <xsl:with-param name="content">
        <dl>
          <xsl:for-each select="//mei:date[count(. | key('dateByType', @type)[1]) = 1]">
            <xsl:sort select="@type" />
            <dt>
              <xsl:value-of select="concat(i18n:translate(concat('editor.label.lifeData.',@type)), ':')" />
            </dt>
            <dd>
              <ul class="list-unstyled">
                <xsl:for-each select="key('dateByType', @type)">
                  <li>
                    <xsl:variable name="displayDate">
                      <xsl:choose>
                        <xsl:when test="text()">
                          <xsl:value-of select="text()" />
                        </xsl:when>
                        <xsl:when test="@isodate">
                          <xsl:value-of select="@isodate" />
                        </xsl:when>
                        <xsl:when test="@notbefore and @notafter">
                          <xsl:value-of select="concat(@notbefore, '-', @notafter)" />
                        </xsl:when>
                        <xsl:when test="@notbefore">
                          <xsl:value-of select="concat(@notbefore, '-?')" />
                        </xsl:when>
                        <xsl:when test="@notafter">
                          <xsl:value-of select="concat('?-', @notafter)" />
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="isoDate">
                      <xsl:choose>
                        <xsl:when test="@isodate">
                          <xsl:value-of select="@isodate" />
                        </xsl:when>
                        <xsl:when test="@notbefore and @notafter">
                          <xsl:value-of select="concat(@notbefore, '-', @notafter)" />
                        </xsl:when>
                        <xsl:when test="@notbefore">
                          <xsl:value-of select="concat(@notbefore, '-?')" />
                        </xsl:when>
                        <xsl:when test="@notafter">
                          <xsl:value-of select="concat('?-', @notafter)" />
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <time>
                      <xsl:attribute name="datetime"><xsl:value-of select="$isoDate" /></xsl:attribute>
                      <xsl:attribute name="title"><xsl:value-of select="$isoDate" /></xsl:attribute>
                      <xsl:value-of select="$displayDate" />
                    </time>
                    <xsl:if test="@calendar">
                      <xsl:text> (</xsl:text>
                      <xsl:value-of select="@calendar" />
                      <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="@source">
                      <xsl:text> [</xsl:text>
                      <xsl:choose>
                        <xsl:when test="@label">
                          <a href="{$WebApplicationBaseURL}receive/{@source}"><xsl:value-of select="@label" /></a>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:call-template name="objectLink">
                            <xsl:with-param select="@source" name="obj_id" />
                          </xsl:call-template>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text>]</xsl:text>
                    </xsl:if>
                  </li>
                </xsl:for-each>
              </ul>
            </dd>
          </xsl:for-each>
        </dl>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mei:name" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:name</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label">
        <xsl:value-of select="'editor.label.name'" />
      </xsl:with-param>
      <xsl:with-param name="type">
        <xsl:value-of select="@type" />
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:value-of select="text()" />
        <xsl:if test="@nymref">
          <small> (<xsl:call-template name="objectLink"><xsl:with-param select="@nymref" name="obj_id" /></xsl:call-template>)</small>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>
