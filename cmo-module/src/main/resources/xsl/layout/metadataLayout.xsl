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

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="xalan xlink acl i18n mei exslt">


  <xsl:template name="metadataLabelContent">
    <xsl:param name="label" />
    <xsl:param name="content" />
    <tr>
      <th>
        <xsl:value-of select="i18n:translate($label)" />
      </th>
      <td>
        <xsl:variable name="rTree" select="exslt:node-set($content)" />
        <xsl:copy-of select="$rTree" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="metadataTextContent">
    <xsl:param name="text" />
    <xsl:param name="content" />
    <tr>
      <th>
        <xsl:value-of select="$text" />
      </th>
      <td>
        <xsl:variable name="rTree" select="exslt:node-set($content)" />
        <xsl:copy-of select="$rTree" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="metadataContentContent">
    <xsl:param name="content1" />
    <xsl:param name="content2" />
    <tr>
      <th>
        <xsl:variable name="rTree1" select="exslt:node-set($content1)" />
        <xsl:copy-of select="$rTree1" />
      </th>
      <td>
        <xsl:variable name="rTree2" select="exslt:node-set($content2)" />
        <xsl:copy-of select="$rTree2" />
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="metadataContainer">
    <xsl:param name="content" />
    <table class="table">
      <xsl:variable name="rTree" select="exslt:node-set($content)" />
      <xsl:copy-of select="$rTree" />
    </table>
  </xsl:template>

  <xsl:template name="metadataSection">
    <xsl:param name="content" />
    <div class="row">
      <xsl:variable name="rTree" select="exslt:node-set($content)" />
      <xsl:copy-of select="$rTree" />
    </div>
  </xsl:template>

  <xsl:template name="derivateSection">
    <xsl:param name="content" />
    <div class="row">
      <xsl:variable name="rTree" select="exslt:node-set($content)" />
      <xsl:copy-of select="$rTree" />
    </div>
  </xsl:template>

  <xsl:template name="metadataPage">
    <xsl:param name="content" />
    <xsl:variable name="rTree" select="exslt:node-set($content)" />
    <xsl:copy-of select="$rTree" />
  </xsl:template>

  <!-- how a metadata page is build
  <metadataPage>
    <metadataSection>
      <title_and_other_stuff />
      <metadataContainer>
        <metadataLabelContent />
        <metadataTextContent />
        <metadataLabelContent />
        <metadataTextContent />
        <metadataLabelContent />
      </metadataContainer>
    </metadataSection>
    <derivateSection>
    </derivateSection>
  </metadataPage>
  -->

  <xsl:template match="parent" mode="metadataView">
    <xsl:param name="type" select="'object'" />
    <h2>
      Back to top <xsl:value-of select="$type" />
      <xsl:call-template name="objectLink">
        <xsl:with-param select="@xlink:href" name="obj_id" />
      </xsl:call-template>
    </h2>
  </xsl:template>

  <xsl:template match="children" mode="metadataView">
    <xsl:if test="child">
      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="label" select="'editor.label.contents'" />
        <xsl:with-param name="content">
          <ul>
            <xsl:for-each select="child">
              <xsl:sort select="@xlink:title" />
              <li>
                <xsl:call-template name="objectLink">
                  <xsl:with-param select="./@xlink:href" name="obj_id" />
                </xsl:call-template>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="displayIdWithOldLink">
    <xsl:param name="id" />
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'docdetails.ID'" />
      <xsl:with-param name="content">
        <a href="http://quellen-perspectivia.net/en/cmo/{$id}">
          <xsl:value-of select="$id" />
        </a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="displayDerivateSection">
    <xsl:if test="structure/derobjects/derobject[acl:checkPermission(@xlink:href,'read')]">
      <xsl:call-template name="derivateSection">
        <xsl:with-param name="content">
          <xsl:apply-templates select="structure/derobjects/derobject[acl:checkPermission(@xlink:href,'read')]">
            <xsl:with-param name="objID" select="@ID" />
          </xsl:apply-templates>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>