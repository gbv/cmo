<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:export="http://www.corpus-musicae-ottomanicae.de/ns/export"
                version="3.0"
>

  <!--
    This stylesheets pulls all dependencies and inserts them to the output.

    Source Document should look like this:
    <export:export>
      <export:dependency id="cmo_source_00000051" resolved="false" />
    </export:export>

   The Result Document will look like this:
   <export:export>
     <export:dependency id="cmo_source_00000051" resolved="true">
       <mycoreobject ... >
     </export:dependency>
   </export:export>
   -->

  <xsl:mode on-no-match="shallow-skip"/>

  <xsl:template match="/export:export">
    <xsl:variable name="unresolvedDeps" select="count(export:dependency[@resolved='false'])"/>
    <xsl:choose>
      <xsl:when test="$unresolvedDeps=0">
        <!-- everything is resolved here -->
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>There are <xsl:value-of select="$unresolvedDeps"/> deps to resolve!</xsl:message>
        <xsl:variable name="oldExport" select="."/>
        <xsl:variable name="newExport">
          <xsl:copy>
            <xsl:copy-of select="$oldExport/export:dependency[@resolved='true']"/>
            <xsl:for-each-group select="$oldExport/export:dependency[@resolved='false']" group-by="@id">
              <xsl:variable name="resolverUri" select="concat('mcrobject:', fn:current-grouping-key())" />
              <export:dependency id="{current-grouping-key()}" resolved="true">
                <xsl:copy-of select="document($resolverUri)"/>
              </export:dependency>
            </xsl:for-each-group>
          </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$newExport"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- mode: resolve dependency has to generate export elements with the template addToResolve -->
  <xsl:template match="node()" >
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>