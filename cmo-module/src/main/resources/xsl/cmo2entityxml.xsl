<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="https://sub.uni-goettingen.de/met/standards/entity-xml#"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:dcterms="http://purl.org/dc/terms/" 
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:gndo="https://d-nb.info/standards/elementset/gnd#" 
    xmlns:owl="http://www.w3.org/2002/07/owl#" 
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
    xmlns:geo="http://www.opengis.net/ont/geosparql#" 
    xmlns:dnb="https://www.dnb.de" 
    xmlns:wgs84="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:dicu="http://digicult.vocnet.org/terminology/"
    xmlns:sch="https://schema.org/"
    xmlns:mei="http://www.music-encoding.org/ns/mei" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0" 
    xpath-default-namespace="https://sub.uni-goettingen.de/met/standards/entity-xml#">
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:template match="/">
        <entityXML xmlns="https://sub.uni-goettingen.de/met/standards/entity-xml#"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:dcterms="http://purl.org/dc/terms/"
            xmlns:foaf="http://xmlns.com/foaf/0.1/"
            xmlns:gndo="https://d-nb.info/standards/elementset/gnd#"
            xmlns:owl="http://www.w3.org/2002/07/owl#"
            xmlns:skos="http://www.w3.org/2004/02/skos/core#"
            xmlns:geo="http://www.opengis.net/ont/geosparql#"
            xmlns:dnb="https://www.dnb.de"
            xmlns:wgs84="http://www.w3.org/2003/01/geo/wgs84_pos#"
            xmlns:lido="http://www.lido-schema.org"
            xmlns:dicu="http://digicult.vocnet.org/terminology/"
            xmlns:sch="https://schema.org/">
            <collection>
                <metadata>
                    <title>CMO Personendaten</title>
                    <abstract>Datenlieferung von CMO an die Text+ GND-Agentur. Es handelt sich um 560 Personendatensätze.</abstract>
                    <provider id="cmo">
                        <title>CMO</title>
                        <abstract>...</abstract>
                        <respStmt id="NRP">
                            <resp>Mitarbeiterin</resp>
                            <name>Nanette Rißler-Pipka</name>
                            <contact>
                                <mail>Rissler-Pipka@MaxWeberStiftung.de</mail>
                            </contact>
                        </respStmt>
                        <respStmt id="SG">
                            <resp>Mitarbeiter</resp>
                            <name>Sven Gronemeyer</name>
                            <contact>
                                <mail>Gronemeyer@MaxWeberStiftung.de</mail>
                            </contact>
                        </respStmt>
                        <respStmt id="KN">
                            <resp>Datenabzug</resp>
                            <name>Kathleen Neumann</name>
                            <contact>
                                <mail>Kathleen.Neumann@gbv.de</mail>
                            </contact>
                        </respStmt>
                    </provider>
                    <agency isil="DE-000">
                        <respStmt id="US">
                            <resp>entityXML Konvertierung</resp>
                            <name>Uwe Sikora</name>
                            <contact>
                                <mail>sikora@sub.uni-goettingen.de</mail>
                            </contact>
                        </respStmt>
                    </agency>
                    
                    <revision status="opened">
                        <change when="2023-10-06" who="US">entityXML Datenlieferung erzeugt.</change>
                    </revision>
                </metadata>
                <data>
                    <list>
                        <xsl:apply-templates select=".//mei:persName"/>
                    </list>
                    </data>
            </collection>
        </entityXML>
    </xsl:template>    
    
    <xsl:template match="mei:persName">
        <person xmlns="https://sub.uni-goettingen.de/met/standards/entity-xml#" xml:id="{/*[namespace-uri()='' and local-name()='mycoreobject']/@ID}">
            <!-- 1. Create GND-Identifier if there is any -->
            <xsl:if test="mei:identifier[@type='GND']">
                <xsl:attribute name="gndo:uri">
                    <xsl:text>http://d-nb.info/gnd/</xsl:text><xsl:value-of select="mei:identifier[@type='GND']"/>
                </xsl:attribute>
            </xsl:if>
            <!-- 2. Create Geographic Area Code -->
            <gndo:geographicAreaCode gndo:term="https://d-nb.info/standards/vocab/gnd/geographic-area-code#XV"/>
            <!-- 3. Create Names -->
            <xsl:call-template name="names"/>
            <!-- 4. Create Dates -->
            <xsl:call-template name="dates"/>
            <!-- 5. Create Annotations -->
            <xsl:call-template name="annotations"/>
            <revision status="opened">
                <change when="2023-10-06" who="US">Datensatz abgezogen und in entityXML konvertiert.</change>
                <xsl:call-template name="change-date">
                    <xsl:with-param name="date" select="//*[namespace-uri()='' and local-name()='servdate'][@type='createdate']" />
                </xsl:call-template>
            </revision>
        </person>
    </xsl:template>
    
    <xsl:template match="mei:identifier"/>
    
    <xsl:template name="change-date">
        <xsl:param name="date" />
        <change xmlns="https://sub.uni-goettingen.de/met/standards/entity-xml#" when="{substring-before($date, 'T')}" who="KN">Datensatz angelegt</change>
    </xsl:template>
    
    
    <!-- NAMES -->
    <xsl:template name="names">
        <xsl:apply-templates select="mei:name"/>
    </xsl:template>
    
    <xsl:template match="mei:name[@type = 'TMAS-other']"/>
    
    <xsl:template match="mei:name">
        <xsl:choose>
            <xsl:when test="@type = 'TMAS-main'">
                <gndo:preferredName>
                    <xsl:apply-templates/>
                    <xsl:call-template name="name-additions"/>
                </gndo:preferredName>
            </xsl:when>
            <xsl:when test="@type = 'CMO' and not(preceding-sibling::mei:name[@type='TMAS-main'] or following-sibling::mei:name[@type='TMAS-main'])">
                <gndo:preferredName>
                    <xsl:apply-templates/>
                    <xsl:call-template name="name-additions"/>
                </gndo:preferredName>
            </xsl:when>
            <xsl:otherwise>
                <gndo:variantName>
                    <xsl:apply-templates/>
                </gndo:variantName>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:name/text()">
        <xsl:variable name="tokens" select="tokenize(., ',')"/>
        <xsl:choose>
            <xsl:when test="count($tokens) = 2">
                <gndo:surname>
                    <xsl:value-of select="normalize-space($tokens[1])"/>
                </gndo:surname>, <gndo:forename>
                    <xsl:value-of select="normalize-space($tokens[2])"/>
                </gndo:forename>
            </xsl:when>
            <xsl:otherwise>
                <gndo:personalName><xsl:value-of select="."/></gndo:personalName>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="name-additions">
        <xsl:variable name="tmas-other" select="(./preceding-sibling::mei:name[@type = 'TMAS-other'], ./following-sibling::mei:name[@type = 'TMAS-other'])"/>
        <xsl:if test="count($tmas-other) > 0">
            <xsl:for-each select="tokenize($tmas-other[1]/text(), ',')">
                <gndo:epithetGenericNameTitleOrTerritory>
                    <xsl:value-of select="normalize-space(.)"/>
                </gndo:epithetGenericNameTitleOrTerritory>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    
    <!-- DATES -->
    <xsl:template name="dates">
        <xsl:variable name="gregorian-dates" select="mei:date[@calendar='gregorian']"/>
        <xsl:variable name="birth" select="$gregorian-dates[@type='birth']"/>
        <xsl:variable name="death" select="$gregorian-dates[@type='death']"/>
        
        <xsl:apply-templates select="$birth"></xsl:apply-templates>
        <xsl:apply-templates select="$death"></xsl:apply-templates>
        <!--<xsl:choose>
            <xsl:when test="$birth[@isodate]">
                <xsl:apply-templates select="$birth[@isodate][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$birth[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:choose>
            <xsl:when test="$death[@isodate]">
                <xsl:apply-templates select="$death[@isodate][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$death[1]"/>
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>
    
    <xsl:template match="mei:date[@isodate][@type=('birth','death')]">
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="@type='birth'">dateOfBirth</xsl:when>
                <xsl:when test="@type='death'">dateOfDeath</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="gndo:{$name}" namespace="https://d-nb.info/standards/elementset/gnd#">
            <!--<xsl:attribute name="cmo:source" select="@source"/>
            <xsl:attribute name="cmo:label" select="@label"/>-->
            <xsl:attribute name="iso-date" select="@isodate"/>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
        <xsl:if test="@source">
            <source>
                <xsl:text>source: </xsl:text><xsl:value-of select="data(@source)"/>
                <xsl:text>;label: </xsl:text><xsl:value-of select="data(@label)"/>
            </source>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mei:date[not(@isodate)][@type=('birth','death')]">
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="@type='birth'">dateOfBirth</xsl:when>
                <xsl:when test="@type='death'">dateOfDeath</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="gndo:{$name}" namespace="https://d-nb.info/standards/elementset/gnd#">
            <!--<xsl:attribute name="cmo:source" select="@source"/>
            <xsl:attribute name="cmo:label" select="@label"/>-->
            <xsl:if test="@notbefore">
                <xsl:attribute name="iso-notBefore" select="@notbefore"/>
            </xsl:if>
            <xsl:if test="@notafter">
                <xsl:attribute name="iso-notAfter" select="@notafter"/>
            </xsl:if>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
        <xsl:if test="@source">
            <source>
                <xsl:text>source: </xsl:text><xsl:value-of select="data(@source)"/>
                <xsl:text>;label: </xsl:text><xsl:value-of select="data(@label)"/>
            </source>
        </xsl:if>
        
    </xsl:template>
    
    <!--<xsl:template match="mei:date[@type='birth']">
        <gndo:dateOfBirth>
            <xsl:choose>
                <xsl:when test="@isodate">
                    <xsl:attribute name="iso-date" select="@isodate"/>
                </xsl:when>
                <xsl:when test="@notbefore">
                    <xsl:attribute name="iso-date" select="@notbefore"/>
                </xsl:when>
                <xsl:when test="@notafter">
                    <xsl:attribute name="iso-date" select="@notafter"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="text()"/>
        </gndo:dateOfBirth>
    </xsl:template>
   
    
    <xsl:template match="mei:date[@type='death']">
        <gndo:dateOfDeath iso-date="{@isodate}">
            <xsl:choose>
                <xsl:when test="@isodate">
                    <xsl:attribute name="iso-date" select="@isodate"/>
                </xsl:when>
                <xsl:when test="@notafter">
                    <xsl:attribute name="iso-date" select="@notafter"/>
                </xsl:when>
                <xsl:when test="@notbefore">
                    <xsl:attribute name="iso-date" select="@notbefore"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="text()"/>
        </gndo:dateOfDeath>
    </xsl:template>-->
    
    
    <!-- ANNOTATIONS -->
    <xsl:template name="annotations">
        <xsl:apply-templates select="mei:annot"/>
    </xsl:template>
    
    <xsl:template match="mei:annot">
        <skos:note xml:lang="en"><xsl:value-of select="."/></skos:note>
    </xsl:template>
    
    
    <!-- DEFAULT Template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>