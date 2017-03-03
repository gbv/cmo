<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xalan xlink acl i18n tei" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_bibl_')]">

    <div class="row">

      <xsl:call-template name="objectActions">
        <xsl:with-param name="id" select="@ID" />
      </xsl:call-template>

      <h1>
        <xsl:value-of select="//tei:bibl/tei:title" />
      </h1>

      <table class="table">
        <tr>
          <th>
            <xsl:value-of select="i18n:translate('docdetails.ID')" />
          </th>
          <td>
            <a href="http://quellen-perspectivia.net/en/cmo/{//tei:bibl/@xml:id}"><xsl:value-of select="//tei:bibl/@xml:id" /></a>
          </td>
        </tr>

        <xsl:if test="//tei:bibl/tei:idno">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.idno')" />
            </th>
            <td>
              <xsl:value-of select="//tei:bibl/tei:idno" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//tei:bibl/tei:author">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.author')" />
            </th>
            <td>
              <xsl:value-of select="//tei:bibl/tei:author" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//tei:bibl/tei:publisher">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.publisher')" />
            </th>
            <td>
              <xsl:value-of select="//tei:bibl/tei:publisher" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//tei:bibl/tei:pubPlace">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.pubPlace')" />
            </th>
            <td>
              <xsl:value-of select="//tei:bibl/tei:pubPlace" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//tei:bibl/tei:date">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.date')" />
            </th>
            <td>
              <xsl:value-of select="//tei:bibl/tei:date" />
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

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_bibl_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/tei:bibl/tei:title" />
  </xsl:template>

</xsl:stylesheet>
