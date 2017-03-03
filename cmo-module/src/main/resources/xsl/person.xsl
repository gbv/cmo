<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_person_')]">

    <div class="row">

      <xsl:call-template name="objectActions">
        <xsl:with-param name="id" select="@ID" />
      </xsl:call-template>

      <h1>
        <xsl:value-of select="//mei:persName/mei:name" />
      </h1>

      <table class="table">
        <tr>
          <th>
            <xsl:value-of select="i18n:translate('docdetails.ID')" />
          </th>
          <td>
            <a href="http://quellen-perspectivia.net/en/cmo/{//mei:persName/@xml:id}"><xsl:value-of select="//mei:persName/@xml:id" /></a>
          </td>
        </tr>

        <xsl:if test="//mei:persName/mei:identifier">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.nameID')" />
            </th>
            <td>
              <xsl:value-of select="//mei:persName/mei:identifier" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//mei:persName/mei:date">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.lifeData')" />
            </th>
            <td>
              <dl>
                <dt><xsl:value-of select="i18n:translate('editor.label.lifeData.birth')" /></dt>
                <xsl:for-each select="//mei:persName/mei:date[@type='birth']">
                  <dd>
                    <xsl:value-of select="@isodate" />
                    <xsl:text> [ </xsl:text>
                    <a href="http://quellen-perspectivia.net/en/cmo/{@source}"><xsl:value-of select="@label" /></a>
                    <!-- xsl:call-template name="objectLink">
                      <xsl:with-param select="@source" name="obj_id" />
                    </xsl:call-template -->
                    <xsl:text> ] </xsl:text>
                  </dd>
                </xsl:for-each>
              </dl>
              <dl>
                <dt><xsl:value-of select="i18n:translate('editor.label.lifeData.death')" /></dt>
                <xsl:for-each select="//mei:persName/mei:date[@type='death']">
                  <dd>
                    <xsl:value-of select="@isodate" />
                    <xsl:text> [ </xsl:text>
                    <a href="http://quellen-perspectivia.net/en/cmo/{@source}"><xsl:value-of select="@label" /></a>
                    <!-- xsl:call-template name="objectLink">
                      <xsl:with-param select="@source" name="obj_id" />
                    </xsl:call-template -->
                    <xsl:text> ] </xsl:text>
                  </dd>
                </xsl:for-each>
              </dl>
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

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_person_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:persName/mei:identifier" />
  </xsl:template>


</xsl:stylesheet>
