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
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xalan xlink acl i18n mods" version="1.0">


  <xsl:template match="mods:identifier[@type='CMO']" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.identifier.CMO'" />
      <xsl:with-param name="content">
        <xsl:value-of select="." />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:mods" mode="metadataViewName">
    <!-- grouped for every role -->
    <xsl:for-each select="mods:name[not(@ID) and @type='personal' and
                         count(. | key('name-by-role',mods:role/mods:roleTerm)[1])=1]">
      <xsl:choose>
        <!-- check if role term is given -->
        <xsl:when test="not(mods:role/mods:roleTerm)">
          <!-- do nothing -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="personLabel">
            <xsl:choose>
              <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']">
                <xsl:apply-templates select="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']"
                                     mode="printModsClassInfo" />
                <xsl:value-of select="':'" />
              </xsl:when>
              <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator']">
                <xsl:value-of
                  select="concat(i18n:translate(concat('component.mods.metaData.dictionary.',mods:role/mods:roleTerm[@authority='marcrelator'])),':')" />
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
            
          <xsl:call-template name="metadataTextContent">
            <xsl:with-param name="text" select="$personLabel" />
            <xsl:with-param name="content">
              <xsl:for-each select="key('name-by-role',mods:role/mods:roleTerm)">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="'; '" />
                </xsl:if>
                <xsl:apply-templates select="." mode="nameLink" />
              </xsl:for-each>
              <xsl:if test="mods:etal">
                <em>et.al.</em>
              </xsl:if>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:genre" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.mods.genre'" />
      <xsl:with-param name="content">
        <xsl:variable name="modsType">
          <xsl:apply-templates select="//mods:mods" mode="mods.type" />
        </xsl:variable>
        <xsl:value-of select="document(concat('classification:metadata:0:children:cmo_genres:', $modsType))//category/label[@xml:lang=$CurrentLang]/@text"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:originInfo[@eventType='publication']/mods:publisher" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.publisher'" />
      <xsl:with-param name="content">
        <xsl:value-of select="." />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:originInfo[@eventType='publication']/mods:dateIssued" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.publishingDate'" />
      <xsl:with-param name="content">
        <xsl:value-of select="." />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:originInfo[@eventType='publication']/mods:place/mods:placeTerm" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.pubPlace'" />
      <xsl:with-param name="content">
        <xsl:value-of select="." />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:physicalDescription/mods:extent" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.extent'" />
      <xsl:with-param name="content">
        <xsl:value-of select="." />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:note" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.note'" />
      <xsl:with-param name="content">
        <xsl:value-of select="." />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.host'" />
      <xsl:with-param name="content">
        <xsl:choose>
          <xsl:when test="@xlink:href">
            <xsl:call-template name="objectLink">
              <xsl:with-param select="@xlink:href" name="obj_id" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:titleInfo/mods:title" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="mods:part/mods:extent[@unit='pages']">
          <xsl:value-of select="concat(', ',i18n:translate('cmo.pages.abbreviated.multiple'), ' ', mods:part/mods:extent[@unit='pages']/mods:start, ' - ', mods:part/mods:extent[@unit='pages']/mods:end )" />
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='series']" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.legend.series'" />
      <xsl:with-param name="content">
        <xsl:value-of select="mods:titleInfo/mods:title" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='original']" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.originalLink'" />
      <xsl:with-param name="content">
        <xsl:call-template name="objectLink">
          <xsl:with-param select="@xlink:href" name="obj_id" />
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>