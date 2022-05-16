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

  <!-- Set some styles -->
  <xsl:variable name="warnColour">#f4c842</xsl:variable>
  <xsl:variable name="errColour">#db2800</xsl:variable>

  <!-- some reusable strings -->
  <xsl:variable name="nil"><span color="{$warnColour}">No field match / unsure of field mapping</span></xsl:variable>
  <xsl:variable name="missing"><span color="{$errColour}">N/A</span></xsl:variable>
  <xsl:variable name="redundant"><span>Potentially redundant information</span></xsl:variable>

  <xsl:variable name="parentMissing">
    <span><i>Field not present on parent record</i></span>
  </xsl:variable>

  <xsl:variable name="prestyle">overflow-x: auto; white-space: pre-wrap; word-wrap: break-word; font-family: Arial, Helvetica, sans-serif; vertical-align: top;</xsl:variable>
  <xsl:variable name="footstyle">font-size: 12px;</xsl:variable>
  <xsl:variable name="tdstyle">vertical-align: top;</xsl:variable>

  <!-- Dates -->
  <xsl:variable name="monthyear"><xsl:value-of select="format-dateTime(current-dateTime(),'[MNn] [Y0001]')"/></xsl:variable>
  <xsl:variable name="year"><xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001]')"/></xsl:variable>
  <xsl:variable name="printdate"><xsl:value-of select="format-dateTime(current-dateTime(),'[D01]/[M01]/[Y0001] [h1]:[m01]:[s01] [P]')"/></xsl:variable>

  <!-- Hardcoded values -->
  <xsl:variable name="jurisdiction"><xsl:value-of select="'Victoria'"/></xsl:variable>  
  <xsl:variable name="verticalDatum"><xsl:value-of select="'AHD'"/></xsl:variable>  

  <!-- function to render CSW request for looking up associated records -->
  <!-- not used in current implementation -->
  <xsl:function name="gn-fn-render:cswURL">
    <xsl:param name="uuid"/>
    <xsl:variable name="query">
        Identifier+like+'<xsl:value-of select="$uuid" />'
    </xsl:variable>
    <xsl:value-of select="translate( concat('http://localhost:8080/geonetwork/srv/eng/csw?request=GetRecords&amp;service=CSW&amp;version=2.0.2&amp;namespace=xmlns%28csw%3Dhttp%3A%2F%2Fwww.opengis.net%2Fcat%2Fcsw%2F2.0.2%29%2Cxmlns%28gmd%3Dhttp%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd%29&amp;constraint=', $query, '&amp;constraintLanguage=CQL_TEXT&amp;constraint_language_version=1.1.0&amp;typeNames=mdb:MD_Metadata&amp;resultType=results&amp;ElementSetName=full&amp;outputSchema=http://standards.iso.org/iso/19115/-3/mdb/2.0'), ' ', '')" />
  </xsl:function>

  <!-- 
    function to combine an associated resource record and a URL 
    required so we can pass the URL of the resource linkage through to the child record, and render the template
  -->
  <xsl:function name="gn-fn-render:add-url">
    <!-- made nodeset to be linked -->
    <xsl:param name="mainNode"/>
    <!-- URL valuer -->
    <xsl:param name="url"/>

    <!-- wrap whole set in new element-->
    <resource>
      <!-- grab copy of main node -->
      <xsl:copy-of select="$mainNode"/>
      <!-- populate new resUrl element with url value -->
      <resUrl><xsl:copy-of select="$url"/></resUrl>
    </resource>
    
  </xsl:function>

  <!-- Create API url for looking up associated records -->
  <xsl:function name="gn-fn-render:APIURL">
    <xsl:param name="uuid"/>
    <xsl:value-of select="concat( 'http://localhost:8080/geonetwork/srv/api/records/', $uuid, '/formatters/xml?approved=true' )" />
  </xsl:function>

  <!-- BEGIN RENDERING REPORT TEMPLATE -->
  <xsl:template mode="renderExport" match="mdb:MD_Metadata">

    <!-- store scope of record - i.e. project or dataset -->
    <xsl:variable name="rawscope"><xsl:value-of select="mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue" /></xsl:variable>
    <!-- make capitalised scope for use in headings -->
    <xsl:variable name="datascope">
      <xsl:value-of select="concat( translate(substring($rawscope, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($rawscope, 2))" />
    </xsl:variable>

    <!-- store title -->
    <xsl:variable name="title">
      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title" />
    </xsl:variable>

    <!-- START PROCESSING ASSOCIATED RECORDS -->

    <!-- get available associated records -->
    <!-- nb. this is a list or mri:associatedResource elements from the parent project, not the records themselves -->
    <!-- use the doc-available() function on the rendered URL to test if we can access it -->
    <xsl:variable name="availableAssocRecords" 
      select=" mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource[
        doc-available( gn-fn-render:APIURL( mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) ) 
        ]" />
    
    <!-- same as above, but these are the associated records that are not available -->
    <xsl:variable name="missingAssocRecords" 
      select="mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource[
        not( doc-available( gn-fn-render:APIURL( mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) ) )
        ]" />
    
    <!-- 
    loop records and see if they have a "dem" element 
    we need this to render the headers properly, because I can't find a good way of 
    storing whole documents in a list. The demExists variable value will be string of numbers representing t/f if 
    they have the dem element

    e.g. if there are 3 records and the second one is a DEM, then the value will be 010.
    Parsing this text value into a number will result in 0 if there are no records that match dem
    and greater than 0 if there are results 
    -->
    <xsl:variable name="demExists">
      <xsl:for-each select="$availableAssocRecords">
        <xsl:variable name="resDoc" 
        select=" document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
        <xsl:choose>
          <xsl:when test="$resDoc//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'DEM'">
            <xsl:value-of select="concat( position(), ',' ) " />
          </xsl:when>
        </xsl:choose>
        
      </xsl:for-each>
    </xsl:variable>

    <!-- save index of first record to use for generic fields -->
    <xsl:variable name="demIndex">
      <xsl:value-of select="number( substring-before($demExists, ',') )" />
    </xsl:variable>

    <!-- as above for, but point cloud records -->
    <xsl:variable name="pointCloudExists">
      <xsl:for-each select="$availableAssocRecords">
        <xsl:variable name="resDoc" 
        select=" document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
        <xsl:choose>
            <xsl:when test="$resDoc//delwp:pointCloudDetails">
            <xsl:value-of select="concat( position(), ',' ) " />
          </xsl:when>
        </xsl:choose>
        
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="pointCloudIndex">
      <xsl:value-of select="number( substring-before($pointCloudExists, ',') )" />
    </xsl:variable>

    <!-- as above, but for contour records -->
    <xsl:variable name="contourExists">
      <xsl:for-each select="$availableAssocRecords">
        <xsl:variable name="resDoc" 
        select=" document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
        <xsl:choose>
          <xsl:when test="$resDoc//delwp:contourDetails">
            <xsl:value-of select="concat( position(), ',' ) " />
          </xsl:when>
        </xsl:choose>
        
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="contourIndex">
      <xsl:value-of select="number( substring-before($contourExists, ',') )" />
    </xsl:variable>

    <!-- as above, but for imagery records -->
    <xsl:variable name="imageryExists">
      <xsl:for-each select="$availableAssocRecords">
        <xsl:variable name="resDoc" 
        select=" document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
        <xsl:choose>
          <xsl:when test="$resDoc//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'Aerial Photo'">
            <xsl:value-of select="concat( position(), ',' ) " />
          </xsl:when>
        </xsl:choose>
        
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="imageryIndex">
      <xsl:value-of select="number( substring-before($imageryExists, ',') )" />
    </xsl:variable>

    <!-- 
      Save list of dates to string variable 
      We can't store the list of fetched docs, so we need to go get each of the docs, and store their dates in a comma-separated string.
      We can then parse and sort the dates to get the min and max dates for a project
    -->
    <xsl:variable name="projDates">
      <xsl:for-each select="$availableAssocRecords">
        <xsl:variable name="resDoc" 
        select=" document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />

        <xsl:value-of select="concat( $resDoc//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition, ',' ) " />
        <xsl:value-of select="concat( $resDoc//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition, ',' ) " />
        
      </xsl:for-each>
    </xsl:variable>

    <!-- parse out minimum date from list of dates -->
    <xsl:variable name="projMinDate">
      <xsl:for-each select="tokenize( substring($projDates, 1, string-length($projDates) - 1), ',')">
        <xsl:sort select="." order="ascending"/>
        <xsl:if test="position() = 1">
            <xsl:value-of select="." />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- parse out maximum date from list of dates -->
    <xsl:variable name="projMaxDate">
      <xsl:for-each select="tokenize( substring($projDates, 1, string-length($projDates) - 1), ',')">
        <xsl:sort select="." order="descending"/>
        <xsl:if test="position() = 1">
            <xsl:value-of select="." />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Start creating report body -->
    <div style="font-family: Arial, Helvetica, sans-serif;">
      
      <!-- report header -->
      <h1><xsl:value-of select="$title" /></h1>
      <h3>Vicmap Imagery and Elevation Metadata Report</h3>

      <h2>Description</h2>
      <!-- Head section -->
      <table width="100%" class="identification">
        <tr>
          <!-- title -->
          <td width="30%"><strong>Title:</strong></td>
          <td><xsl:value-of select="$title"/></td>
        </tr>
        <tr>
          <!-- custodian -->
          <td><strong>Custodian:</strong></td>
          <td>
            <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian' ]/cit:party/cit:CI_Organisation/cit:name" />
          </td>
        </tr>
        <tr>
          <!-- abstract -->
          <td style="vertical-align: top;"><strong>Abstract:</strong></td>
          <td>
            <pre style="{$prestyle}">
              <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract"/>
            </pre>
          </td>
        </tr>
        <tr>
          <!-- extent -->
          <td><strong>Geographic Extent:</strong></td>
          <td>
            <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:description"/>
          </td>
        </tr>
        <td></td>
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
            <td></td>
          </xsl:otherwise>
        </xsl:choose>
        <tr>
          <!-- jurisdiction -->
          <td><strong>Jursidiction:</strong></td>
          <td><xsl:value-of select="$jurisdiction"/></td>
        </tr>
      </table>

      
      <!-- old graphic overview image -->
      <!-- <xsl:for-each select="mdb:identificationInfo/*/mri:graphicOverview/*">
        <div>
          <img src="{mcc:fileName/*}" style="height: auto; display: inline-block" />
          <caption>
            <xsl:apply-templates mode="render-value" select="mcc:fileDescription" />
          </caption>
        </div>
      </xsl:for-each> -->

      <!-- handle projects -->
      <xsl:choose>
        <xsl:when test="$rawscope = 'project'">
          <h2>General <xsl:value-of select="$datascope"/> Details</h2>
          <table>
            <tr>
              <td><strong>Acquisition Date:</strong></td>
              <td>
                <span data-gn-humanize-time="{$projMinDate}" data-format="DD MMM YYYY"><xsl:value-of select="$projMinDate" /></span> to 
                <span data-gn-humanize-time="{$projMaxDate}" data-format="DD MMM YYYY"><xsl:value-of select="$projMaxDate" /></span></td>
              <!-- <td><strong>Projection</strong></td>
              <td>
                <xsl:value-of select="mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code" />
              </td> -->
            </tr>
          </table>
        
        </xsl:when>

        <!-- handle datasets -->
        <!-- will probably remove this bit -->
        <xsl:when test="$rawscope = 'dataset'">

          <xsl:choose>
            <!-- LIDAR TEMPLATE -->
            <xsl:when test="*//delwp:pointCloudDetails">
              <h2>LiDAR Point Cloud Details</h2>
              <!-- <table>
                <tr>
                  <td><strong>Average Point Density:</strong></td>
                  <td>
                    <xsl:value-of select="*//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:pointDensityActual" />
                  </td>
                  <td><strong>Sensor Name:</strong></td>
                  <td>
                    <xsl:value-of select="mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Sensor/mac:citation/cit:CI_Citation/cit:title" />
                  </td>
                </tr>
                <tr>
                  <td><strong>Footprint Size:</strong></td>
                  <td>
                    <xsl:value-of select="*//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:footprintSize" />
                  </td>
                  <td><strong>Stored Data Format:</strong></td>
                  <td>
                      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat" />
                  </td>
                </tr>
                <tr>
                  <td><strong>Pulse Mode:</strong></td>
                  <td>
                    ???
                  </td>
                  <td><strong>Classification:</strong></td>
                  <td>
                    ???
                  </td>
                </tr>
                <tr>
                  <td><strong>Return Type:</strong></td>
                  <td>
                    ???
                  </td>
                </tr>
              </table> -->

              <hr />

              <table style="margin-top: 10px; width: 100%;">
                <tr>
                  <th>Dataset</th>
                  <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
                  <th>Vertical Accuracy</th>
                  <th>Average Point Density</th>
                  <th>
                    Projection
                  </th>
                  <th>Vertical Datum</th>
                  <th>Stored Format</th>
                  <th>Class</th>
                  <th>Start Date</th>
                  <th>End Date</th>
                </tr>
                <xsl:apply-templates mode="render-cip-associated-record" select="." />
              </table>

              <hr />


            </xsl:when>

            <!-- CONTOUR TEMPLATE -->
            <xsl:when test="*//delwp:contourDetails">

              <h2>Contour Details</h2>
              <table>
                <tr>
                  <td><strong>Stored Data Format:</strong></td>
                  <td>
                    <td><xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title"/></td>
                  </td>
                </tr>
              </table>

              <hr />

              <table style="margin-top: 10px; width: 100%;">
                <tr>
                  <th>Dataset</th>
                  <th>Contour Interval</th>
                  <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
                  <th>Vertical Accuracy</th>
                  <th>
                    Projection
                  </th>
                  <th>Vertical Datum</th>
                  <th>Start Date</th>
                  <th>End Date</th>
                </tr>
                <xsl:apply-templates mode="render-cip-associated-record" select="." />
              </table>

              <hr />

            </xsl:when>

            <!-- DEM TEMPLATE -->
            <xsl:when test=".//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'DEM'">

              <h2>Digital Elevation Model Details</h2>
              <table>
                <tr>
                  <td><strong>Stored Data Format:</strong></td>
                  <td>
                    <td><xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title"/></td>
                  </td>
                </tr>
              </table>

              <hr />

              <table style="margin-top: 10px; width: 100%;">
                <tr>
                  <th>Dataset</th>
                  <th>Resolution</th>
                  <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
                  <th>Vertical Accuracy</th>
                  <th>
                    Projection
                  </th>
                  <th>Vertical Datum</th>
                  <th>Start Date</th>
                  <th>End Date</th>
                </tr>
                <xsl:apply-templates mode="render-cip-associated-record" select="." />
              </table>

              <hr />

            </xsl:when>

            <xsl:when test=".//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'Aerial Photo'">
              <!-- write single set of headers if there are any records -->
              <h2>Aerial Photography Details</h2>

              <!-- summary table - TBC if this comes from a single child dataset -->
              <table>
                <tr>
                  <td><strong>Sensor Name:</strong></td>
                  <td><xsl:apply-templates mode="render-value" select=".//mac:instrument/mac:MI_Sensor/mac:citation/cit:CI_Citation/cit:title"/></td>
                  <td><strong>Number of Bands:</strong></td>
                  <td><xsl:apply-templates mode="render-value" select=".//delwp:dataDetails/delwp:MD_DataDetails/delwp:rasterDetails/delwp:MD_RasterDetails/delwp:numberOfBands"/></td>
                </tr>
                <tr>
                  <td><strong>Stored Data Format:</strong></td>
                  <td>
                    <td>
                      <xsl:choose>
                        <xsl:when test=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title">
                          <xsl:value-of select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="$missing"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </td>
                  <td><strong>Tile Size:</strong></td>
                  <td><xsl:apply-templates mode="render-value" select=".//delwp:datasetDetails/delwp:MD_DatasetDetails/delwp:tileSize/delwp:MD_TileSizeCode/@codeListValue"/></td>
                </tr>
              </table>

              <table style="margin-top: 10px; width: 100%;">
                <tr>
                  <th>Dataset</th>
                  <th>Resolution</th>
                  <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
                  <th>Vertical Accuracy</th>
                  <th>
                    Projection
                  </th>
                  <th>Vertical Datum</th>
                  <th>Start Date</th>
                  <th>End Date</th>
                </tr>
                <xsl:apply-templates mode="render-cip-associated-record" select="." />
              </table>

              <hr />
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>

          </xsl:choose>

          <h3>Processing Lineage:</h3>
          <xsl:choose>
            <xsl:when test=".//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description or .//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description">

                
                <pre style="{$prestyle}">
                  <xsl:apply-templates mode="render-value" select=".//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
                </pre>
                <pre style="{$prestyle}">
                  <xsl:apply-templates mode="render-value" select=".//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description"/>
                </pre>
              
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$missing"/>
            </xsl:otherwise>
          </xsl:choose>

          <h3>Logical Consistency:</h3>
          <xsl:choose>
            <xsl:when test=".//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
                
                <pre style="{$prestyle}">
                  <xsl:apply-templates mode="render-value" select=".//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
                </pre>

            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$missing"/>
            </xsl:otherwise>
          </xsl:choose>

          <h3>Completeness:</h3>
          <xsl:choose>
            <xsl:when test=".//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
                
                <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select=".//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
            </pre>

            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$missing"/>
            </xsl:otherwise>
          </xsl:choose>

          
        
        
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>

      
      </xsl:choose>

      <!-- RENDER ASSOCIATED RECORDS -->
      <!-- test if there are any point cloud records
      i.e. when casting the pointCloudExists variable to a number, it is greater than 0 -->
      <xsl:if test="$pointCloudIndex > 0">

        <xsl:variable name="pointCloudIndexDoc" 
          select="document( gn-fn-render:APIURL( ($availableAssocRecords)[ number($pointCloudIndex) ]/mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />

        <!-- write single set of headers if there are any records -->
        <h2>LiDAR Point Cloud Details</h2>

        <!-- <table>
          <tr>
            <td><strong>Average Point Density:</strong></td>
            <td>
              <xsl:choose>
                <xsl:when test="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:pointDensityActual">
                  <xsl:value-of select="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:pointDensityActual" /> 
                  <xsl:value-of select="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:pointDensityActual/gco:Measure/@uom" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$missing"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td><strong>Sensor Name:</strong></td>
            <td>
              <xsl:choose>
                <xsl:when test="$pointCloudIndexDoc//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Sensor/mac:citation/cit:CI_Citation/cit:title">
                  <xsl:value-of select="$pointCloudIndexDoc//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Sensor/mac:citation/cit:CI_Citation/cit:title" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$missing"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td><strong>Footprint Size:</strong></td>
            <td>
              <xsl:choose>
                <xsl:when test="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:footprintSize">
                  <xsl:value-of select="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:footprintSize" />
                  <xsl:value-of select="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:footprintSize/gco:Measure/@uom" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$missing"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td><strong>Stored Data Format:</strong></td>
            <td>
                <xsl:choose>
                <xsl:when test="$pointCloudIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat">
                  <xsl:value-of select="$pointCloudIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$missing"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td><strong>Pulse Mode:</strong></td>
            <td>
              <xsl:value-of select="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:pulseMode" />
            </td>
            <td><strong>Classification:</strong></td>
            <td>
              <xsl:value-of select="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:classification/delwp:MD_Classification/delwp:classLevel" />
            </td>
          </tr>
          <tr>
            <td><strong>Return Type:</strong></td>
            <td>
              <xsl:value-of select="$pointCloudIndexDoc//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:returnType" />
            </td>
          </tr>
        </table> -->

        <hr />

        <table style="margin-top: 10px; width: 100%;">
        <tr>
          <th>Dataset</th>
          <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
          <th>Vertical Accuracy</th>
          <th>Average Point Density</th>
          <th>
            Projection
          </th>
          <th>Vertical Datum</th>
          <th>Stored Format</th>
          <th>Class</th>
          <th>Start Date</th>
          <th>End Date</th>
        </tr>

        <!-- loop records -->
        <xsl:for-each select="$availableAssocRecords">

            <xsl:variable name="resDoc" 
              select="document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
            
            <xsl:choose>
              <xsl:when test="$resDoc//delwp:pointCloudDetails">

                <!-- render associated record, and append the resource URL to it so we can link out -->
                <xsl:apply-templates mode="render-cip-associated-record" select="gn-fn-render:add-url($resDoc, .//cit:linkage)" />

              </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
        </table>

        <h3>Processing Lineage:</h3>
        <xsl:choose>
          <xsl:when test="$pointCloudIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description or $pointCloudIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description">

              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$pointCloudIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
              </pre>
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$pointCloudIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description"/>
              </pre>
            
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Logical Consistency:</h3>
        <xsl:choose>
          <xsl:when test="$pointCloudIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$pointCloudIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
              </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Completeness:</h3>
        <xsl:choose>
          <xsl:when test="$pointCloudIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
            <xsl:apply-templates mode="render-value" select="$pointCloudIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
          </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <hr />
        
      </xsl:if>

      <!-- test if there are any dem records  -->
      <xsl:if test="$demIndex > 0">

        <xsl:variable name="demIndexDoc" 
          select="document( gn-fn-render:APIURL( ($availableAssocRecords)[ number($demIndex) ]/mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />

        <!-- write single set of headers if there are any records -->
        <h2>Digital Elevation Model Details</h2>

        <!-- summary table - TBC if this comes from a single child dataset -->
        <table>
          <tr>
            <td><strong>Stored Data Format:</strong></td>
            <td>
              <td>
                <xsl:choose>
                <xsl:when test="$demIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title">
                  <xsl:value-of select="$demIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$missing"/>
                </xsl:otherwise>
              </xsl:choose>
              </td>
            </td>
          </tr>
        </table>

        <hr />

        <table style="margin-top: 10px; width: 100%;">
        <tr>
          <th>Dataset</th>
          <th>Resolution</th>
          <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
          <th>Vertical Accuracy</th>
          <th>
            Projection
          </th>
          <th>Vertical Datum</th>
          <th>Start Date</th>
          <th>End Date</th>
        </tr>

        <!-- loop rows to populate table -->
        <xsl:for-each select="$availableAssocRecords">
            <!-- fetch xml record -->
            <xsl:variable name="resDoc" 
              select="document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
            
            <xsl:choose>
              <xsl:when test="$resDoc//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'DEM'">
                
                <!-- render associated record, and append the resource URL to it so we can link out -->
                <xsl:apply-templates mode="render-cip-associated-record" select="gn-fn-render:add-url($resDoc, .//cit:linkage)" />

              </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
        <!-- close table -->
        </table>

        <h3>Processing Lineage:</h3>
        <xsl:choose>
          <xsl:when test="$demIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description or $demIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description">

              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$demIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
              </pre>
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$demIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description"/>
              </pre>
            
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Logical Consistency:</h3>
        <xsl:choose>
          <xsl:when test="$demIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$demIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
              </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Completeness:</h3>
        <xsl:choose>
          <xsl:when test="$demIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$demIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
              </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <hr />
      </xsl:if>

      <!-- test if there are any IMAGERY records  -->
      <xsl:if test="$imageryIndex > 0">

        <xsl:variable name="imageryIndexDoc" 
          select="document( gn-fn-render:APIURL( ($availableAssocRecords)[ number($imageryIndex) ]/mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />

        <!-- write single set of headers if there are any records -->
        <h2>Aerial Photography Details</h2>

        <!-- summary table - TBC if this comes from a single child dataset -->
        <table>
          <tr>
            <td><strong>Sensor Name:</strong></td>
            <td><xsl:apply-templates mode="render-value" select="$imageryIndexDoc//mac:instrument/mac:MI_Sensor/mac:citation/cit:CI_Citation/cit:title"/></td>
            <td><strong>Number of Bands:</strong></td>
            <td><xsl:apply-templates mode="render-value" select="$imageryIndexDoc//delwp:dataDetails/delwp:MD_DataDetails/delwp:rasterDetails/delwp:MD_RasterDetails/delwp:numberOfBands"/></td>
          </tr>
          <tr>
            <td><strong>Stored Data Format:</strong></td>
            <td>
              <td>
                <xsl:choose>
                <xsl:when test="$imageryIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title">
                  <xsl:value-of select="$imageryIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$missing"/>
                </xsl:otherwise>
              </xsl:choose>
              </td>
            </td>
            <td><strong>Tile Size:</strong></td>
            <td><xsl:apply-templates mode="render-value" select="$imageryIndexDoc//delwp:datasetDetails/delwp:MD_DatasetDetails/delwp:tileSize/delwp:MD_TileSizeCode/@codeListValue"/></td>
          </tr>
        </table>

        <hr />

        <table style="margin-top: 10px; width: 100%;">
        <tr>
          <th>Dataset</th>
          <th>Resolution</th>
          <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
          <th>Vertical Accuracy</th>
          <th>
            Projection
          </th>
          <th>Vertical Datum</th>
          <th>Start Date</th>
          <th>End Date</th>
        </tr>

        <!-- loop rows to populate table -->
        <xsl:for-each select="$availableAssocRecords">
            <!-- fetch xml record -->
            <xsl:variable name="resDoc" 
              select="document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
            
            <xsl:choose>
              <xsl:when test="$resDoc//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'Aerial Photo'">
                
                <!-- render associated record, and append the resource URL to it so we can link out -->
                <xsl:apply-templates mode="render-cip-associated-record" select="gn-fn-render:add-url($resDoc, .//cit:linkage)" />

              </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
        <!-- close table -->
        </table>

        <h3>Processing Lineage:</h3>
        <xsl:choose>
          <xsl:when test="$imageryIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description or $imageryIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description">

              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$imageryIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
              </pre>
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$imageryIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description"/>
              </pre>
            
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Logical Consistency:</h3>
        <xsl:choose>
          <xsl:when test="$imageryIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$imageryIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
              </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Completeness:</h3>
        <xsl:choose>
          <xsl:when test="$imageryIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$imageryIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
              </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <hr />
      </xsl:if>

      <!-- test if there are any contour records
      i.e. when casting the contourIndex variable to a number, it is greater than 0 -->
      <xsl:if test="$contourIndex > 0">

        <xsl:variable name="contourIndexDoc" 
          select="document( gn-fn-render:APIURL( ($availableAssocRecords)[ number($contourIndex) ]/mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />

        <!-- write single set of headers if there are any records -->
        <h2>Contour Details</h2>
        <table>
          <tr>
            <td><strong>Stored Data Format:</strong></td>
            <td>
              <td>
                <xsl:choose>
                <xsl:when test="$contourIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title">
                  <xsl:value-of select="$contourIndexDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$missing"/>
                </xsl:otherwise>
              </xsl:choose>
              </td>
            </td>
          </tr>
        </table>

        <hr />

        <table style="margin-top: 10px; width: 100%;">
        <tr>
          <th>Dataset</th>
          <th>Contour Interval</th>
          <th>Accuracy (RMSE 68% Conf.) Horizontal</th>
          <th>Vertical Accuracy</th>
          <th>
            Projection
          </th>
          <th>Vertical Datum</th>
          <th>Start Date</th>
          <th>End Date</th>
        </tr>
        <xsl:for-each select="$availableAssocRecords">

            <!-- get document -->
            <xsl:variable name="resDoc" 
              select="document( gn-fn-render:APIURL(./mri:MD_AssociatedResource/mri:metadataReference/@uuidref ) )" />
            
            <!-- select out only those with contour records -->
            <xsl:choose>
              <xsl:when test="$resDoc//delwp:contourDetails">
                <!-- render associated record, and append the resource URL to it so we can link out -->
                <xsl:apply-templates mode="render-cip-associated-record" select="gn-fn-render:add-url($resDoc, .//cit:linkage)" />
              </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
        </table>
        
        <h3>Processing Lineage:</h3>
        <xsl:choose>
          <xsl:when test="$contourIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description or $contourIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description">

              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$contourIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
              </pre>
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$contourIndexDoc//mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description"/>
              </pre>
            
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Logical Consistency:</h3>
        <xsl:choose>
          <xsl:when test="$contourIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
                <xsl:apply-templates mode="render-value" select="$contourIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
              </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

        <h3>Completeness:</h3>
        <xsl:choose>
          <xsl:when test="$contourIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation">
              
              <pre style="{$prestyle}">
            <xsl:apply-templates mode="render-value" select="$contourIndexDoc//mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
          </pre>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$missing"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:if>
      
      <!-- handle any associated records that could not be accessed -->
      <xsl:if test="count($missingAssocRecords) > 0">
        <h1>Other associated records</h1>
        <xsl:for-each select="$missingAssocRecords">
          <p>Could not retrieve details for <a href="{.//cit:linkage}" target="blank"><xsl:value-of select=".//cit:title" /></a> - you may be able to view its details online.</p>
        </xsl:for-each>  
      </xsl:if>
     
      <!-- <caption style="text-align: left; font-size: 6pt; padding-top:5px;">
          * Accuracy (RMSE 68% Conf.)
      </caption> -->


      <!-- <hr /> -->
    
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

  <xsl:template mode="render-cip-associated-record" match="*">
    <xsl:choose>
      <xsl:when test=".//delwp:contourDetails">
          
          <tr>
            <td>
              <a href="{.//resUrl}" target="blank">
                <xsl:value-of select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title"/>
              </a>
            </td>
            <!-- <td><xsl:value-of select=".//delwp:contourDetails/delwp:MD_ContourDetails/delwp:interval"/></td> -->
            <td><xsl:apply-templates mode="render-value" select=".//delwp:contourDetails/delwp:MD_ContourDetails/delwp:interval/gco:Measure"/></td>
            <td><xsl:apply-templates mode="render-value" select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance"/></td>
            <td><xsl:apply-templates mode="render-value" select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:spatialResolution/mri:MD_Resolution/mri:vertical/gco:Distance"/></td>
            <td><xsl:value-of select=".//mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code"/></td>
            <td><xsl:value-of select="$verticalDatum"/></td>
            <td>
              <span data-gn-humanize-time="{.//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition}" data-format="DD MMM YYYY">
                <xsl:value-of select=".//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition" />
              </span>
            </td>
            <td>
              <span data-gn-humanize-time="{.//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition}" data-format="DD MMM YYYY">
                <xsl:value-of select=".//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition" />
              </span>
            </td>
          </tr>

      </xsl:when>
      <xsl:when test=".//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'DEM' or .//delwp:type/delwp:MD_RasterTypeCode/@codeListValue = 'Aerial Photo'">
 
          <tr>
            <td>
              <a href="{.//resUrl}" target="blank">
                <xsl:value-of select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title"/>
              </a>
            </td>
            <td>
              <xsl:for-each select=".//mdb:spatialRepresentationInfo/msr:MD_GridSpatialRepresentation/msr:axisDimensionProperties/msr:MD_Dimension">
                <xsl:choose>
                  <xsl:when test=".//msr:dimensionName/msr:MD_DimensionNameTypeCode/@codeListValue = 'column'">
                    <span>Column <xsl:apply-templates mode="render-value"  select="msr:resolution/gco:Measure"/></span><br />
                  </xsl:when>
                  <xsl:when test="msr:dimensionName/msr:MD_DimensionNameTypeCode/@codeListValue = 'row'">
                    <span>Row <xsl:apply-templates mode="render-value"  select="msr:resolution/gco:Measure"/></span>
                  </xsl:when>
                </xsl:choose> 
              </xsl:for-each>
            </td>
            <td><xsl:apply-templates mode="render-value" select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance"/></td>
            <td><xsl:apply-templates mode="render-value" select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:spatialResolution/mri:MD_Resolution/mri:vertical/gco:Distance"/></td>
            <td><xsl:value-of select=".//mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code"/></td>
            <td><xsl:value-of select="$verticalDatum"/></td>
            <td>
              <span data-gn-humanize-time="{.//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition}" data-format="DD MMM YYYY">
                <xsl:value-of select=".//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition" />
              </span>
            </td>
            <td>
              <span data-gn-humanize-time="{.//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition}" data-format="DD MMM YYYY">
                <xsl:value-of select=".//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition" />
              </span>
            </td>
          </tr>

      </xsl:when>
      <xsl:when test=".//delwp:pointCloudDetails">
    
          <tr>
            <td>
              <a href="{.//resUrl}" target="blank">
                <xsl:value-of select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title"/>
              </a>
            </td>
            <td><xsl:apply-templates mode="render-value" select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance"/></td>
            <td>
              <xsl:apply-templates mode="render-value" select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:spatialResolution/mri:MD_Resolution/mri:vertical/gco:Distance"/>
            </td>
            <td>
              <xsl:apply-templates mode="render-value" select=".//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:pointDensityActual/gco:Measure"/>
            </td>
            <td><xsl:value-of select=".//mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code"/></td>
            <td><xsl:value-of select="$verticalDatum"/></td>
            <td><xsl:value-of select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat" /></td>
            <td><xsl:value-of select=".//delwp:pointCloudDetails/delwp:MD_PointCloudDetails/delwp:classification/delwp:MD_Classification/delwp:classLevel" /></td>
            <td>
              <span data-gn-humanize-time="{.//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition}" data-format="DD MMM YYYY">
                <xsl:value-of select=".//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition" />
              </span>
            </td>
            <td>
              <span data-gn-humanize-time="{.//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition}" data-format="DD MMM YYYY">
                <xsl:value-of select=".//mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:scope/mcc:MD_Scope/mcc:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition" />
              </span>
            </td>
          </tr>

      </xsl:when>
    </xsl:choose>
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
