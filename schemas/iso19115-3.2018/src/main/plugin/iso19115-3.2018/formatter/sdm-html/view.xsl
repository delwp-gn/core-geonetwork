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

  <xsl:variable name="nil"><span style="color: {$warnColour}">No field match / unsure of field mapping</span></xsl:variable>
  <xsl:variable name="missing"><span style="color: {$errColour}">Specific info missing from XML</span></xsl:variable>
  <xsl:variable name="redundant"><span>Potentially redundant information</span></xsl:variable>

  <xsl:variable name="prestyle">overflow-x: auto; white-space: pre-wrap; word-wrap: break-word; font-family: inherit;</xsl:variable>

  <xsl:template mode="renderExport" match="mdb:MD_Metadata">
    <xsl:variable name="title">
      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title" />
    </xsl:variable>

    <xsl:variable name="altTitle">
      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:alternateTitle" />
    </xsl:variable>

    <xsl:variable name="ccLinkage">
      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:reference/cit:CI_Citation/cit:CI_OnlineResource/cit:linkage"/>
    </xsl:variable>

    <xsl:variable name="id">
      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[mcc:authority]/mcc:code" />
    </xsl:variable>

    <xsl:variable name="level">
      <xsl:apply-templates mode="render-value" select="mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue" />
    </xsl:variable>

    <!-- custom styling to override external css -->
    <style type="text/css">
      .listTable tbody {
        vertical-align: top !important;
      }
      .keyColumn {
        white-space:nowrap;
        padding-top: 10px;
        padding-bottom: 10px;
       }
      </style>

    <table id="main">
      <tr>

        <td id="content">
          <div class="yui-skin-sam">

            <div id="viewMetadataTab" class="yui-navset">
              <ul class="yui-nav">
                <li class="selected">
                  <a href="#tab1">
                    <EM>Brief</EM>
                  </a>
                </li>
                <li>
                  <a href="#tab2">
                    <EM>Details</EM>
                  </a>
                </li>
                <li>
                  <a href="#tab1">
                    <EM>Attributes</EM>
                  </a>
                </li>


              </ul>
              <div class="yui-content">

                <!-- TAB 1 -->
                <div>
                  <table class="listTable">
                    <tr class="labelCell">
                      <th class="keyColumn">Metadata Name</th>
                      <th>Descriptions</th>
                    </tr>
                    <tr class="labelCell">
                      <td  class="keyColumn">Resource Name:</td>
                      <td><xsl:value-of select="$altTitle"/></td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Title:</td>
                      <td><xsl:value-of select="$title"/></td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Anzlic ID:</td>
                      <td><xsl:value-of select="$id"/></td>
                    </tr>
                    <!-- <tr class="labelCell">
                      <td class="keyColumn">Cutodial Program:</td>
                      <td><xsl:copy-of select="$missing"/></td>
                    </tr> -->
                    <tr class="labelCell">
                      <td class="keyColumn">Custodian:</td>
                      <td>
                        <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian']/cit:party/cit:CI_Organisation/cit:name"/>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Abstract:</td>
                      <td>
                        <pre style="{$prestyle}">
                          <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract"/>
                        </pre>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Search Words:</td>
                      <td>
                        <xsl:for-each select="mdb:identificationInfo/mri:MD_DataIdentification//mri:topicCategory">
                          <xsl:apply-templates mode="render-value" select="mri:MD_TopicCategoryCode"/>
                          <xsl:if test="position() != last()">,&#160;</xsl:if>
                        </xsl:for-each>
                      </td>
                    </tr>
                    <!-- <tr class="labelCell">
                      <td>Nominal Input Scale</td>
                      <td><xsl:copy-of select="$missing"/></td>
                    </tr> -->
                    <tr class="labelCell">
                      <td class="keyColumn">Publication Date:</td>
                      <td>
                        <xsl:value-of select="format-dateTime(mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date,'[D01] [MNn] [Y0001]')"/>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Dataset Status:</td>
                      <td>
                        <xsl:apply-templates mode="render-value" select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation"/>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Progress:</td>
                      <td>
                        <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mcc:MD_ProgressCode/@codeListValue"/>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td  class="keyColumn">Access Constraint:</td>
                      <td>
                        <div>
                          <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:reference/cit:CI_Citation/cit:title"/>
                          (<a href="{$ccLinkage}" target="blank" >
                            <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:reference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:description"/>
                          </a>)
                        </div>
                        <div>
                          <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_SecurityConstraints/mco:useLimitation"/>
                        </div>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Data Existence:</td>
                      <td>
                        <!-- <xsl:if test="count(mdb:identificationInfo/*/mri:graphicOverview/*) > 0">
                          <xsl:for-each select="mdb:identificationInfo/*/mri:graphicOverview/*">
                            <xsl:variable name="imgUrl">
                              <xsl:value-of select="mcc:MD_BrowseGraphic/mcc:linkage/cit:CI_OnlineResource/cit:linkage/gco:CharacterString" />
                            </xsl:variable>

                            <xsl:value-of select="mcc:MD_BrowseGraphic/mcc:linkage/cit:CI_OnlineResource/cit:linkage/gco:CharacterString" />
                            <xsl:value-of select="mdb:identificationInfo/*/mri:graphicOverview/mcc:MD_BrowseGraphic/mcc:linkage/cit:CI_OnlineResource/cit:linkage/gco:CharacterString" />

                            <div>
                              <img src="{$imgUrl}" style="max-width: 50%;" />
                              <p>
                                <xsl:apply-templates mode="render-value" select="mcc:fileDescription" />
                              </p>
                            </div>
                          </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="count(mdb:identificationInfo/*/mri:graphicOverview/*) = 0"> -->
                          <xsl:apply-templates mode="render-field" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox" />
                        <!-- </xsl:if> -->
                      </td>
                    </tr>
                  </table>
                </div>

                <!-- http://localhost:8080/geonetwork/srv//eng/region.getmap.png?mapsrs=EPSG:3857&width=250&background=settings&geomsrs=EPSG:4326&geom=Polygon((141%20-39,150%20-39,150%20-34,141%20-34,141%20-39)) -->
                <!-- END TAB 1 -->

                <!-- TAB 2 -->
                <div>
                  <table class="listTable">
                    <tr>
                      <th>Metadata Name</th>
                      <th>Descriptions</th>
                    </tr>
                    <tr class="labelCell">
                        <td class="keyColumn">Resource Name:</td>
                        <td><xsl:value-of select="$altTitle"/></td>
                      </tr>
                      <tr class="labelCell">
                        <td class="keyColumn">Title:</td>
                        <td><xsl:value-of select="$title"/></td>
                      </tr>
                      <tr class="labelCell">
                        <td class="keyColumn">Anzlic ID:</td>
                        <td><xsl:value-of select="$id"/></td>
                      </tr>
                      <tr class="labelCell">
                          <td class="keyColumn">Custodian:</td>
                          <td>
                            <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian']/cit:party/cit:CI_Organisation/cit:name"/>
                          </td>
                        </tr>
                      <tr class="labelCell">
                        <td class="keyColumn">Owner:</td>
                        <td><xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner']/cit:party/cit:CI_Organisation/cit:name"/></td>
                      <tr class="labelCell">
                          <td class="keyColumn">Jurisdiction:</td>
                          <td>
                              <xsl:apply-templates mode="render-value" select="*//cit:identifier/mcc:MD_Identifier[mcc:description/gco:CharacterString = 'Jurisdiction ID']/mcc:code"/>
                          </td>
                        </tr>
                      </tr>
                      <tr class="labelCell">
                        <td class="keyColumn">Abstract:</td>
                        <td>
                          <pre style="{$prestyle}">
                            <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract"/>
                          </pre>
                        </td>
                      </tr>
                      <tr>
                        <td class="keyColumn">Search Words:</td>
                        <td>
                          <xsl:for-each select="mdb:identificationInfo/mri:MD_DataIdentification//mri:topicCategory">
                            <xsl:apply-templates mode="render-value" select="mri:MD_TopicCategoryCode"/>
                            <xsl:if test="position() != last()">,&#160;</xsl:if>
                          </xsl:for-each>
                        </td>
                      </tr>
                      <tr class="labelCell">
                        <td class="keyColumn">Purpose:</td>
                        <td><pre style="{$prestyle}">
                            <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose"/>
                          </pre></td>
                      </tr>
                      <tr class="labelCell">
                        <td class="keyColumn">Geographic Extent Polygon:</td>
                        <td>
                          <xsl:for-each select="mdb:identificationInfo/*/mri:graphicOverview/*">

                            <xsl:variable name="imgUrl">
                              <xsl:value-of select="mcc:MD_BrowseGraphic/mcc:linkage/cit:CI_OnlineResource/cit:linkage/gco:CharacterString" />
                            </xsl:variable>

                            <div>
                              <img src="{$imgUrl}" style="max-width: 50%;" />
                              <p>
                                <xsl:apply-templates mode="render-value" select="mcc:fileDescription" />
                              </p>
                            </div>
                          </xsl:for-each>
                          <xsl:apply-templates mode="render-field" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox" />
                        </td>
                      </tr>
                      <tr class="labelCell">
                        <td class="keyColumn">Geographic Bounding Box:</td>
                        <xsl:for-each select="*//gex:geographicElement/gex:EX_GeographicBoundingBox">
                          <xsl:variable name="boxdivstyle">
                            <xsl:text>
                              width: 50px;
                              height: 50px;
                              border: 2px solid #aaa;
                            </xsl:text>
                          </xsl:variable>
                          <xsl:variable name="aligncenter">
                            <xsl:text>
                              text-align: center;
                            </xsl:text>
                          </xsl:variable>
                          <td>

                            <table>
                              <tr>
                                <td></td>
                                <td style="{$aligncenter}"><xsl:apply-templates mode="render-value" select="gex:northBoundLatitude" /></td>
                                <td></td>
                              </tr>
                              <tr>
                                <td ><xsl:apply-templates mode="render-value" select="gex:westBoundLongitude" /></td>
                                <td style="{$boxdivstyle}"></td>
                                <td><xsl:apply-templates mode="render-value" select="gex:eastBoundLongitude" /></td>
                              </tr>
                              <tr>
                                <td></td>
                                <td style="{$aligncenter}"><xsl:apply-templates mode="render-value" select="gex:southBoundLatitude" /></td>
                                <td></td>
                              </tr>
                            </table>

                          </td>
                        </xsl:for-each>
                      </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Beginning to Ending Date:</td>
                      <td>
                        <xsl:apply-templates mode="render-field" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Maintainence and Update Frequency:</td>
                      <td>
                        <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceAndUpdateFrequency/mmi:MD_MaintenanceFrequencyCode/@codeListValue" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Stored Data Format:</td>
                      <td>
                        <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Available Format(s) Types:</td>
                      <td>
                        <xsl:value-of select="mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Positional Accuracy:</td>
                      <td>
                        <pre style="{$prestyle}">
                          <xsl:value-of select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AbsoluteExternalPositionalAccuracy/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
                        </pre>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Attribute Accuracy:</td>
                      <td>
                        <pre style="{$prestyle}">
                          <xsl:value-of select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_NonQuantitativeAttributeCorrectness/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
                        </pre>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Logical Consistency:</td>
                      <td>
                        <pre style="{$prestyle}">
                          <xsl:value-of select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
                        </pre>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Data Source:</td>
                      <td>
                        <pre style="{$prestyle}">
                          <xsl:value-of select="mdb:resourceLineage/mrl:LI_Lineage/mrl:statement" />
                        </pre>
                      </td>
                    </tr>


                    <tr class="labelCell">
                      <td class="keyColumn">Contact Organisation:</td>
                      <td>
                        <xsl:value-of select="mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Contact Position:</td>
                      <td>
                        <xsl:value-of select="mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:positionName" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Address:</td>
                      <td>
                        <xsl:for-each select="mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/*">
                          <xsl:apply-templates mode="render-value" select="." /><br />
                        </xsl:for-each>
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Telephone:</td>
                      <td>
                        <xsl:apply-templates mode="render-value" select="mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:contactInfo/cit:CI_Contact/cit:phone[cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'voice']/cit:CI_Telephone/cit:number" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Facsimile:</td>
                      <td>
                          <xsl:apply-templates mode="render-value" select="mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:contactInfo/cit:CI_Contact/cit:phone[cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'fax']/cit:CI_Telephone/cit:number" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Email Address:</td>
                      <td>
                        <xsl:apply-templates mode="render-value" select="mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Metadata Date:</td>
                      <td>
                        <xsl:apply-templates mode="render-value" select="mdb:dateInfo/cit:CI_Date/cit:date" />
                      </td>
                    </tr>
                    <tr class="labelCell">
                      <td class="keyColumn">Additional Metadata:</td>
                      <td>
                          <pre style="{$prestyle}">
                              <xsl:copy-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:supplementalInformation"/>
                            </pre>
                      </td>
                    </tr>

                  </table>

                </div>
                <!-- END TAB 2 -->

                <!-- TAB 3 -->
                <div>
                  <xsl:choose>
                    <xsl:when test="count(*//mrc:attribute)">
                      <table class="listTable">
                        <tr>
                          <th>Column Name</th>
                          <!-- <th>Column Name 10</th> -->
                          <th>Obligation</th>
                          <th>Unique</th>
                          <th>Data Type</th>
                          <th>Reference Table</th>
                          <th>Comments</th>
                        </tr>
                        <xsl:for-each select="*//mrc:attribute">
                          <tr>
                            <td>
                              <xsl:value-of select="mrc:MD_SampleDimension/mrc:otherProperty/gco:Record/delwp:MD_Attribute/delwp:name" />
                            </td>
                            <!-- <td>
                              -
                            </td> -->
                            <td>
                              <xsl:value-of select="mrc:MD_SampleDimension/mrc:otherProperty/gco:Record/delwp:MD_Attribute/delwp:obligation" />
                            </td>
                            <td>
                              <xsl:value-of select="mrc:MD_SampleDimension/mrc:otherProperty/gco:Record/delwp:MD_Attribute/delwp:unique" />
                            </td>
                            <td>
                              <xsl:value-of select="mrc:MD_SampleDimension/mrc:otherProperty/gco:Record/delwp:MD_Attribute/delwp:dataType" />
                            </td>
                            <td>
                              <xsl:value-of select="mrc:MD_SampleDimension/mrc:otherProperty/gco:Record/delwp:MD_Attribute/delwp:refTabTableName" />
                            </td>
                            <td>
                              <xsl:value-of select="mrc:MD_SampleDimension/mrc:otherProperty/gco:Record/delwp:MD_Attribute/delwp:comments" />
                            </td>
                          </tr>
                        </xsl:for-each>
                      </table>

                    </xsl:when>
                    <xsl:otherwise>
                      <pre>No attributes</pre>
                    </xsl:otherwise>
                  </xsl:choose>


                </div>
                <!-- END TAB 3 -->
              </div>

            </div>
          </div>


        </td>
      </tr>
    </table>

    <!--
          Embed JS directly into HTML body
          unparsed-text() reads the file,
          replace() escapes weird line-ending chars,
          (as here: https://www.data2type.de/en/xml-xslt-xslfo/xslt/xslt-xpath-function-reference/alphabetical-xslt-and-xpath-reference/unparsed-text/ ),
          disable-output-escaping="yes" attribute on xsl:value-of let's us keep the &, < and > characters from the minified JS
    -->
    <script type="text/javascript">
      <xsl:value-of select="replace( unparsed-text(concat(/root/gui/baseUrl, '/images/js/yahoo-dom-event.js'), 'iso-8859-1'), '[&#xD;&#xA;]+', '&#xA;' )" disable-output-escaping="yes"/>
    </script>
    <script type="text/javascript">
      <xsl:value-of select="replace( unparsed-text(concat(/root/gui/baseUrl, '/images/js/element-beta-min.js'), 'iso-8859-1'), '[&#xD;&#xA;]+', '&#xA;' )" disable-output-escaping="yes"/>
    </script>
    <script type="text/javascript">
      <xsl:value-of select="replace( unparsed-text(concat(/root/gui/baseUrl, '/images/js/tabview-min.js'), 'iso-8859-1'), '[&#xD;&#xA;]+', '&#xA;' )" disable-output-escaping="yes"/>
    </script>

    <script type="text/javascript">
      //  restores the tabs in browsers which support them
      //  Chrome refuses to run any script so the tabs will not work in that browser
      function enabletabs()
      {
        (function() {
          var tabView = new YAHOO.widget.TabView('viewMetadataTab');
          console.log('tabs created');
        })();

        var f = document.getElementById("tab1");
        if (f) f.href="#tab1";
        f = document.getElementById("tab2");
        if (f) f.href="#tab2";
        f = document.getElementById("tab3");
        if (f) f.href="#tab3";
        console.log('tabs enabled');
      }

      window.onload = enabletabs;

    </script>

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
        <xsl:copy-of select="'https://dev-metashare.maps.vic.gov.au/geonetwork/srv/eng/region.getmap.png?mapsrs=EPSG:3857&amp;width=500&amp;background=osm&amp;geomsrs=EPSG:4326&amp;geom='" />
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

    <img src="{concat( translate($urlbase, ' ', '') , $bbox )}"/>
    <br/>

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
