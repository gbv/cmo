<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="xlink basket mcr mcrver mcrxsl i18n">

  <xsl:import href="resource:xsl/layout/common-layout.xsl" />

  <xsl:output method="html" doctype-system="about:legacy-compat" indent="yes" omit-xml-declaration="yes" media-type="text/html"
    version="5" />
  <xsl:strip-space elements="*" />

  <!-- Various versions -->
  <xsl:variable name="bootstrap.version" select="'3.3.7'" />
  <xsl:variable name="fontawesome.version" select="'4.7.0'" />
  <xsl:variable name="jquery.version" select="'3.1.1'" />
  <xsl:variable name="jquery.migrate.version" select="'1.4.1'" />
  <xsl:variable name="datetimepicker.version" select="'4.17.47'" />
  <!-- End of various versions -->
  <xsl:variable name="PageTitle" select="/*/@title" />

  <xsl:template match="/site">
    <html lang="{$CurrentLang}" class="no-js">
      <head>
        <meta charset="utf-8" />
        <title>
          <xsl:value-of select="$PageTitle" />
        </title>
        <xsl:comment>
          Mobile viewport optimization
        </xsl:comment>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        <link href="{$WebApplicationBaseURL}webjars/font-awesome/{$fontawesome.version}/css/font-awesome.min.css" rel="stylesheet" />
        <link href="{$WebApplicationBaseURL}webjars/eonasdan-bootstrap-datetimepicker/{$datetimepicker.version}/build/css/eonasdan-bootstrap-datetimepicker.min.css" rel="stylesheet" />

        <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet" />
        <link href="{$WebApplicationBaseURL}css/fileupload.css" rel="stylesheet" />
        <link href="{$WebApplicationBaseURL}css/file.css" rel="stylesheet" />

        <link href="{$WebApplicationBaseURL}rsc/sass/scss/bootstrap-cmo.css" rel="stylesheet" />


        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/jquery/{$jquery.version}/jquery.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/jquery-migrate/{$jquery.migrate.version}/jquery-migrate.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/systemjs/0.19.3/dist/system.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/moment/2.18.1/min/moment.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/eonasdan-bootstrap-datetimepicker/{$datetimepicker.version}/build/js/bootstrap-datetimepicker.min.js"></script>
        <script>
          window["mcrBaseURL" ]= '<xsl:value-of select="$WebApplicationBaseURL" />';

          System.config({
          baseURL: '<xsl:value-of select="concat($WebApplicationBaseURL, 'js/')" />',
          defaultJSExtensions: true
          });
          // loads /js/main.js
          System.import('search/cmo.js');
        </script>
        <xsl:copy-of select="head/*" />
      </head>

      <body>

        <header>
            <div class="container-fluid">
                <div class="row">
                    <div id="logo"
                         class="col-xs-4 col-sm-3 col-lg-2 text-center">
                        <a href="{$WebApplicationBaseURL}">
                            <img src="{$WebApplicationBaseURL}content/images/cmo_logo.jpg" alt="CMO" />
                            <span id="slogan">Corpus Musicae Ottomanicae</span>
                        </a>
                    </div>
                    <div id="suche"
                         class="col-xs-8 col-md-9 col-lg-10">
                        <div class="row">
                          <form action="{$WebApplicationBaseURL}servlets/solr/select">
                            <input type="hidden" name="fq" value="objectType:mods" />
                            <div id="e_suche"
                                 class="col-xs-6 col-md-8 col-lg-8">
                                e-suche
                            </div>
                          </form>
                          <form action="{$WebApplicationBaseURL}servlets/solr/select">
                            <input type="hidden" name="fq" value="-objectType:mods" />
                            <div id="k_suche"
                                 class="col-xs-6 col-md-4 col-lg-4">
                                k-suche
                            </div>
                          </form>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <section>
            <div class="container-fluid">
                <div class="row">
                    <div id="side_menu_1"
                         class="hidden-xs hidden-sm col-md-3 col-lg-2 text-center">
                         <div class="fullheightbox">
                            <nav class="collapse navbar-collapse main-nav-entries">
                              <ul class="nav navbar-nav">
                                <li id="cmo_home"><a href="{$WebApplicationBaseURL}content/index.xml">Startseite</a></li>
                                <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_edition']" />
                                <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_catalogue']" />
                                <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_publish']" />
                                <!-- TODO: Add Basket -->
                                <li id="cmo_basket"><a href="#">Merkliste</a></li>
                              </ul>
                            </nav>
                         </div>
                    </div>
                    <div id="content"
                         class="col-xs-12 col-md-9 col-lg-10">
                        <nav>
                          <ul class="nav navbar-nav pull-right">
                            <xsl:call-template name="loginMenu" />
                            <xsl:call-template name="languageMenu" />
                          </ul>
                        </nav>
                        <div class="row">
                            <div id="main">
                              <xsl:attribute name="class">
                                <xsl:choose>
                                  <xsl:when test="contains($RequestURL, '/editor/')"><xsl:text>col-md-11 col-lg-11</xsl:text></xsl:when>
                                  <xsl:otherwise><xsl:text>col-md-9 col-lg-9</xsl:text></xsl:otherwise>
                                </xsl:choose>
                              </xsl:attribute>
                              <div class="row">
                                <div class="col-md-10 col-md-offset-1">
                                  <xsl:call-template name="print.writeProtectionMessage" />
                                  <xsl:choose>
                                    <xsl:when test="$readAccess='true'">
                                      <xsl:copy-of select="*[not(name()='head')]" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:call-template name="printNotLoggedIn" />
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </div>
                              </div>
                            </div>
                            <xsl:if test="not (contains($RequestURL, '/editor/'))">
                              <div id="sidebar"
                                 class="hidden-xs hidden-sm col-md-3 col-lg-3">
                                <!-- TODO: add sidebar content -->
                                &#160;
                            </div>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <footer>
            <div id="subnav" class="container-fluid">
                <div class="row">
                    <div id="side_menu_2"
                         class="hidden-xs hidden-sm col-md-3 col-lg-2">
                      <nav>
                        <ul class="nav">
                          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_help']/*" />
                        </ul>
                      </nav>
                    </div>
                    <div id="bottom_menu"
                         class="col-xs-12 col-md-6 col-lg-7 text-center">
                       <ul>
                         <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_below']/*" />
                       </ul>
                    </div>
                    <div id="bottom_side"
                         class="hidden-xs hidden-sm col-md-3 col-lg-3">
                        &#160;
                    </div>
                </div>
            </div>
            <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
            <div id="powered">
                <div class="container-fluid">
                    <div class="row">
                        <div id="contact"
                             class="col-xs-12 col-sm-6 col-md-5 col-lg-4 col-lg-offset-1">
                            Tel: +49-(0)251-83241-11 • cmo@uni-muenster.de
                        </div>
                        <div id="logo"
                             class="hidden-xs hidden-sm col-md-2 col-lg-2">
                            <a href="http://www.mycore.de/">
                                <img src="{$WebApplicationBaseURL}content/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
                            </a>
                        </div>
                        <div id="copyright"
                             class="col-xs-12 col-sm-6 col-md-5 col-lg-4">
                            © 2017 Corpus Musicae Ottomanicae (CMO)
                        </div>
                        <div id="logo"
                             class="col-xs-12 col-sm-12 hidden-md hidden-lg">
                            <a href="http://www.mycore.de/">
                                <img src="{$WebApplicationBaseURL}content/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </footer>

        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/bootstrap-sass/{$bootstrap.version}/javascripts/bootstrap.min.js"></script>
       </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
