<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:cmo="http://cmo.gbv.de/cmo"
  exclude-result-prefixes="xsl cmo i18n">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="cmo:textfield.nobind">
    <div class="form-group">
      <label class="col-md-3 control-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6 {@divClass}">
        <input id="{@id}" type="text" class="form-control {@inputClass}" name="">
          <xsl:copy-of select="@placeholder" />
          <xsl:copy-of select="@autocomplete" />
        </input>
      </div>
      <div class="col-md-3">
        <xsl:if test="string-length(@help-text) &gt; 0">
          <xsl:call-template name="cmo-helpbutton" />
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cmo:textfield">
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <xsl:choose>
              <xsl:when test="@bind" >
                <xed:bind xpath="{@bind}" >
                  <xsl:call-template name="cmo-textfield" />
                </xed:bind>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="cmo-textfield" />
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <xsl:call-template name="cmo-textfield" />
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:textarea">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <div class="form-group {@class} {$xed-val-marker}">
            <label class="col-md-3 control-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
            <xsl:choose>
              <xsl:when test="@bind" >
                <xed:bind xpath="{@bind}" >
                  <textarea class="form-control">
                    <xsl:copy-of select="@rows" />
                    <xsl:copy-of select="@placeholder" />
                  </textarea>
                </xed:bind>
              </xsl:when>
              <xsl:otherwise>
                <textarea class="form-control">
                  <xsl:copy-of select="@rows" />
                  <xsl:copy-of select="@placeholder" />
                </textarea>
              </xsl:otherwise>
            </xsl:choose>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="cmo-helpbutton" />
              </xsl:if>
              <xsl:call-template name="cmo-pmud" />
            </div>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <div class="form-group {@class} {$xed-val-marker}">
            <label class="col-md-3 control-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <textarea class="form-control">
                <xsl:copy-of select="@rows" />
                <xsl:copy-of select="@placeholder" />
              </textarea>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="cmo-helpbutton" />
              </xsl:if>
              <xsl:if test="@pmud = 'true'">
                <xsl:call-template name="cmo-pmud" />
              </xsl:if>
            </div>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:selectClassification">
    <xed:bind xpath="{@xpath}">
      <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
      <div class="form-group {@class} {$xed-val-marker}">
        <label class="col-md-3 control-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <div class="controls">
            <select class="form-control form-control-inline">
              <option value="">
                <xed:output i18n="editor.select" />
              </option>
              <xed:include uri="xslStyle:items2options:classification:editorComplete:1:children:{@classification}" />
            </select>
          </div>
        </div>
        <div class="col-md-3">
          <xsl:if test="string-length(@help-text) &gt; 0">
            <xsl:call-template name="cmo-helpbutton" />
          </xsl:if>
        </div>
        <xsl:call-template name="cmo-required" />
      </div>
    </xed:bind>
  </xsl:template>

  <xsl:template match="cmo:isoApproxDate">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <div class="form-group {@class} {$xed-val-marker}">
      <label class="col-md-3 control-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6">
        <div class="form-inline">
          <xed:bind xpath="@isodate">
            <input id="cmo_isodate" type="text" placeholder="YYYY-MM-DD" class="form-control datetimepicker date" />
          </xed:bind>
          <xed:bind xpath="@approx" initially="false">
            <div class="checkbox">
              <label>
                <xed:choose>
                  <xed:when test=".='true'">
                     <input id="cmo_toggleDate" type="checkbox" checked="checked" />
                  </xed:when>
                  <xed:otherwise>
                     <input id="cmo_toggleDate" type="checkbox" />
                  </xed:otherwise>
                </xed:choose>
                <xed:output i18n="editor.label.approxDate" />
              </label>
            </div>
          </xed:bind>
          <xed:bind xpath="@range" initially="false">
            <div class="checkbox">
              <label>
                <xed:choose>
                  <xed:when test=".='true'">
                     <input id="cmo_toggleRange" type="checkbox" checked="checked" />
                  </xed:when>
                  <xed:otherwise>
                     <input id="cmo_toggleRange" type="checkbox" />
                  </xed:otherwise>
                </xed:choose>
                <xed:output i18n="editor.label.rangeDate" />
              </label>
            </div>
          </xed:bind>
          <div id="cmo_toggleDate_approx" style="display:none;">
            <xed:bind xpath="@notbefore">
              <input id="cmo_notbefore" type="text" placeholder="YYYY-MM-DD" class="form-control datetimepicker cmo_dateInput" />
            </xed:bind>
            <xsl:text> - </xsl:text>
            <xed:bind xpath="@notafter">
              <input id="cmo_notafter"  type="text" placeholder="YYYY-MM-DD" class="form-control datetimepicker cmo_dateInput" />
            </xed:bind>
          </div>
          <div id="cmo_toggleDate_range" style="display:none;">
            <xed:bind xpath="@startdate">
              <input id="cmo_startdate" type="text" placeholder="YYYY-MM-DD" class="form-control datetimepicker cmo_dateInput" />
            </xed:bind>
            <xsl:text> - </xsl:text>
            <xed:bind xpath="@enddate">
              <input id="cmo_enddate"  type="text" placeholder="YYYY-MM-DD" class="form-control datetimepicker cmo_dateInput" />
            </xed:bind>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <xsl:if test="string-length(@help-text) &gt; 0">
          <xsl:call-template name="cmo-helpbutton" />
        </xsl:if>
      </div>
      <xsl:call-template name="cmo-required" />
    </div>
  </xsl:template>



  <xsl:template name="cmo-textfield">
    <label class="col-md-3 control-label form-inline">
      <xsl:if test="@label">
        <xed:output i18n="{@label}" />
      </xsl:if>
      <xsl:if test="@type">
        <xsl:text>&#160;</xsl:text>
        <xed:bind xpath="@type">
          <select class="form-control">
            <xed:include uri="xslStyle:items2options:classification:editorComplete:1:children:{@type}" />
          </select>
        </xed:bind>
      </xsl:if>
    </label>
    <div class="col-md-6">
      <input id="{@id}" type="text" class="form-control">
        <xsl:copy-of select="@placeholder" />
      </input>
    </div>
    <div class="col-md-3">
      <xsl:if test="string-length(@help-text) &gt; 0">
        <xsl:call-template name="cmo-helpbutton" />
      </xsl:if>
      <xsl:if test="@repeat = 'true'">
        <xsl:call-template name="cmo-pmud" />
      </xsl:if>
    </div>
  </xsl:template>


  <xsl:template name="cmo-required">
    <xsl:if test="@required='true'">
      <xed:validate required="true" display="global">
        <xsl:value-of select="i18n:translate(@required-i18n)" />
      </xed:validate>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cmo-helpbutton">
    <a tabindex="0" class="btn btn-default info-button" role="button" data-toggle="popover" data-placement="right" data-content="{@help-text}">
      <i class="fa fa-info"></i>
    </a>
  </xsl:template>

  <xsl:template match="cmo:pmud">
    <div class="col-md-3 {@class}">
      <xsl:call-template name="cmo-pmud" />
    </div>
  </xsl:template>

  <xsl:template match="cmo:help-pmud">
    <div class="col-md-3 {@class}">
      <xsl:if test="string-length(@help-text) &gt; 0">
        <xsl:call-template name="cmo-helpbutton" />
      </xsl:if>
      <xsl:if test="@pmud='true'">
        <xsl:call-template name="cmo-pmud" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="cmo-pmud">
    <span class="pmud-button">
      <xed:controls>insert</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>remove</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>up</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>down</xed:controls>
    </span>
  </xsl:template>


</xsl:stylesheet>