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

    <xsl:call-template name="metadataPage">
      <xsl:with-param name="content">

        <xsl:apply-templates select="//meiContainer/tei:bibl/tei:idno[@type='CMO']" mode="metadataHeader" />

        <!--Show metadata -->
        <xsl:call-template name="metadataSection">
          <xsl:with-param name="content">

            <xsl:call-template name="objectActions">
              <xsl:with-param name="id" select="@ID" />
            </xsl:call-template>

            <xsl:call-template name="metadataContainer">
              <xsl:with-param name="content">
                <xsl:call-template name="displayIdWithOldLink">
                  <xsl:with-param name="id" select="//tei:bibl/@xml:id" />
                </xsl:call-template>


        <xsl:if test="//meiContainer/tei:bibl/tei:bibl[@type='in']">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.bibl.in')" />
            </th>
            <td>
              <xsl:for-each select="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:author">
                <xsl:value-of select="." />
                <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
                <xsl:if test="position() = last()"><xsl:text>. </xsl:text></xsl:if>
              </xsl:for-each>
              <xsl:if test="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:title">
                <em><xsl:value-of select="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:title" />
                <xsl:text>. </xsl:text></em>
              </xsl:if>
              <xsl:if test="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:pubPlace or
                            //meiContainer/tei:bibl/tei:bibl[@type='in']/tei:date or
                            //meiContainer/tei:bibl/tei:bibl[@type='in']/tei:biblScope or
                            //meiContainer/tei:bibl/tei:bibl[@type='in']/tei:series">
                <br />
                <xsl:if test="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:series">
                  <xsl:value-of select="concat(//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:series, ', ')" />
                </xsl:if>
                <xsl:if test="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:pubPlace">
                  <xsl:value-of select="concat(//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:pubPlace, ': ')" />
                </xsl:if>
                <xsl:if test="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:date">
                  <xsl:value-of select="concat(//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:date, '. ')" />
                </xsl:if>
                <xsl:if test="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:biblScope">
                  <xsl:value-of select="i18n:translate('cmo.biblScope')" />
                  <xsl:value-of select="//meiContainer/tei:bibl/tei:bibl[@type='in']/tei:biblScope" />
                </xsl:if>
              </xsl:if>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:idno">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.idno')" />
            </th>
            <td>
              <xsl:value-of select="//meiContainer/tei:bibl/tei:idno" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:author">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.author')" />
            </th>
            <td>
              <xsl:for-each select="//meiContainer/tei:bibl/tei:author">
                <xsl:value-of select="." />
                <xsl:if test="position() != last()">
                  <br />
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:editor">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.editor')" />
            </th>
            <td>
              <xsl:for-each select="//meiContainer/tei:bibl/tei:editor">
                <xsl:value-of select="." />
                <xsl:if test="position() != last()">
                  <br />
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:publisher">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.publisher')" />
            </th>
            <td>
              <xsl:value-of select="//meiContainer/tei:bibl/tei:publisher" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:pubPlace">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.pubPlace')" />
            </th>
            <td>
              <xsl:value-of select="//meiContainer/tei:bibl/tei:pubPlace" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:date">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.date')" />
            </th>
            <td>
              <xsl:value-of select="//meiContainer/tei:bibl/tei:date" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:extent">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.extent')" />
            </th>
            <td>
              <xsl:value-of select="//meiContainer/tei:bibl/tei:extent" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:series">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.series')" />
            </th>
            <td>
              <xsl:value-of select="//meiContainer/tei:bibl/tei:series" />
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="//meiContainer/tei:bibl/tei:note">
          <tr>
            <th>
              <xsl:value-of select="i18n:translate('editor.label.note')" />
            </th>
            <td>
              <xsl:value-of select="//meiContainer/tei:bibl/tei:note" />
            </td>
          </tr>
        </xsl:if>

              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayDerivateSection" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template priority="1" mode="resulttitle" match="mycoreobject[contains(@ID,'_bibl_')]">
    <xsl:value-of select="./metadata/def.meiContainer/meiContainer/tei:bibl/tei:title" />
  </xsl:template>

</xsl:stylesheet>
