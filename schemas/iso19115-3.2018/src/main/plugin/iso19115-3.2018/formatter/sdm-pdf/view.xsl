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

  <xsl:variable name="nil"><span color="{$warnColour}">No field match / unsure of field mapping</span></xsl:variable>
  <xsl:variable name="missing"><span color="{$errColour}">Specific info missing from XML</span></xsl:variable>
  <xsl:variable name="redundant"><span>Potentially redundant information</span></xsl:variable>

  <xsl:variable name="prestyle">overflow-x: auto; white-space: pre-wrap; word-wrap: break-word; font-family: Arial, Helvetica, sans-serif; padding: 0; margin: 0;</xsl:variable>

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

    <xsl:variable name="id">
      <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[mcc:authority]/mcc:code" />
    </xsl:variable>

    <xsl:variable name="level">
      <xsl:apply-templates mode="render-value" select="mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue" />
    </xsl:variable>

    <div style="font-family: Arial, Helvetica, sans-serif;">

      <h3>
        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_fullDescriptionReport')"/>
        <xsl:apply-templates mode="render-value" select="$level" /></h3>
      <h1><xsl:apply-templates mode="render-value" select="$title" /></h1>

      <h3>
        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_anzlic')"/>
      </h3>
      <h2><xsl:apply-templates mode="render-value" select="$id" /></h2>

      <!-- Head section -->
      <table cellpadding="5" width="100%" class="identification">
        <tr>
          <td width="30%"  style="margin-bottom: 50px;"><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_title')"/>
          </strong></td>
          <td style="margin-bottom: 50px;"><xsl:apply-templates mode="render-value" select="$title"/></td>
        </tr>
        <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_spatialExtent')"/>
          </strong></td>
          <td><xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[not(gex:temporalElement)]/gex:description"/></td>
        </tr>
        <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_owner')"/>
          </strong></td>
          <td><xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner']/cit:party/cit:CI_Organisation/cit:name"/></td>
        </tr>
        <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_custodian')"/>
          </strong></td>
          <td><xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian']/cit:party/cit:CI_Organisation/cit:name"/></td>
        </tr>
        <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_dataAccess')"/>
          </strong></td>
          <td>
              <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode/@codeListValue" />
              <!-- <br />
              <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_SecurityConstraints/mco:useLimitation"/> -->
            </td>
        </tr>
        <!-- <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_sourceDataScale')"/>
          </strong></td>
          <td><xsl:apply-templates mode="render-value" select="$nil"/></td>
        </tr> -->
        <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_jurisdiction')"/>
          </strong></td>
          <td><xsl:apply-templates mode="render-value" select="*//cit:identifier/mcc:MD_Identifier[mcc:description/gco:CharacterString = 'Jurisdiction ID']/mcc:code"/></td>
        </tr>
        <!-- <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_custodialBusinessUnit')"/>
          </strong></td>
          <td><xsl:apply-templates mode="render-value" select="$missing"/></td>
        </tr>
        <tr>
          <td><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_custodialProgram')"/>
          </strong></td>
          <td><xsl:apply-templates mode="render-value" select="$missing"/></td>
        </tr> -->
        <tr>
          <td style="vertical-align: top;"><strong>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_abstract')"/>
          </strong></td>
          <td style="vertical-align: top;">
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract"/>
            </pre>
          </td>
        </tr>
      </table>
      <hr />

      <!-- Report section -->
      <div class="report">
        <!-- Application layer -->
        <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_purpose')"/>
          </h2>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose"/>
            </pre>
        </div>

        <!-- currency -->
        <div>
          <!-- TODO look up codelists -->
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_dataCurrencyInformation')"/>
          </h2>
          <blockquote>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_dataSetStatus')"/>
            </h3>
            <p>
              <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mcc:MD_ProgressCode/@codeListValue"/>
            </p>  
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_dataCollection')"/>
            </h3>
            <blockquote>
              <h4>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_collectionPeriod')"/>
              </h4>
              <p>
                <xsl:apply-templates mode="render-field" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod" />
              </p> 
              <h4>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_updateFrequency')"/>
              </h4>
              <p>
                <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceAndUpdateFrequency/mmi:MD_MaintenanceFrequencyCode/@codeListValue"/>
              </p>
            </blockquote>
          </blockquote>
        </div>

        <!-- Data information -->
        <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_datasetInformation')"/>
          </h2>
          <blockquote>
            <!-- <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_datasetOrigin')"/>
            </h3>
              <blockquote>
                <h4>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_originality')"/>
                </h4>
                <p><xsl:apply-templates mode="render-value" select="$nil"/></p>
                <h4>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_dataCollectionMethod')"/>
                </h4>
                <pre style="{$prestyle}">
                  <xsl:apply-templates mode="render-value" select="mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
                </pre>
              </blockquote> -->
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_datasetSource')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:resourceLineage/mrl:LI_Lineage/mrl:statement"/>
              <xsl:apply-templates mode="render-value" select="mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description"/>
            </pre>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_datasetProcessingDetails')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:resourceLineage/mrl:LI_Lineage/mrl:processStep/mrl:LI_ProcessStep/mrl:description"/>
            </pre>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_positionalAccuracy')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AbsoluteExternalPositionalAccuracy/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
            </pre>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_attributeAccuracy')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_NonQuantitativeAttributeCorrectness/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
            </pre>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_logicalConsistency')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_ConceptualConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
            </pre>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_completeness')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_CompletenessOmission/mdq:result/mdq:DQ_ConformanceResult/mdq:explanation" />
            </pre>
          </blockquote>

        </div> 

        <!-- access -->
        <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_access')"/>
          </h2>
          <blockquote>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_constraints')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_SecurityConstraints/mco:useLimitation"/>
            </pre>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_storedDataFormat')"/>
            </h3>
            <p><xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title"/></p>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_availableFormatType')"/>
            </h3>
            <p><xsl:apply-templates mode="render-value" select="mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title"/></p>
          </blockquote>
        </div> 

        <!-- quality -->
        <!-- <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_quality')"/>
          </h2>
          <blockquote>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_compliance')"/>
            </h3>
            <blockquote>
              <h4>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_requirements')"/>
              </h4>
              <p><xsl:apply-templates mode="render-value" select="$redundant"/>; <xsl:value-of select="$missing"/></p>
              <h4>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_validations')"/>
              </h4>
              <p><xsl:apply-templates mode="render-value" select="$redundant"/>; <xsl:value-of select="$missing"/></p>
            </blockquote>
          </blockquote>
        </div>  -->

        <!-- search -->
        <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_search')"/>
          </h2>
          <blockquote>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_searchWord')"/>
            </h3>
            <p>
              <!-- TODO breakout to template -->
              <ul>
                <xsl:for-each select="mdb:identificationInfo/mri:MD_DataIdentification//mri:topicCategory">
                  <li><xsl:apply-templates mode="render-value" select="mri:MD_TopicCategoryCode"/></li>
                </xsl:for-each>
              </ul>
            </p>
          </blockquote>
        </div> 

        <!-- further info -->
        <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_furtherInformation')"/>
          </h2>
          <blockquote>
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_supportingDocumentation')"/>
            </h3>
            <pre style="{$prestyle}">
              <xsl:apply-templates mode="render-value" select="mdb:identificationInfo/mri:MD_DataIdentification/mri:supplementalInformation"/>
            </pre>
          </blockquote>
        </div> 

        <!-- history -->
        <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_history')"/>
          </h2>
            <blockquote>
              <xsl:if test="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceDate">
                <h3>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_stages')"/>
                </h3>
                <blockquote>
                  <xsl:for-each select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceDate">
                    <h4>
                      <xsl:apply-templates mode="render-value" select="cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue"/>
                    </h4>
                    <p><xsl:apply-templates mode="render-value" select="cit:CI_Date/cit:date/gco:DateTime"/></p>
                  </xsl:for-each>
                </blockquote>
              </xsl:if>
              <h3>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_lastUpdated')"/>
              </h3>
              <blockquote>
                <h4>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_date')"/>
                </h4>
                <p><xsl:apply-templates mode="render-value" select="mdb:dateInfo[1]/cit:CI_Date/cit:date"/></p>
                <!-- <h4>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_user')"/>
                </h4>
                <p><xsl:apply-templates mode="render-value" select="$missing"/></p> -->
              </blockquote>
            <!-- <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_history')"/>
            </h3>
            <p><xsl:apply-templates mode="render-value" select="$missing"/></p> -->
          
          <h3>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_relatedDatasets')"/>
          </h3>
            <blockquote>
              <xsl:choose>
                <xsl:when test="mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource">
                  <table>
                    <tr>
                      <th>
                        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_name')"/>
                      </th>
                      <th>
                        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_type')"/>
                      </th>
                      <th>
                        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_description')"/>
                      </th>
                    </tr>
                    <xsl:for-each select="mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource">

                      <!-- extract URL -->
                      <xsl:variable name="resLink" select="mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:linkage" />

                      <!-- Extract uuid from URL -->
                      <xsl:variable name="uuid">
                        <xsl:value-of select="normalize-space(substring-after($resLink, '='))" />
                      </xsl:variable>

                      <!-- Create API request from UUID -->
                      <xsl:variable name="uriString">
                        <xsl:value-of select="concat( 'http://localhost:8080/geonetwork/srv/api/records/', $uuid , '/formatters/xml' )" />
                      </xsl:variable>

                      <!-- Create XML document from CSW request -->
                      <xsl:variable name="resourceDoc" select="document( $uriString )" />

                      <!-- <xsl:apply-templates mode="render-field" select="." /> -->
                      <tr>
                        <td>
                          <xsl:choose>
                            <xsl:when test="$resourceDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title">
                              <xsl:value-of select="$resourceDoc//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title" />
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:title" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                        <td><xsl:apply-templates mode="render-value" select="mri:MD_AssociatedResource/mri:associationType/mri:DS_AssociationTypeCode/@codeListValue"/></td>
                        <td>
                          <a href="{mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:linkage}">
                            <xsl:apply-templates mode="render-value" select="mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:description"/>
                          </a>
                        </td>
                      </tr>
                    </xsl:for-each>
                  </table>
                </xsl:when>
                <xsl:otherwise>
                  <p>No related datasets</p>
                </xsl:otherwise>
              </xsl:choose>
            </blockquote>
            <!-- <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_citations')"/>
            </h3>
            <p><xsl:apply-templates mode="render-value" select="$nil"/></p> -->
            <h3>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_additionalMetadataURL')"/>
            </h3>
            <p>http://www.delwp.vic.gov.au/vicmap</p>
          </blockquote>
        </div> 

        <!-- contacts -->
        <div>
          <h2>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_contacts')"/>
          </h2>
          <table class="contacts">
            <tr>
              <th>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_contactName')"/>
              </th>
              <th>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_telephone')"/>
              </th>
              <th>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'fdr_contactRole')"/>
              </th>
            </tr>
            <xsl:for-each select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty[cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual]">
              <xsl:sort select="cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name"/>
                <xsl:apply-templates mode="render-field" select="."/>
            </xsl:for-each>
          </table>
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
      <td><xsl:apply-templates mode="render-value" select="cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name"/></td>
      <td><xsl:apply-templates mode="render-value" select="cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:number"/></td>
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
    <xsl:copy-of select="gn-fn-render:bbox(
                            xs:double(gex:westBoundLongitude/gco:Decimal),
                            xs:double(gex:southBoundLatitude/gco:Decimal),
                            xs:double(gex:eastBoundLongitude/gco:Decimal),
                            xs:double(gex:northBoundLatitude/gco:Decimal))"/>
    <br/>
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

  <!-- Render indeterminatePosition value -->
  <xsl:template mode="render-value"
                match="gml:beginPosition/@indeterminatePosition|gml:endPosition/@indeterminatePosition">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            name(), $id)"/>
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
