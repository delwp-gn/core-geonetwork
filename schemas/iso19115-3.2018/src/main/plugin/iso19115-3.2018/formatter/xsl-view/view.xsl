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
                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gml32="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.1"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"
                xmlns:delwp="https://github.com/geonetwork-delwp/iso19115-3.2018"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-iso19115-3.2018="http://geonetwork-opensource.org/xsl/functions/profiles/iso19115-3.2018"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <!-- This formatter render an ISO19139 record based on the
  editor configuration file.


  The layout is made in 2 modes:
  * render-field taking care of elements (eg. sections, label)
  * render-value taking care of element values (eg. characterString, URL)

  3 levels of priority are defined: 100, 50, none

  -->


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

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/mdb:MD_Metadata"/>

  <xsl:variable name="langId" select="gn-fn-iso19115-3.2018:getLangId($metadata, $language)"/>


  <!-- Ignore some fields displayed in header or in right column -->
  <xsl:template mode="render-field"
                match="mri:graphicOverview|mri:abstract|mdb:identificationInfo/*/mri:citation/*/cit:title"
                priority="2000"/>


  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="mdb:MD_Metadata">
    <xsl:for-each select="mdb:identificationInfo/*/mri:citation/*/cit:title">
      <xsl:call-template name="get-iso19115-3.2018-localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="mdb:MD_Metadata">
    <xsl:for-each select="mdb:identificationInfo/*/mri:abstract">
      <xsl:call-template name="get-iso19115-3.2018-localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataHierarchyLevel" match="mdb:MD_Metadata">
    <xsl:value-of select="mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue"/>
  </xsl:template>

  <xsl:template mode="getOverviews" match="mdb:MD_Metadata">
    <h4>
      <i class="fa fa-fw fa-image">&#160;</i>&#160;
      <span>
        <xsl:value-of select="$schemaStrings/overviews"/>
      </span>
    </h4>

    <xsl:for-each select="mdb:identificationInfo/*/mri:graphicOverview/*">
      <img class="gn-img-thumbnail img-thumbnail center-block"
           src="{mcc:fileName/*|mcc:linkage//cit:linkage/*}"/>

      <xsl:for-each select="mcc:fileDescription|mcc:linkage//cit:description">
        <div class="gn-img-thumbnail-caption">
          <xsl:call-template name="get-iso19115-3.2018-localised">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:call-template>
        </div>
      </xsl:for-each>
      <br/>

    </xsl:for-each>
  </xsl:template>


  <xsl:template mode="getMetadataHeader" match="mdb:MD_Metadata">
    <xsl:variable name="scopeAndName" select="if (mdb:identificationInfo/*/mri:citation//cit:alternateTitle) then
        concat(mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue,': ',mdb:identificationInfo/*/mri:citation//cit:alternateTitle) else
        mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue"/>

    <div class="alert alert-info" style="text-transform:capitalize;text-align:center;font-weight:bold;">
      <xsl:value-of select="$scopeAndName"/>
    </div>

    <div class="alert alert-info"
        itemprop="description"
        itemscope="itemscope"
        itemtype="http://schema.org/description">
      <xsl:for-each select="mdb:identificationInfo/*/mri:abstract">
        <xsl:call-template name="get-iso19115-3.2018-localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </div>


    <!-- Citation -->
    <table class="table">
      <tr class="active">
        <td>
          <div class="pull-left text-muted">
            <i class="fa fa-quote-left fa-2x">&#160;</i>
          </div>
        </td>
        <td>
          <em title="{$schemaStrings/citationProposal-help}">
            <xsl:value-of select="$schemaStrings/citationProposal"/>
          </em><br/>

          <!-- Owners, Custodians or Authors -->
          <xsl:for-each select="mdb:identificationInfo/*/mri:pointOfContact/
                              *[cit:role/*/@codeListValue = ('owner', 'author')]|
                  mdb:identificationInfo/*/mri:citation/*/cit:citedResponsibleParty/
                              *[cit:role/*/@codeListValue = ('owner', 'author')]">
            <xsl:variable name="name"
                          select="normalize-space(.//cit:individual/*/cit:name[1])"/>

            <xsl:value-of select="$name"/>
            <xsl:if test="$name != ''">&#160;(</xsl:if>
            <xsl:value-of select="cit:party/*/cit:name/*"/>
            <xsl:if test="$name">)</xsl:if>
            <xsl:if test="position() != last()">&#160;-&#160;</xsl:if>
          </xsl:for-each>

          <!-- Publication or revision year -->
          <xsl:variable name="publicationDate"
                        select="mdb:identificationInfo/*/mri:citation/*/cit:date/*[
                                cit:dateType/*/@codeListValue = ('publication','revision')]/
                                  cit:date/gco:*"/>

          <xsl:if test="$publicationDate != ''">
            (<xsl:value-of select="substring($publicationDate[1], 1, 4)"/>)
          </xsl:if>

          <!-- Title -->
          <xsl:for-each select="mdb:identificationInfo/*/mri:citation/*/cit:title">
            <p><b>
            <xsl:call-template name="get-iso19115-3.2018-localised">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:call-template>
            </b></p>
          </xsl:for-each>

          <!-- Point of contact -->
          <xsl:for-each select="mdb:identificationInfo/*/mri:pointOfContact/
                              *[cit:role/*/@codeListValue = 'pointOfContact']">
            <p>
            <xsl:value-of select="cit:party/*/cit:name/*"/>
            <xsl:if test="position() != last()">&#160;-&#160;</xsl:if>
            </p>
          </xsl:for-each>

          <!-- Link -->
          <xsl:variable name="url"
                        select="concat($nodeUrl, 'eng/catalog.search', '#', '/metadata/', $metadataUuid)"/>
          <a itemprop="url"
              itemscope="itemscope"
              itemtype="http://schema.org/url" href="{$url}" target="blank">
            <xsl:value-of select="$url"/>
          </a>
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- Data quality section is rendered in a table / Disabled
  <xsl:template mode="render-field"
                match="mdb:dataQualityInfo[1]"
                priority="9999">
    <div data-gn-data-quality-measure-renderer="{$metadataId}"/>
  </xsl:template>

  <xsl:template mode="render-field"
                match="mdb:dataQualityInfo[position() > 1]"
                priority="9999"/>-->


  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field"
                match="*[gco:CharacterString != '']|*[gco:Integer != '']|
                       *[gco:Decimal != '']|*[gco:Boolean != '']|
                       *[gco:Real != '']|*[gco:Measure != '']|*[gco:Length != '']|
                       *[gco:Distance != '']|*[gco:Angle != '']|*[gco:Scale != '']|
                       *[gco:Record != '']|*[gco:RecordType != '']|
                       *[gco:LocalName != '']|*[lan:PT_FreeText != '']|
                       *[gml32:beginPosition != '']|*[gml32:endPosition != '']|
                       *[gco:Date != '']|*[gco:DateTime != '']|*[*/@codeListValue]|*[@codeListValue]|
                       gml32:beginPosition[. != '' or @indeterminatePosition]|gml32:endPosition[. != '' or @indeterminatePosition]"
                priority="500">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <xsl:variable name="elementName" select="if (@codeListValue) then name(..) else name(.)"/>
    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), $elementName, null)"/>
      </dt>
      <dd>
        <xsl:choose>
          <xsl:when test="@codeListValue|*/@codeListValue">
            <!-- Do not render codeList text element. -->
            <xsl:apply-templates mode="render-value" select="@codeListValue|*/@codeListValue"/>
          </xsl:when>
          <xsl:when test="@indeterminatePosition"> <!-- gml times -->
            <span style="text-transform:capitalize;"><xsl:value-of select="@indeterminatePosition"/></span>
          </xsl:when>
          <!-- Display the value for simple field eg. gml32:beginPosition. -->
          <xsl:when test="count(*) = 0 and not(*/@codeListValue)">
            <xsl:apply-templates mode="render-value" select="text()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="render-value" select="*"/>
          </xsl:otherwise>
        </xsl:choose>&#160;
        <xsl:apply-templates mode="render-value" select="@*"/>
      </dd>
    </dl>
  </xsl:template>



  <!-- Some elements are only containers so bypass them -->
  <xsl:template mode="render-field"
                match="*[
                          count(*[name() != 'lan:PT_FreeText']) = 1 and
                          count(*/@codeListValue) = 0
                          ]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <xsl:apply-templates mode="render-value" select="@*"/>
    <xsl:apply-templates mode="render-field" select="*">
      <xsl:with-param name="fieldName" select="$fieldName"/>
    </xsl:apply-templates>
  </xsl:template>


  <!-- Some major sections are boxed -->
  <xsl:template mode="render-field"
                match="*[name() = $configuration/editor/fieldsWithFieldset/name or
                         @gco:isoType = $configuration/editor/fieldsWithFieldset/name]|
                       *[$isFlatMode = false() and not(gco:CharacterString)]">

    <div class="entry name">
      <h4>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:apply-templates mode="render-value"
                             select="@*"/>
      </h4>
      <div class="target">
        <xsl:choose>
          <xsl:when test="count(*) > 0">
            <xsl:apply-templates mode="render-field" select="*"/>
          </xsl:when>
          <xsl:otherwise>
            No information provided.
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
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

  <xsl:template mode="render-field" 
                match="gex:EX_BoundingPolygon"
                priority="100">
    <xsl:variable name="gml31stuff">
      <gml:MultiSurface srsName="EPSG:4326" srsDimension="2">
        <xsl:for-each select=".//gml32:Polygon">
          <gml:surfaceMember>
            <xsl:apply-templates mode="gml32-to-gml" select="."/>
          </gml:surfaceMember>
        </xsl:for-each>
      </gml:MultiSurface>
    </xsl:variable>

    <gn-bounding-polygon polygon-xml="{saxon:serialize($gml31stuff,
                                                         'default-serialize-mode')}"
                         identifier="{generate-id()}"
                         read-only="{true()}"
                         viewer-only="{true()}"
                         style="pointer-events:auto;">
    </gn-bounding-polygon>
    <br/>
    <br/>

  </xsl:template>

  <xsl:template mode="gml32-to-gml" match="@*">
    <xsl:choose>
      <xsl:when test="namespace-uri()='http://www.opengis.net/gml/3.2'">
       <xsl:variable name="name" select="concat('gml:',local-name())"/>
       <xsl:attribute name="{$name}"><xsl:value-of select="."/></xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
       <xsl:if test="name()!='srsName'"><xsl:copy-of select="."/></xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template mode="gml32-to-gml" match="*">
    <xsl:variable name="name" select="concat('gml:',local-name())"/>
    <xsl:element name="{$name}">
      <xsl:apply-templates mode="gml32-to-gml" select="@*"/>
      <xsl:choose>
         <xsl:when test="count(*)>0">
           <xsl:apply-templates mode="gml32-to-gml" select="*"/>
         </xsl:when>
         <xsl:otherwise>
           <xsl:value-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
    </xsl:element> 
  </xsl:template>

  <!-- A contact is displayed with its role as header -->
  <xsl:template mode="render-field"
                match="*[cit:CI_Responsibility]"
                priority="100">
    <xsl:variable name="email">
      <xsl:for-each select="*/cit:party/*/cit:contactInfo//cit:address/*/cit:electronicMailAddress[not(@gco:nilReason)]|*/cit:party//cit:CI_Individual/cit:contactInfo//cit:address/*/cit:electronicMailAddress[not(@gco:nilReason)]">
        <xsl:apply-templates mode="render-value" select="."/>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Display name is <org name> - <individual name> (<position name> -->
    <xsl:variable name="displayName">
      <xsl:choose>
        <xsl:when
                test="*/cit:party/cit:CI_Organisation/cit:name and
                      *//cit:CI_Individual/cit:name">
          <!-- Org name may be multilingual -->
          <xsl:apply-templates mode="render-value"
                               select="*/cit:party/cit:CI_Organisation/cit:name"/>
          -
          <xsl:value-of select="*//cit:CI_Individual/cit:name"/>
          <xsl:if test="*//cit:CI_Individual/cit:positionName">&#160;
            (<xsl:apply-templates mode="render-value"
                                  select="*//cit:CI_Individual/cit:positionName"/>)
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="*/cit:party/cit:CI_Organisation/cit:name|
                                *//cit:CI_Individual/cit:name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="gn-contact" style="pointer-events:auto;">
      <h4>
        <i class="fa fa-envelope">&#160;</i>
        <xsl:apply-templates mode="render-value"
                             select="*/cit:role/*/@codeListValue"/>
      </h4>
      <div class="row">
        <div class="col-md-6">
          <!-- Needs improvements as contact/org are more flexible in iso19115-3 -->
          <address itemprop="author"
                   itemscope="itemscope"
                   itemtype="http://schema.org/Organization">
            <strong>
              <xsl:choose>
                <xsl:when test="normalize-space($email) != ''">
                  <a href="mailto:{normalize-space($email)}">
                    <xsl:value-of select="$displayName"/>&#160;
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$displayName"/>&#160;
                </xsl:otherwise>
              </xsl:choose>
            </strong><br/>
            <xsl:for-each select="*//cit:contactInfo/*">
              <xsl:for-each select="cit:address/*/(
                                          cit:deliveryPoint|cit:city|
                                          cit:administrativeArea|cit:postalCode|cit:country)">
                <div itemprop="address"
                      itemscope="itemscope"
                      itemtype="http://schema.org/PostalAddress">
                  <xsl:if test="normalize-space(.) != ''">
                    <xsl:apply-templates mode="render-value" select="."/><br/>
                  </xsl:if>
                </div>
              </xsl:for-each>
            </xsl:for-each>
          </address>
        </div>
        <div class="col-md-6">
          <xsl:for-each select="*//cit:contactInfo/*">
            <address>
              <xsl:for-each select="cit:phone/*/cit:voice[normalize-space(.) != '']">
                <div itemprop="contactPoint"
                      itemscope="itemscope"
                      itemtype="http://schema.org/ContactPoint">
                  <meta itemprop="contactType"
                        content="{ancestor::cit:Responsibility/*/cit:role/*/@codeListValue}"/>
                  <xsl:variable name="phoneNumber">
                    <xsl:apply-templates mode="render-value" select="."/>
                  </xsl:variable>
                  <i class="fa fa-phone">&#160;</i>
                  <a href="tel:{$phoneNumber}">
                    <xsl:value-of select="$phoneNumber"/>
                  </a>
                </div>
              </xsl:for-each>
              <xsl:for-each select="cit:phone/*/cit:facsimile[normalize-space(.) != '']">
                <xsl:variable name="phoneNumber">
                  <xsl:apply-templates mode="render-value" select="."/>
                </xsl:variable>
                <i class="fa fa-fax">&#160;</i>
                <a href="tel:{normalize-space($phoneNumber)}">
                  <xsl:value-of select="normalize-space($phoneNumber)"/>&#160;
                </a>
              </xsl:for-each>
              <xsl:for-each select="cit:onlineResource/*/cit:linkage[normalize-space(.) != '']">
                <xsl:variable name="linkage">
                  <xsl:apply-templates mode="render-value" select="."/>
                </xsl:variable>
                <i class="fa fa-link">&#160;</i>
                <a href="{normalize-space($linkage)}" target="_blank">
                  <xsl:value-of select="if (../cit:name)
                                        then ../cit:name/* else
                                        normalize-space(linkage)"/>&#160;
                </a>
              </xsl:for-each>
              <xsl:for-each select="cit:hoursOfService">
                <span itemprop="hoursAvailable"
                      itemscope="itemscope"
                      itemtype="http://schema.org/OpeningHoursSpecification">
                  <xsl:apply-templates mode="render-field"
                                       select="."/>
                </span>
              </xsl:for-each>
              <xsl:apply-templates mode="render-field"
                                   select="cit:contactInstructions"/>
            </address>
          </xsl:for-each>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Metadata linkage -->
  <xsl:template mode="render-field"
                match="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code"
                priority="100">
    <dl class="gn-link"
        itemprop="distribution"
        itemscope="itemscope"
        itemtype="http://schema.org/DataDownload">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="*"/>
        <xsl:apply-templates mode="render-value" select="@*"/>

        <a class="btn btn-link" href="{$nodeUrl}api/records/{$metadataId}/formatters/xml" target="_blank">
          <i class="fa fa-file-code-o fa-2x">&#160;</i>
          <span><xsl:value-of select="$schemaStrings/metadataInXML"/></span>
        </a>
      </dd>
    </dl>
  </xsl:template>

  <!-- Linkage -->
  <xsl:template mode="render-field"
                match="*[cit:CI_OnlineResource and */cit:linkage/* != '']"
                priority="100">
    <dl class="gn-link" style="pointer-events:auto;">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:variable name="linkDescription">
          <xsl:apply-templates mode="render-value"
                               select="*/cit:description"/>
        </xsl:variable>
        <a href="{*/cit:linkage/*}" target="_blank">
          <xsl:apply-templates mode="render-value"
                               select="*/cit:name"/>&#160;
        </a>
        <p>
          <xsl:value-of select="normalize-space($linkDescription)"/>
        </p>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="render-field"
                match="mco:MD_LegalConstraints[mco:graphic and mco:reference]"
                priority="100">

    <dl class="gn-link" style="pointer-events:auto;">
      <dt>
        <xsl:value-of select="mco:reference/cit:CI_Citation/cit:title/*"/>
      </dt>
      <dd>
        <ul>
          <xsl:if test="mco:graphic//cit:linkage/gco:CharacterString!=''">
            <li style="list-style-type: none;"><img src="{mco:graphic//cit:linkage/gco:CharacterString}"/></li>
          </xsl:if>
          <li style="list-style-type: none;"><a href="{mco:reference//cit:linkage/gco:CharacterString}" target="_blank">License Text</a></li>
        </ul>
      </dd>
    </dl>
  </xsl:template>

  <!-- Identifier -->
  <xsl:template mode="render-field"
                match="*[(mcc:RS_Identifier or mcc:MD_Identifier) and
                       */mcc:code/gco:CharacterString != '']"
                priority="100">
    <dl class="gn-code">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>

        <xsl:if test="*/mcc:codeSpace">
        <xsl:apply-templates mode="render-value"
                             select="*/mcc:codeSpace"/>
        /
        </xsl:if>
        <xsl:apply-templates mode="render-value"
                               select="*/mcc:code"/>
        <p>
          <xsl:apply-templates mode="render-field"
                               select="*/mcc:authority"/>
        </p>
      </dd>
    </dl>
  </xsl:template>



  <!-- Display thesaurus name and the list of keywords -->
  <xsl:template mode="render-field"
                match="mri:descriptiveKeywords[count(*/mri:keyword) = 0]" priority="200"/>
  <xsl:template mode="render-field"
                match="mri:descriptiveKeywords[
                        */mri:thesaurusName/cit:CI_Citation/cit:title]"
                priority="100">
    <xsl:param name="fieldName"/>

    <dl class="gn-keyword">
      <dt>
        <xsl:choose>
          <xsl:when test="$fieldName != ''"><xsl:value-of select="$fieldName"/></xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="render-value"
                                 select="*/mri:thesaurusName/cit:CI_Citation/cit:title/*"/>
          </xsl:otherwise>
        </xsl:choose>

        <!--<xsl:if test="*/mri:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/mri:type/*/@codeListValue"/>)
        </xsl:if>-->
      </dt>
      <dd>
        <div>
          <ul>
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*/mri:keyword/*"/>
            </li>
          </ul>
        </div>
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="mri:descriptiveKeywords[not(*/mri:thesaurusName/cit:CI_Citation/cit:title)]"
                priority="100">
    <dl class="gn-keyword">
      <dt>
        <xsl:value-of select="$schemaStrings/noThesaurusName"/>
        <xsl:if test="*/mri:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/mri:type/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <div>
          <ul>
            <li>
              <xsl:for-each select="*/mri:keyword">
                <xsl:apply-templates mode="render-value"
                                     select="."/><xsl:if test="position() != last()">, </xsl:if>
              </xsl:for-each>
            </li>
          </ul>
        </div>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="render-field"
                match="mrd:distributionFormat[1]"
                priority="100">
    <dl class="gn-format">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/mrd:distributionFormat">
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*/mrd:formatSpecificationCitation/*/
                                    cit:title"/>
              <p>
              <xsl:apply-templates mode="render-field"
                      select="*/(mrd:amendmentNumber|
                              mrd:fileDecompressionTechnique|
                              mrd:medium|
                              mrd:formatDistributor)"/>
              </p>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="mrd:distributionFormat[position() > 1]"
                priority="100"/>

  <!-- delwp specific stuff -->

  <xsl:template mode="render-field"
                match="mrc:attributeGroup[descendant::delwp:MD_Attribute]"
                priority="100">

    <!-- We need this sequence to get the columns in the order we want them
         Adjust the ordering here to suit user requirements if change is required -->
    <xsl:variable name="aheaders" select="(
       'delwp:name',
       'delwp:obligation',
       'delwp:unique',
       'delwp:dataType',
       'delwp:dataLength',
       'delwp:dataPrecision',
       'delwp:dataScale',
       'delwp:refTabOwnerName',
       'delwp:refTabTableName',
       'delwp:refTabCodeColumnName',
       'delwp:shortColumnName',
       'delwp:definition')"/>

    <dl class="gn-format">
      <dt>
        <!-- <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/> -->
      </dt>
      <dd>
        <!-- <table class="table table-bordered table-striped"> -->
        <!-- striped table somewhat wasteful of space -->
        <table class="table table-bordered">
          <tr>
            <!-- HACK: this crazy variable is necessary because null is somehow context
                 dependent and doesn't like being used inside an iteration on a sequence!
                 Wholly bizarre errors result and the line number reported is wrong! -->
            <xsl:variable name="nullity" select="null"/>
            <xsl:for-each select="$aheaders">
              <xsl:variable name="name" select="."/>
              <th>
                <xsl:value-of select="tr:node-label(tr:create($schema), $name, $nullity)"/>
              </th>
            </xsl:for-each>
          </tr>
          <xsl:for-each select="descendant::delwp:MD_Attribute">
            <tr>
              <xsl:variable name="columns">
                <columns>
                  <xsl:for-each select="*">
                    <td id="{name()}">
                      <xsl:value-of select="."/> 
                    </td>
                  </xsl:for-each>
                </columns>
              </xsl:variable>
              <xsl:for-each select="$aheaders">
                <xsl:variable name="name" select="."/>
                <xsl:choose>
                  <xsl:when test="count($columns/columns/td[@id=$name])=1">
                    <xsl:copy-of select="$columns/columns/td[@id=$name]"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <td></td>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </tr>      
          </xsl:for-each>
        </table>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="render-field"
                match="delwp:classification"
                priority="100">

    <xsl:if test="descendant::delwp:classLevel">
      <xsl:apply-templates mode="render-field" select="descendant::delwp:classLevel"/>
    </xsl:if>

    <xsl:if test="descendant::delwp:classAccuracy">
      <xsl:apply-templates mode="render-field" select="descendant::delwp:classAccuracy"/>
    </xsl:if>

    <dl class="gn-format">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
       <table  class="table table-bordered table-striped">
         <tr>
           <xsl:for-each select="descendant::*[starts-with(name(),'delwp:class')]">
             <th>
               <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
             </th>
           </xsl:for-each>
         </tr>
         <tr>
           <xsl:for-each select="descendant::*[starts-with(name(),'delwp:class')]">
             <td>
               <xsl:value-of select="*"/> 
             </td>
           </xsl:for-each>
         </tr>      
       </table>
      </dd>
    </dl>
  </xsl:template>

  <!-- Date -->
  <xsl:template mode="render-field"
                match="cit:date|mdb:dateInfo|mmi:maintenanceDate"
                priority="100">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:if test="*/cit:dateType/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/cit:dateType/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
          <xsl:apply-templates mode="render-value"
                               select="*/cit:date/*"/>
      </dd>
    </dl>
  </xsl:template>


  <!-- Enumeration -->
  <xsl:template mode="render-field"
                match="mri:topicCategory[1]|
                       mex:MD_ObligationCode[1]|
                       msr:MD_PixelOrientationCode[1]|
                       srv:SV_ParameterDirection[1]|
                       reg:RE_AmendmentType[1]"
                priority="100">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/(mri:topicCategory|mex:MD_ObligationCode|
                msr:MD_PixelOrientationCode|srv:SV_ParameterDirection|
                reg:RE_AmendmentType)">
            <li>
            <xsl:apply-templates mode="render-value"
                                 select="*"/>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template mode="render-field"
                match="mri:topicCategory[position() > 1]|
                       mex:MD_ObligationCode[position() > 1]|
                       msr:MD_PixelOrientationCode[position() > 1]|
                       srv:SV_ParameterDirection[position() > 1]|
                       reg:RE_AmendmentType[position() > 1]"
                priority="100"/>


  <!-- Link to other metadata records -->
  <xsl:template mode="render-field"
                match="*[@uuidref]"
                priority="100">
    <xsl:variable name="nodeName" select="name()"/>

    <!-- Only render the first element of this kind and render a list of
    following siblings. -->
    <xsl:variable name="isFirstOfItsKind"
                  select="count(preceding-sibling::node()[name() = $nodeName]) = 0"/>
    <xsl:if test="$isFirstOfItsKind">
      <dl class="gn-md-associated-resources" style="pointer-events:auto;">
        <dt>
          <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        </dt>
        <dd>
          <ul>
            <xsl:for-each select="parent::node()/*[name() = $nodeName]">
              <li><a href="#uuid={@uuidref}" target="_blank">
                <i class="fa fa-link">&#160;</i>
                <xsl:value-of select="gn-fn-render:getMetadataTitle(@uuidref, $language)"/>
              </a></li>
            </xsl:for-each>
          </ul>
        </dd>
      </dl>
    </xsl:if>
  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field"
                match="*">
    <xsl:param name="fieldName" select="''" as="xs:string"/>
    <xsl:apply-templates mode="render-field">
      <xsl:with-param name="fieldName" select="$fieldName"/>
    </xsl:apply-templates>
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
                       gco:LocalName|gml32:beginPosition|gml32:endPosition">
    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
                      select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a target=''_blank'' href=''$1''&gt;$1&lt;/a&gt;')"/>

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
                match="gco:Distance|gco:Measure">
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
                match="@*"/>

</xsl:stylesheet>
