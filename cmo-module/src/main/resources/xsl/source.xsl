<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:template match="/mycoreobject[contains(@ID,'_source_')]">

    <div class="row">

      <xsl:call-template name="objectActions">
        <xsl:with-param name="id" select="@ID" />
      </xsl:call-template>

      <h1>
        <xsl:value-of select="//mei:source/mei:identifier" />
      </h1>

      <xsl:if test="structure/parents/parent">
        <h2>
          Back to top Source
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
            <a href="http://quellen-perspectivia.net/en/cmo/{//mei:source/@xml:id}"><xsl:value-of select="//mei:source/@xml:id" /></a>
          </td>
        </tr>

        <xsl:if test="//mei:titleStmt/mei:title[@type='main']">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.title')" />
            </th>
            <td>
              <xsl:value-of select="//mei:titleStmt/mei:title[@type='main']" />
              <br />
              <xsl:value-of select="//mei:titleStmt/mei:title[@type='sub']" />
              <br />
              <xsl:value-of select="//mei:titleStmt/mei:title[@type='desc']" />
              <br />
              <xsl:value-of select="//mei:titleStmt/mei:author" />
              <br />
              <xsl:value-of select="//mei:titleStmt/mei:editor" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//mei:langUsage/mei:language">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.language')" />
            </th>
            <td>
              <ul>
                <xsl:for-each select="//mei:langUsage/mei:language">
                  <li><xsl:value-of select="." /></li>
                </xsl:for-each>
              </ul>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//mei:notesStmt/mei:annot">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.annot')" />
            </th>
            <td>
              <ul>
                <xsl:for-each select="//mei:notesStmt/mei:annot">
                  <li><xsl:value-of select="." /></li>
                </xsl:for-each>
              </ul>
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

  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_source_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/mei:source/mei:identifier" />
  </xsl:template>

</xsl:stylesheet>
