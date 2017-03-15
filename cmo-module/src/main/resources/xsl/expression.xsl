<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_expression_')]">

    <div class="row">

      <xsl:call-template name="objectActions">
        <xsl:with-param name="id" select="@ID" />
      </xsl:call-template>

      <h1>
        <xsl:value-of select="//mei:expression/mei:identifier" />
      </h1>

      <xsl:if test="structure/parents/parent">
        <h2>
          Back to top expression
          <xsl:call-template name="objectLink">
            <xsl:with-param select="structure/parents/parent/@xlink:href" name="obj_id" />
          </xsl:call-template>
        </h2>
      </xsl:if>

      <table class="table">
        <tr>
          <th>
            <xsl:value-of select="i18n:translate('docdetails.ID')" />
          </th>
          <td>
            <a href="http://quellen-perspectivia.net/en/cmo/{//mei:expression/@xml:id}"><xsl:value-of select="//mei:expression/@xml:id" /></a>
          </td>
        </tr>

        <xsl:if test="//mei:composer/mei:persName">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.composer')" />
            </th>
            <td>
              <xsl:for-each select="//mei:composer/mei:persName">
                <xsl:value-of select="." />
                <br />
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>

        <!--  Makam:   Râst  Râst
              Usul:
              Tempo:  -->

        <xsl:if test="//mei:incip/mei:incipText">
          <tr>
            <th>
              <xsl:value-of disable-output-escaping="yes" select="i18n:translate('editor.label.incipText')" />
            </th>
            <td>
              <xsl:text>„</xsl:text>
              <xsl:value-of select="//mei:incip/mei:incipText" />
              <xsl:text>“</xsl:text>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//mei:langUsage/mei:language">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.language')" />
            </th>
            <td>
              <xsl:value-of select="//mei:langUsage/mei:language" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//mei:relationList/mei:relation">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.relatedSources')" />
            </th>
            <td>
              <xsl:for-each select="//mei:relationList/mei:relation">
                <xsl:call-template name="objectLink">
                  <xsl:with-param select="./@target" name="obj_id" />
                </xsl:call-template>
                <br />
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>

        <xsl:call-template name="listClassifications" />

        <xsl:if test="structure/children/child">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.contents')" />
            </th>
            <td>
              <ul>
                <xsl:for-each select="structure/children/child">
                  <xsl:sort select="@xlink:title" />
                  <li>
                    <xsl:call-template name="objectLink">
                      <xsl:with-param select="./@xlink:href" name="obj_id" />
                    </xsl:call-template>
                  </li>
                </xsl:for-each>
              </ul>
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


  <!--Template for generated link names and result titles: see mycoreobject.xsl, results.xsl, MyCoReLayout.xsl -->
  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_expression_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:expression/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
