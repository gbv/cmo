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

      <header>
         <h1>
           <xsl:choose>
             <xsl:when test="//meiContainer/tei:bibl/tei:title[@type='main']">
               <xsl:value-of select="//meiContainer/tei:bibl/tei:title[@type='main']" />
               <xsl:if test="//meiContainer/tei:bibl/tei:title[@type='main']/@xml:lang">
                 <small> (<xsl:value-of select="//meiContainer/tei:bibl/tei:title[@type='main']/@xml:lang" />)</small>
               </xsl:if>
             </xsl:when>
             <xsl:otherwise>
               <xsl:value-of select="//meiContainer/tei:bibl/tei:title[not(@type)]" />
             </xsl:otherwise>
           </xsl:choose>
         </h1>
         <xsl:if test="//meiContainer/tei:bibl/tei:title[@type='sub']">
           <p>
             <xsl:value-of select="//meiContainer/tei:bibl/tei:title[@type='sub']" />
             <xsl:if test="//meiContainer/tei:bibl/tei:title[@type='sub']/@xml:lang">
               <small> (<xsl:value-of select="//meiContainer/tei:bibl/tei:title[@type='sub']/@xml:lang" />)</small>
             </xsl:if>
           </p>
         </xsl:if>
      </header>

      <table class="table">
        <tr>
          <th class="col-xs-3">
            <xsl:value-of select="i18n:translate('docdetails.ID')" />
          </th>
          <td class="col-xs-9">
            <a href="http://quellen-perspectivia.net/en/cmo/{//meiContainer/tei:bibl/@xml:id}"><xsl:value-of select="//meiContainer/tei:bibl/@xml:id" /></a>
          </td>
        </tr>

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
