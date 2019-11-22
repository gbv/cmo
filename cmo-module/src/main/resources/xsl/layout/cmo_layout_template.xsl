<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:calendar="xalan://java.util.GregorianCalendar"
  exclude-result-prefixes="xlink basket mcr mcrver mcrxsl i18n calendar">

  <xsl:import href="resource:xsl/layout/common-layout.xsl" />

  <xsl:output method="html" doctype-system="about:legacy-compat" indent="yes" omit-xml-declaration="yes" media-type="text/html"
    version="5" />
  <xsl:strip-space elements="*" />

  <!-- Various versions -->
  <xsl:variable name="bootstrap.version" select="'4.3.1'" />
  <xsl:variable name="fontawesome.version" select="'5.10.1'" />
  <xsl:variable name="jquery.version" select="'3.1.1'" />
  <xsl:variable name="jquery.migrate.version" select="'1.4.1'" />
  <xsl:variable name="chosen.version" select="'1.8.3'" />
  <xsl:variable name="datetimepicker.version" select="'1.7.1'" />
  <xsl:variable name="jquery.table.sort.version" select="'2.25.4'" />

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

        <link href="{$WebApplicationBaseURL}webjars/font-awesome/{$fontawesome.version}/css/all.min.css" rel="stylesheet" />

        <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,700&amp;subset=latin-ext" rel="stylesheet" />
        <link href="{$WebApplicationBaseURL}css/file.css" rel="stylesheet" />

        <link href="{$WebApplicationBaseURL}rsc/sass/scss/bootstrap-cmo.css" rel="stylesheet" />
        <link href="{$WebApplicationBaseURL}webjars/tablesorter/{$jquery.table.sort.version}/css/theme.default.css" rel="stylesheet" />
        <link href="{$WebApplicationBaseURL}webjars/chosen-js/{$chosen.version}/chosen.min.css" rel="stylesheet" />

        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/jquery/{$jquery.version}/jquery.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/jquery-migrate/{$jquery.migrate.version}/jquery-migrate.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/chosen-js/{$chosen.version}/chosen.jquery.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/tablesorter/{$jquery.table.sort.version}/js/jquery.tablesorter.js" async="true"></script>
        <script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-api.js"></script>
        <script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-gui.js"></script>
        <script src="{$WebApplicationBaseURL}js/cmo.bundle.js"></script>
        <link rel="stylesheet" type="text/css" href="{$WebApplicationBaseURL}modules/webtools/upload/css/upload-gui.css" />

        <script>
          window["mycoreUploadSettings"] = {
            webAppBaseURL:"<xsl:value-of select='$WebApplicationBaseURL' />"
          };
          window["mcrBaseURL" ] = '<xsl:value-of select="$WebApplicationBaseURL" />';
          window["webApplicationBaseURL" ] = '<xsl:value-of select="$WebApplicationBaseURL" />';
          window["mcrLanguage" ] = '<xsl:value-of select="$CurrentLang" />';
        </script>
        <xsl:copy-of select="head/*" />
      </head>

      <body>

        <header>
            <div class="container-fluid">
                <div class="row">
                    <div id="logo"
                         class="col-12 col-lg-3 col-xl-2 text-center">
                        <a href="{$WebApplicationBaseURL}">
                            <img src="{$WebApplicationBaseURL}content/images/cmo_logo.jpg" alt="CMO" />
                            <span id="slogan">Corpus Musicae Ottomanicae</span>
                        </a>
                    </div>
                    <div id="suche"
                         class="col-12 col-lg-9 col-xl-10">
                        <div class="row">
                            <div id="e_suche"
                                 class="col-12 col-sm-6 col-md-8 col-lg-8">
                                e-suche
                            </div>
                            <div id="k_suche"
                                 class="col-12 col-sm-6 col-md-4 col-lg-4">
                                k-suche
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <section>
          <xsl:call-template name="print.statusMessage" />
          <div class="container-fluid">
                <div class="row">
                    <div id="side_menu_1"
                         class="col-12 col-md-3 col-xl-2 text-center">
                         <div class="fullheightbox">
                            <nav class="collapse show navbar-collapse main-nav-entries">
                              <ul class="nav navbar-nav">
                                <li class="nav-item" id="cmo_home"><a href="{$WebApplicationBaseURL}content/index.xml"><xsl:value-of select="i18n:translate('cmo.frontpage')" /></a></li>
                                <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_edition']" />
                                <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_catalogue']" />
                                <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_publish']" />
                                <li id="cmo_basket">
                                  <a href="#action=basket">
                                    <sup id="basked_badge">0</sup>
                                    <xsl:value-of select="i18n:translate('cmo.basket')" />
                                  </a>
                                </li>
                              </ul>
                            </nav>
                         </div>
                    </div>
                    <div id="content" class="col-12 col-md-9 col-xl-10">
                        <div class="row">
                          <div class="col-12">
                            <nav id="cmo_side-menu"> <!-- display: block -->
                              <ul class="nav navbar-nav float-right">
                                <xsl:call-template name="languageMenu" />
                                <xsl:call-template name="loginMenu" />
                              </ul>
                            </nav>
                          </div>
                        </div>
                        <div class="row">
                            <div id="main">
                              <xsl:attribute name="class">
                                <xsl:choose>
                                  <xsl:when test="contains($RequestURL, '/editor/')"><xsl:text>col-12</xsl:text></xsl:when>
                                  <xsl:otherwise><xsl:text>col-12 col-lg-9 order-2 order-lg-1</xsl:text></xsl:otherwise>
                                </xsl:choose>
                              </xsl:attribute>
                              <div class="row">
                                <div>
                                  <xsl:attribute name="class">
                                    <xsl:choose>
                                      <xsl:when test="contains($RequestURL, '/editor/')"><xsl:text>col-12</xsl:text></xsl:when>
                                      <xsl:otherwise><xsl:text>offset-lg-1 col-lg-11 col-12</xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                  </xsl:attribute>
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
                            <xsl:choose>
                              <xsl:when test="not (contains($RequestURL, '/editor/'))">
                                <div id="sidebar"
                                   class="col-12 col-lg-3 order-1 order-lg-2">
                                  <!-- TODO: add sidebar content -->
                                  &#160;
                                </div>
                              </xsl:when>
                              <!-- hide div complete -->
                              <xsl:otherwise>
                                <div id="sidebar"
                                   class="d-none">
                                  <!-- TODO: add sidebar content -->
                                  &#160;
                                </div>
                              </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <footer>
            <div id="subnav" class="container-fluid">
                <div class="row">

                    <div id="side_menu_2"
                         class="col-12 col-md-3 col-lg-2">
                      <nav>
                        <ul class="nav">
                          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_help']/*" />
                        </ul>
                      </nav>
                    </div>

                    <div id="bottom_menu"
                         class="col-12 col-md-9 col-lg-10">
                       <div class="row">
                         <div class="logo-box col-12 col-sm-6 col-md-4 col-xl-2">
                           <a href="https://www.oiist.org/">
                             <img src="{$WebApplicationBaseURL}content/images/logos/orient_institut_istanbul.svg" title="Link to Orient Institute Istanbul" alt="Logo Orient Institute Istanbul" id="logo_oi" class="img-fluid"/>
                           </a>
                         </div>
                         <div class="logo-box col-12 col-sm-6 col-md-4 col-xl-2">
                           <a href="https://www.uni-muenster.de/ArabistikIslam/">
                             <img src="{$WebApplicationBaseURL}content/images/logos/institut_arabistik.svg" title="Link to Institute for Arabistik and Islam" alt="Logo Institute for Arabistik and Islam" id="logo_arab" class="img-fluid"/>
                           </a>
                         </div>
                         <div class="logo-box col-12 col-sm-6 col-md-4 col-xl-2">
                           <a href="https://www.uni-muenster.de/Musikwissenschaft/">
                             <img src="{$WebApplicationBaseURL}content/images/logos/muwi_muenster.png" title="Link to Musikwissenschaft Münster" alt="Logo Musikwissenschaft Münster" class="img-fluid"/>
                           </a>
                         </div>
                         <div class="logo-box col-12 col-sm-6 col-md-4 col-xl-2">
                           <a href="http://www.perspectivia.net/">
                             <img src="{$WebApplicationBaseURL}content/images/logos/perspectivia.png" title="Link to perspectivia.net" alt="Logo perspectivia.net" class="img-fluid"/>
                           </a>
                         </div>
                         <div class="logo-box col-12 col-sm-6 col-md-4 col-xl-2">
                           <a href="http://dfg.de/">
                             <span id="dfg_founded">gefördert durch:</span>
                             <img src="{$WebApplicationBaseURL}content/images/logos/dfg.svg" title="Link to DFG" alt="DFG logo" id="logo_dfg" class="img-fluid"/>
                           </a>
                         </div>
                         <div class="logo-box col-12 col-sm-6 col-md-4 col-xl-2">
                           <a href="https://www.gbv.de/">
                             <img src="{$WebApplicationBaseURL}content/images/logos/vzg.png" title="Link to VZG" alt="VZG logo" id="logo_vzg" class="img-fluid"/>
                           </a>
                         </div>
                       </div>
                    </div>
                </div>
            </div>
            <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
            <xsl:variable name="copyrightDate" select="calendar:new()"/>
            <div id="powered">
                <div class="container-fluid">
                    <div class="row">
                      <div id="nav_below" class="col-12 text-center">
                        <ul>
                          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='cmo_below']/*" />
                        </ul>
                      </div>
                    </div>
                    <div class="row">
                        <div id="copyright" class="col-12 col-sm-7 col-md-5 col-lg-4">
                            © <xsl:value-of select="calendar:get($copyrightDate, 1)"/> Corpus Musicae Ottomanicae (CMO)
                        </div>
                        <div id="logo" class="d-none d-md-block col-md-2 col-lg-4 text-center">
                            <a href="http://www.mycore.de/">
                                <img src="{$WebApplicationBaseURL}content/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
                            </a>
                        </div>
                        <div id="contact" class="col-12 col-sm-5 col-md-5 col-lg-4 text-right">
                            <a href="mailto:cmo@uni-muenster.de">cmo@uni-muenster.de</a>
                        </div>
                        <div id="logo"
                             class="col-12 col-sm-12 d-md-none d-lg-none">
                            <a href="http://www.mycore.de/">
                                <img src="{$WebApplicationBaseURL}content/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </footer>

        <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/bootstrap/{$bootstrap.version}/js/bootstrap.bundle.min.js"></script>
       </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
