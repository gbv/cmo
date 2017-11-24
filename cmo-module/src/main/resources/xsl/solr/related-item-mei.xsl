<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:meiDate="xalan://org.mycore.mei.MCRDateHelper"
                exclude-result-prefixes="mods mei xlink">
  <xsl:import href="xslImport:solr-document:solr/related-item-mei.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:if test="mods:originInfo">
        <xsl:call-template name="printDateIssued">
          <xsl:with-param name="originInfo" select="mods:originInfo" />
        </xsl:call-template>
      </xsl:if>


      <xsl:for-each select="mods:relatedItem">
        <xsl:variable name="type" select="@type" />

        <xsl:if test="@xlink:href">
          <xsl:variable name="href" select="@xlink:href" />
          <xsl:variable name="meiDoc" select="document(concat('mcrobject:', $href))" />
          <xsl:variable name="id" select="$meiDoc/mycoreobject/@ID" />

          <field name="mods.relatedItem">
            <xsl:value-of select="$id" />
          </field>

          <field name="mods.relatedItem.{$type}">
            <xsl:value-of select="$id" />
          </field>
        </xsl:if>

        <xsl:if test="mods:originInfo">
          <xsl:call-template name="printDateIssued">
            <xsl:with-param name="fieldSuffix" select="'.host'" />
            <xsl:with-param name="originInfo" select="mods:originInfo" />
          </xsl:call-template>
        </xsl:if>

        <xsl:for-each
          select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[not(@type='code')]">
          <field name="mods.place.{$type}">
            <xsl:value-of select="." />
          </field>
        </xsl:for-each>

        <xsl:for-each
          select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
          <field name="mods.publisher.{$type}">
            <xsl:call-template name="printModsName" />
          </field>
        </xsl:for-each>

        <xsl:for-each
          select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='code' and text()='edt')]]">
          <field name="mods.editor.{$type}">
            <xsl:call-template name="printModsName" />
          </field>
        </xsl:for-each>

        <xsl:for-each
          select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='text' and text()='author') or (@type='code' and text()='aut')]]">
          <field name="mods.author.{$type}">
            <xsl:call-template name="printModsName" />
          </field>
        </xsl:for-each>

        <xsl:for-each select="mods:name">
          <field name="mods.name.{$type}">
            <xsl:call-template name="printModsName" />
          </field>
        </xsl:for-each>

        <xsl:for-each select="mods:part/mods:extent[@unit='pages']">
          <field name="mods.extent.{$type}">
            <xsl:choose>
              <xsl:when test="string-length(mods:start/text())&gt;0 and string-length(mods:end/text())&gt;0">
                <xsl:value-of select="concat(mods:start/text(), '-', mods:end/text())" />
              </xsl:when>
              <xsl:when test="string-length(mods:start/text())&gt;0">
                <xsl:value-of select="concat(mods:start/text(), '- ?')" />
              </xsl:when>
              <xsl:when test="string-length(mods:end/text())&gt;0">
                <xsl:value-of select="concat('?-',mods:end/text())" />
              </xsl:when>
              <xsl:when test="string-length(text()) &gt;0">
                <xsl:value-of select="text()" />
              </xsl:when>
            </xsl:choose>
          </field>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each
        select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[not(@type='code')]">
        <field name="mods.place.this">
          <xsl:value-of select="." />
        </field>
      </xsl:for-each>

      <xsl:for-each
        select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
        <field name="mods.publisher.this">
          <xsl:call-template name="printModsName" />
        </field>
      </xsl:for-each>

      <xsl:for-each
        select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='code' and text()='edt')]]">
        <field name="mods.editor.this">
          <xsl:call-template name="printModsName" />
        </field>
      </xsl:for-each>

      <xsl:for-each
        select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='text' and text()='author') or (@type='code' and text()='aut')]]">
        <field name="mods.author.this">
          <xsl:call-template name="printModsName" />
        </field>
      </xsl:for-each>

    </xsl:for-each>

    <xsl:for-each select="structure/parents/parent">
      <xsl:variable name="parent" select="document(concat('mcrobject:',@xlink:href))/mycoreobject" />
      <field name="parentLinkText">
        <xsl:apply-templates select="$parent" mode="resulttitle" />
      </field>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="mycoreobject" mode="resulttitle">
    <xsl:choose>
      <xsl:when test="metadata/def.meiContainer/meiContainer/mei:source/mei:identifier">
        <xsl:value-of select="metadata/def.meiContainer/meiContainer/mei:source/mei:identifier" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@ID" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <xsl:template name="printDateIssued">
    <xsl:param name="originInfo" />
    <xsl:param name="fieldSuffix" select="''" />


    <xsl:variable name="start"
                  select="$originInfo/mods:dateIssued[@point='start']" />
    <xsl:variable name="end"
                  select="$originInfo/mods:dateIssued[@point='end']" />
    <xsl:variable name="issueDateRange">
      <xsl:choose>
        <xsl:when test="$start and $end">
          <xsl:value-of select="concat('[', $start, ' TO ', $end,']')" />
        </xsl:when>
        <xsl:when test="$start">
          <xsl:value-of select="concat('[', $start, ' TO *]')" />
        </xsl:when>
        <xsl:when test="$end">
          <xsl:value-of select="concat('[* TO ', $end,']')" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($issueDateRange)&gt;0">
      <field name="{concat('mods.dateIssued',$fieldSuffix,'.range')}">
        <xsl:value-of select="$issueDateRange" />
      </field>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>
