<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:dqm="http://standards.iso.org/iso/19157/-2/dqm/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:reg="http://standards.iso.org/iso/19115/-3/reg/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"

                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0" 
                xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0" 
                xmlns:delwp="https://github.com/geonetwork-delwp/iso19115-3.2018" 

                xmlns:java="java:org.fao.geonet.util.XslUtil"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"

                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                xmlns:dc="http://purl.org/dc/elements/1.1/"

                xmlns:str="http://exslt.org/strings"

                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-iso19115-3.2018="http://geonetwork-opensource.org/xsl/functions/profiles/iso19115-3.2018"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">


                <!-- xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  -->


  <!-- This formatter render an ISO19139 record based on the
  editor configuration file.


  The layout is made in 2 modes:
  * render-field taking care of elements (eg. sections, label)
  * render-value taking care of element values (eg. characterString, URL)

  3 levels of priority are defined: 100, 50, none

  -->
  <xsl:output method="html" version="4.0"
    encoding="UTF-8" indent="yes"/>

  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

 <!-- Required for utility-fn.xsl -->
  <xsl:variable name="editorConfig"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>
  <xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>
  <xsl:include href="../../layout/utility-fn.xsl"/>
  <xsl:include href="../../update-fixed-info-subtemplate.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/> 
  
  <!-- <xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/> -->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/mdb:MD_Metadata"/>

  <xsl:variable name="langId" select="gn-fn-iso19115-3.2018:getLangId($metadata, $language)"/>

  <!-- Ignore some fields displayed in header or in right column -->
  <xsl:template mode="render-field"
                match="mri:graphicOverview|mri:abstract|mdb:identificationInfo/*/mri:citation/*/cit:title|mri:associatedResource"
                priority="2000" />

  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="mdb:MD_Metadata" priority="999">

  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="mdb:MD_Metadata">

  </xsl:template>

  <xsl:template mode="getMetadataHierarchyLevel" match="mdb:MD_Metadata">
    
  </xsl:template>

  <xsl:template mode="getOverviews" match="mdb:MD_Metadata">
   

  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="mdb:MD_Metadata">
   
  </xsl:template>

  <xsl:variable name="warnColour">#f4c842</xsl:variable>
  <xsl:variable name="errColour">#db2800</xsl:variable>

  <xsl:variable name="nil"><span color="{$warnColour}">No field match / unsure of field mapping</span></xsl:variable>
  <xsl:variable name="missing"><span color="{$errColour}">Specific info missing from XML</span></xsl:variable>
  <xsl:variable name="redundant"><span>Potentially redundant information</span></xsl:variable>

  <xsl:variable name="prestyle">overflow-x: auto; white-space: pre-wrap; word-wrap: break-word; font-family: Arial, Helvetica, sans-serif;</xsl:variable>
  <xsl:variable name="footstyle">font-size: 12px;</xsl:variable>

  <!-- Dates -->
  <xsl:variable name="monthyear"><xsl:value-of select="format-dateTime(current-dateTime(),'[MNn] [Y0001]')"/></xsl:variable>
  <xsl:variable name="year"><xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001]')"/></xsl:variable>
  <xsl:variable name="printdate"><xsl:value-of select="format-dateTime(current-dateTime(),'[D01]/[M01]/[Y0001] [h1]:[m01]:[s01] [P]')"/></xsl:variable>

  <xsl:function name="gn-fn-render:cswURL">
    <xsl:param name="uuid"/>
    <xsl:variable name="query">
        Identifier+like+'<xsl:value-of select="$uuid" />'
    </xsl:variable>
    <xsl:value-of select="translate( concat('http://localhost:8080/geonetwork/srv/eng/csw?request=GetRecords&amp;service=CSW&amp;version=2.0.2&amp;namespace=xmlns%28csw%3Dhttp%3A%2F%2Fwww.opengis.net%2Fcat%2Fcsw%2F2.0.2%29%2Cxmlns%28gmd%3Dhttp%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd%29&amp;constraint=', $query, '&amp;constraintLanguage=CQL_TEXT&amp;constraint_language_version=1.1.0&amp;typeNames=mdb:MD_Metadata&amp;resultType=results&amp;ElementSetName=full&amp;outputSchema=http://standards.iso.org/iso/19115/-3/mdb/2.0'), ' ', '')" />
  </xsl:function>

  <xsl:template mode="renderExport" match="mdb:MD_Metadata">

    <xsl:variable name="title">
      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title" />
    </xsl:variable>

    <div style="font-family: Arial, Helvetica, sans-serif;">

      <h1><xsl:value-of select="$title" /></h1>

      <h2>Description</h2>
      <!-- Head section -->
      <table width="100%" class="identification">
        <tr>
          <td width="30%"><strong>Title:</strong></td>
          <td><xsl:value-of select="$title"/></td>
        </tr>
        <tr>
          <td><strong>Custodian:</strong></td>
          <td>
            <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian' ]/cit:party/cit:CI_Organisation/cit:name" />
          </td>
        </tr>
        <!-- <tr>
          <td><strong>Jurisdiction:</strong></td>
          <td><xsl:value-of select="$nil"/></td>
        </tr> -->
        <tr>
          <td><strong>Abstract:</strong></td>
          <td>
            <pre style="{$prestyle}">
              <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract"/>
            </pre>
          </td>
        </tr>
        <tr>
          <td><strong>Geographic Extent:</strong></td>
          <xsl:choose>
            <xsl:when test="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox">
              <td>
                <xsl:apply-templates mode="render-field" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox" />
              </td>
            </xsl:when>
            <xsl:when test="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_BoundingPolygon">
              <td>
                <xsl:apply-templates mode="render-field" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_BoundingPolygon" />
              </td>
            </xsl:when>
            <xsl:otherwise>
              <td>None provided</td>
            </xsl:otherwise>
          </xsl:choose>
          
          
        </tr>        
      </table>

      <!-- <xsl:for-each select="mdb:identificationInfo/*/mri:graphicOverview/*">
        <div>
          <img src="{mcc:fileName/*}" style="height: auto; display: inline-block" />
          <caption>
            <xsl:apply-templates mode="render-value" select="mcc:fileDescription" />
          </caption>
        </div>
      </xsl:for-each> -->

      <h2>General Dataset Details</h2>
      <table>
        <tr>
          <td><strong>Acquisition Date:</strong></td>
          <td><xsl:apply-templates mode="render-value" select="mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition" /> - <xsl:apply-templates mode="render-value" select="mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition" /></td>
          <td><strong>Projection</strong></td>
          <td>
            <xsl:value-of select="mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code" />
          </td>
          <td><strong>Vertical Datum</strong></td>
          <td>
            -
          </td>
        </tr>
      </table>

      <hr />
      
      <h2>Aerial Photography Details</h2>
      <table>
        <tr>
          <td><strong>Sensor Name:</strong></td>
          <td>
            <xsl:value-of select="mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Sensor/mac:citation/cit:CI_Citation/cit:title" />
          </td>
          <td><strong>Number of Bands:</strong></td>
          <td>
            <xsl:value-of select="*//delwp:rasterDetails/delwp:MD_RasterDetails/delwp:numberOfBands" />
          </td>
        </tr>
        <tr>
          <td><strong>Stored Data Format:</strong></td>
          <td>
              <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat" />
          </td>
          <td><strong>Tile Size:</strong></td>
          <td>
            <xsl:value-of select="*//delwp:tileSize/delwp:MD_TileSizeCode/@codeListValue" />
          </td>
        </tr>
      </table>

      <hr />
      <h2>Component Datasets</h2>
      <table style="margin-top: 10px; width: 100%;">
        <tr>
          <th>Record</th>
          <th>Dataset</th>
          <th>Resolution</th>
          <th>
            Horizontal*
          </th>
          <th>Start Date</th>
          <th>End Date</th>
        </tr>
        <xsl:for-each select="mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource">
          
          <!-- extract URL -->
          <xsl:variable name="resLink" select="mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:linkage" />
          
          <!-- Extract uuid from URL -->
          <xsl:variable name="uuid">
            <xsl:value-of select="normalize-space(substring-after($resLink, '='))" />
          </xsl:variable>

          <!-- Dummy UUID -->
          <!-- <xsl:variable name="uuid">
            <xsl:text>28fe27b29091e0481d07107e018503367e68a0d2</xsl:text>
          </xsl:variable> -->
          
          <!-- Create CSW URI from extracted uuid -->
          <!-- <xsl:variable name="uriString">
            <xsl:value-of select="concat( 'http://localhost:8080/geonetwork/srv/eng/csw?request=GetRecords&amp;service=CSW&amp;version=2.0.2&amp;namespace=xmlns%28csw%3Dhttp%3A%2F%2Fwww.opengis.net%2Fcat%2Fcsw%2F2.0.2%29%2Cxmlns%28gmd%3Dhttp%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd%29&amp;constraint=Identifier+like+%27', $uuid , '%27&amp;constraintLanguage=CQL_TEXT&amp;constraint_language_version=1.1.0&amp;typeNames=mdb:MD_Metadata&amp;resultType=results&amp;ElementSetName=full&amp;outputSchema=http://standards.iso.org/iso/19115/-3/mdb/2.0')" />
          </xsl:variable> -->

          <!-- Create API request from UUID -->
          <xsl:variable name="uriString">
            <xsl:value-of select="concat( 'http://localhost:8080/geonetwork/srv/api/records/', $uuid , '/formatters/xml' )" />
          </xsl:variable>

          <!-- https://dev-metashare.maps.vic.gov.au -->
          
          <!-- Create XML document from CSW request -->
          <xsl:variable name="resourceDoc" select="document( $uriString )" />
          
          <!-- Catch empty serach results and throw warning -->
          <xsl:choose>
            <xsl:when test="$resourceDoc//@numberOfRecordsReturned != 0 or not($resourceDoc//@numberOfRecordsReturned)">
              <tr>
                <td>
                  <xsl:value-of select="position()" />
                  <!-- <a href="{$uriString}" target="blank">XML</a> -->
                </td>
                <td>
                  <a href="{$resLink}" target="blank">
                    <xsl:value-of select="$resourceDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title" />
                  </a>
                </td>
                
                <td>
                  <xsl:value-of select="$resourceDoc//msr:MD_Dimension[msr:dimensionName/msr:MD_DimensionNameTypeCode/@codeListValue = 'row']/msr:resolution" />
                  <xsl:value-of select="$resourceDoc//msr:MD_Dimension[msr:dimensionName/msr:MD_DimensionNameTypeCode/@codeListValue = 'row']/msr:resolution/gco:Measure/@uom" />
                </td>
                <td>
                  
                  <xsl:value-of select="$resourceDoc//mri:spatialResolution" />
                  <xsl:value-of select="$resourceDoc//mri:spatialResolution//gco:Distance/@uom" />
                </td>
                
                <td>
                  <xsl:apply-templates mode="render-value" select="$resourceDoc//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition" />
                </td>
                <td>
                  <xsl:apply-templates mode="render-value" select="$resourceDoc//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition" />
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr style="background-color: {$warnColour}">
                <td colspan="5">
                  * Error: cannot retrieve record with UUID <xsl:value-of select="$uuid" />. It either does not exist or requires authorisation. <br />
                    <a href="{$uriString}" target="blank">CSW Request</a>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:for-each>
      </table>
      <caption style="text-align: left; font-size: 6pt; padding-top:5px;">
          * Accuracy (RMSE 68% Conf.)
      </caption>

      <table>
        <tr>
          <td><strong>Processing Lineage:</strong></td>
          <td>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
            </pre>
          </td>
        </tr>
        <tr>
          <td><strong>Logical Consistency:</strong></td>
          <td>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
            </pre>
          </td>
        </tr>
        <tr>
          <td><strong>Completeness:</strong></td>
          <td>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
            </pre>
          </td>
        </tr>
      </table>
    
      <div>
        <div style="width: 75%; float: left;">
            <p style="{$footstyle}">Published by the Victorian Government Department of Environment, Land, Water and Planning Melbourne, <xsl:value-of select="$monthyear" /></p>
            <p style="{$footstyle}">© The State of Victoria Department of Environment, Land, Water, and Planning <xsl:value-of select="$year" /> This publication is copyright. No part may be reproduced by any process except in
                accordance with the provisions of the Copyright Act 1968.</p>
            <p style="{$footstyle}">Printed <xsl:value-of select="$printdate" /></p>
        </div>
        <div style="float: right;">
          <img style="background-color: #201647; padding: 5px" src="https://www2.delwp.vic.gov.au/__data/assets/git_bridge/0015/177/deploy/mysource_files/logo-copy.png" />
        </div>
        
      </div>

      
    </div>
  </xsl:template>


  <!-- FIELD RENDERING -->
  <!-- time period fields -->
  <xsl:template mode="render-field" match="gml:TimePeriod">
    <xsl:choose>
      <xsl:when test="gml:beginPosition != ''">
        <xsl:apply-templates mode="render-value" select="gml:beginPosition"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="render-value" select="gml:beginPosition/@indeterminatePosition"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> - </xsl:text>
    <xsl:choose>
      <xsl:when test="gml:endPosition != ''">
        <xsl:apply-templates mode="render-value" select="gml:endPosition"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="render-value" select="gml:endPosition/@indeterminatePosition"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Contact table rows -->
  <xsl:template mode="render-field" match="cit:citedResponsibleParty">
    <tr>
      <td><xsl:value-of select="cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name"/></td>
      <td><xsl:value-of select="cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:number"/></td>
      <td>
        <xsl:apply-templates mode="render-value" select="cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue"/>
      </td>
    </tr>
  </xsl:template>
  




  <!-- Bbox is displayed with an overview and the geom displayed on it
  and the coordinates displayed around -->
  <xsl:template mode="render-field"
                match="gex:EX_GeographicBoundingBox[
                            gex:westBoundLongitude/gco:Decimal != '']">

    <xsl:variable name="urlbase">
      <xsl:copy-of select="'http://localhost:8080/geonetwork/srv//eng/region.getmap.png?mapsrs=EPSG:3857&amp;width=500&amp;background=osm&amp;geomsrs=EPSG:4326&amp;geom='" />
    </xsl:variable>
    <xsl:variable name="n">
        <xsl:value-of select="xs:double(gex:northBoundLatitude/gco:Decimal)" />
    </xsl:variable>
    <xsl:variable name="s">
        <xsl:value-of select="xs:double(gex:southBoundLatitude/gco:Decimal)" />
    </xsl:variable>
    <xsl:variable name="e">
        <xsl:value-of select="xs:double(gex:eastBoundLongitude/gco:Decimal)" />
    </xsl:variable>
    <xsl:variable name="w">
      <xsl:value-of select="xs:double(gex:westBoundLongitude/gco:Decimal)" />
    </xsl:variable>

    <xsl:variable name="bbox">
      <xsl:copy-of select="concat( 'POLYGON((' ,$e, ' ', $s, ',', $e, ' ', $n,',',$w, ' ', $n, ',', $w, ' ', $s, ',', $e, ' ', $s,'))' )" />
    </xsl:variable>

    <img src="{concat(translate($urlbase,' ',''),$bbox)}" />
    <br/>

  </xsl:template>

  <!-- Bbox is displayed with an overview and the geom displayed on it
  and the coordinates displayed around -->
  <xsl:template mode="render-field"
                match="gex:EX_BoundingPolygon">

    <xsl:variable name="urlbase">
      <xsl:copy-of select="'http://localhost:8080/geonetwork/srv//eng/region.getmap.png?mapsrs=EPSG:3857&amp;width=500&amp;background=osm&amp;geomsrs=EPSG:4326&amp;geom='" />
    </xsl:variable>

    <xsl:variable name="multipoly"><xsl:value-of select="count(/*//gml:posList) &gt; 1" /></xsl:variable>
    
    <xsl:variable name="nodes">
      <xsl:choose>
        <xsl:when test="not($multipoly)">
          <xsl:for-each select="tokenize(/*//gml:posList, ' ')">
            <xsl:if test="position() mod 2 &gt; 0">
              <y><xsl:value-of select="number(.)" /></y>
            </xsl:if>
            <xsl:if test="position() mod 2 = 0">
              <x><xsl:value-of select="number(.)" /></x>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="/*//gml:posList">
            <xsl:for-each select="tokenize(., ' ')">
              <xsl:if test="position() mod 2 &gt; 0">
                <y><xsl:value-of select="number(.)" /></y>
              </xsl:if>
              <xsl:if test="position() mod 2 = 0">
                <x><xsl:value-of select="number(.)" /></x>
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:variable>

    <xsl:variable name="polygonround">
      <xsl:text>POLYGON((</xsl:text>
      <xsl:for-each select="$nodes/x">
        <xsl:variable name="idx" select="position()" />
        <xsl:choose>
          <xsl:when test="position() != last()">
            <xsl:copy-of select="concat(format-number(., '000.000'), ' ', format-number(($nodes/y)[$idx], '000.000'), ',')" />
          </xsl:when>
          <xsl:otherwise>
              <xsl:copy-of select="concat(format-number(., '000.000'), ' ', format-number(($nodes/y)[$idx], '000.000'))" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:text>))</xsl:text>
    </xsl:variable>

    <xsl:variable name="polygon">
      <xsl:text>POLYGON((</xsl:text>
      <xsl:for-each select="$nodes/x">
        <xsl:variable name="idx" select="position()" />
        <xsl:choose>
          <xsl:when test="position() != last()">
            <xsl:copy-of select="concat(., ' ', ($nodes/y)[$idx], ',')" />
          </xsl:when>
          <xsl:otherwise>
              <xsl:copy-of select="concat(., ' ', ($nodes/y)[$idx])" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:text>))</xsl:text>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length(concat(translate($urlbase,' ',''),$polygon)) &lt; 2000 and not($multipoly)">
        <img src="{concat(translate($urlbase,' ',''),$polygon)}" />
        <br/>
      </xsl:when>
      <xsl:when test="string-length(concat(translate($urlbase,' ',''),$polygonround)) &lt; 2000 and not($multipoly)">
        <img src="{concat(translate($urlbase,' ',''),$polygon)}" />
        <caption style="text-align: left">* Polygon footprint has been simplified for.</caption>
        <br/>
      </xsl:when>
      <xsl:otherwise>
          <xsl:variable name="n">
            <xsl:value-of select="max( $nodes/y )" />
          </xsl:variable>
          <xsl:variable name="s">
            <xsl:value-of select="min( $nodes/y )" />
          </xsl:variable>
          <xsl:variable name="e">
            <xsl:value-of select="max( $nodes/x )" />
          </xsl:variable>
          <xsl:variable name="w">
            <xsl:value-of select="min( $nodes/x )" />
          </xsl:variable>
      
          <xsl:variable name="bbox">
            <xsl:copy-of select="concat( 'POLYGON((' ,$e, ' ', $s, ',', $e, ' ', $n,',',$w, ' ', $n, ',', $w, ' ', $s, ',', $e, ' ', $s,'))' )" />
          </xsl:variable>
      
          <img src="{concat(translate($urlbase,' ',''),$bbox)}" />
          <br/>
          <caption style="text-align: left">* Polygon footprint too complex to render, image shows bounding box of footprint area.</caption>
          <xsl:if test="$multipoly">
            <caption style="text-align: left">Source footprint comprised of multiple polygons.</caption>
          </xsl:if>
      </xsl:otherwise>
    </xsl:choose>


    

  </xsl:template>





  <!-- ########################## -->
  <!-- Render values for text ... -->

  <xsl:template mode="render-value"
                match="*[gco:CharacterString]">
  
    <xsl:apply-templates mode="localised" select=".">
      <xsl:with-param name="langId" select="$langId"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Integer|gco:Decimal|
                       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Angle|
                       gco:Scale|gco:Record|gco:RecordType|
                       gco:LocalName|gml:beginPosition|gml:endPosition">
    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
                      select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a href=''$1''&gt;$1&lt;/a&gt;')"/>

        <xsl:if test="$textWithLinks != ''">
          <xsl:copy-of select="saxon:parse(
                          concat('&lt;p&gt;',
                          replace($textWithLinks, '&amp;', '&amp;amp;'),
                          '&lt;/p&gt;'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>


    <xsl:if test="@uom">
      &#160;<xsl:value-of select="@uom"/>
    </xsl:if>
  </xsl:template>


  <xsl:template mode="render-value"
                match="lan:PT_FreeText">
    <xsl:apply-templates mode="localised" select="../node()">
      <xsl:with-param name="langId" select="$language"/>
    </xsl:apply-templates>
  </xsl:template>



  <xsl:template mode="render-value"
                match="gco:Distance">
    <span><xsl:value-of select="."/>&#10;<xsl:value-of select="@uom"/></span>
  </xsl:template>

  <!-- ... Dates - formatting is made on the client side by the directive  -->
  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="MMM YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:DateTime[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
    <span data-gn-humanize-time="{.}">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date|gco:DateTime">
    <span data-gn-humanize-time="{.}">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <!-- TODO -->
  <xsl:template mode="render-value"
          match="lan:language/gco:CharacterString">
    <!--mri:defaultLocale>-->
    <!--<lan:PT_Locale id="ENG">-->
    <!--<lan:language-->
    <span data-translate=""><xsl:value-of select="."/></span>
  </xsl:template>

  <!-- ... Codelists -->
  <xsl:template mode="render-value"
                match="@codeListValue">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
        <span title="{$codelistDesc}"><xsl:value-of select="$codelistTranslation"/></span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Enumeration -->
  <xsl:template mode="render-value"
                match="mri:MD_TopicCategoryCode|
                       mex:MD_ObligationCode[1]|
                       msr:MD_PixelOrientationCode[1]|
                       srv:SV_ParameterDirection[1]|
                       reg:RE_AmendmentType">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            local-name(), $id)"/>
        <span title="{$codelistDesc}"><xsl:value-of select="$codelistTranslation"/></span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-value"
                match="@gco:nilReason[. = 'withheld']"
                priority="100">
    <i class="fa fa-lock text-warning" title="{{{{'withheld' | translate}}}}">&#160;</i>
  </xsl:template>

  <xsl:template mode="render-value"
                match="@indeterminatePosition">

    <xsl:value-of select="."/>

  </xsl:template>


  <xsl:template mode="render-value"
                match="@*"/>

</xsl:stylesheet>
