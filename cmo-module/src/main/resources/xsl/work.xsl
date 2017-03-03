<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_work_')]">

    <div class="row">

      <xsl:call-template name="objectActions">
        <xsl:with-param name="id" select="@ID" />
      </xsl:call-template>

      <h1>
        <xsl:value-of select="//mei:work/mei:identifier" />
      </h1>

      <table class="table">
        <tr>
          <th>
            <xsl:value-of select="i18n:translate('docdetails.ID')" />
          </th>
          <td>
            <a href="http://quellen-perspectivia.net/en/cmo/{//mei:work/@xml:id}"><xsl:value-of select="//mei:work/@xml:id" /></a>
          </td>
        </tr>

        <xsl:if test="//mei:work/mei:biblList/mei:bibl">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.biblList')" />
            </th>
            <td>
              <xsl:for-each select="//mei:work/mei:biblList/mei:bibl">
                <xsl:call-template name="objectLink">
                  <xsl:with-param select="./@target" name="obj_id" />
                </xsl:call-template>
                <br />
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//mei:bibl/mei:pubPlace">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.pubPlace')" />
            </th>
            <td>
              <xsl:value-of select="//mei:bibl/mei:pubPlace" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//mei:bibl/mei:date">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.date')" />
            </th>
            <td>
              <xsl:value-of select="//mei:bibl/mei:date" />
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


  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_work_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:work/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
