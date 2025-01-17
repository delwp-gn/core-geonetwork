<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0" extension-element-prefixes="saxon"
>
  <!-- Global XSL variables about the metadata record. This should be included for
  service dealing with one metadata record (eg. viewing, editing). -->

  <xsl:include href="base-variables.xsl"/>

  <!-- The metadata record in whatever profile -->
  <xsl:variable name="metadata" select="/root/*[name(.)!='gui' and name(.) != 'request']"/>


  <!-- Get the last gn:info element in case something added it twice to the record
  which may break the editor. In that case, XML view can help fixing the record. -->
  <xsl:variable name="metadataInfo" select="$metadata/gn:info[position() = last()]"/>

  <!-- The metadata schema -->
  <xsl:variable name="schema" select="$metadataInfo/schema"/>
  <xsl:variable name="metadataUuid" select="$metadataInfo/uuid"/>
  <xsl:variable name="metadataId" select="$metadataInfo/id"/>
  <xsl:variable name="isTemplate" select="$metadataInfo/isTemplate"/>

  <xsl:variable name="isService">
    <saxon:call-template name="{concat('get-', $schema, '-is-service')}"/>
  </xsl:variable>

  <xsl:variable name="metadataTitle">
    <saxon:call-template name="{concat('get-', $schema, '-title')}"/>
  </xsl:variable>

  <xsl:variable name="metadataLanguage">
    <saxon:call-template name="{concat('get-', $schema, '-language')}"/>
  </xsl:variable>
  <xsl:variable name="metadataOtherLanguages">
    <saxon:call-template name="{concat('get-', $schema, '-other-languages')}"/>
  </xsl:variable>
  <xsl:variable name="metadataOtherLanguagesAsJson">
    <saxon:call-template name="{concat('get-', $schema, '-other-languages-as-json')}"/>
  </xsl:variable>
  <xsl:variable name="metadataIsMultilingual" select="count($metadataOtherLanguages/*[not(@default)]) > 0"/>

  <!-- The list of thesaurus -->
  <xsl:variable name="listOfThesaurus" select="/root/gui/thesaurus/thesauri"/>


  <!-- The labels, codelists and profiles specific strings -->
  <xsl:variable name="schemaInfo" select="/root/gui/schemas/*[name(.)=$schema]"/>
  <xsl:variable name="labels" select="$schemaInfo/labels"/>
  <xsl:variable name="codelists" select="$schemaInfo/codelists"/>
  <xsl:variable name="strings" select="$schemaInfo/strings"/>

  <xsl:variable name="iso19139schema" select="/root/gui/schemas/iso19139"/>
  <xsl:variable name="iso19139labels" select="$iso19139schema/labels"/>
  <xsl:variable name="iso19139codelists" select="$iso19139schema/codelists"/>
  <xsl:variable name="iso19139strings" select="$iso19139schema/strings"/>

  <xsl:variable name="isEditing"
                select="$service = 'md.edit'
                or $service = 'embedded'
                or $service = 'md.element.add'"/>

  <xsl:variable name="withInlineEditing" select="false()"/>

  <xsl:variable name="withXPath" select="false()"/>

  <xsl:variable name="editorConfig">
    <saxon:call-template name="{concat('get-', $schema, '-configuration')}"/>
  </xsl:variable>

  <xsl:variable name="iso19139EditorConfig">
    <!-- TODO only load for ISO profiles -->
    <xsl:call-template name="get-iso19139-configuration"/>
  </xsl:variable>

  <xsl:variable name="tab">
     <xsl:variable name="tabName"
                select="if (/root/request/currTab)
                        then /root/request/currTab
                        else if (/root/gui/currTab)
                        then /root/gui/currTab
                        else ''"/>
     <xsl:value-of select="if ($tabName='default') then 
                           $editorConfig/editor/views/view[@name='default']/tab[@default]/@id
                           else $tabName"/>
  </xsl:variable>

  <xsl:variable name="currentView" as="node()">

     <xsl:variable name="tabName"
                select="if (/root/request/currTab)
                        then /root/request/currTab
                        else if (/root/gui/currTab)
                        then /root/gui/currTab
                        else ''"/>
      <xsl:variable name="views" select="$editorConfig/editor/views/view[tab/@id = $tab]"/>
      <!-- <xsl:message>SSSSSQ2 <xsl:value-of select="$tabName"/>:<xsl:value-of select="$tab"/>:<xsl:copy-of select="count($views)"/></xsl:message> -->

      <!-- Could be two current views - one could be disabled - so find the one that isn't -->

      <xsl:choose>
        <xsl:when test="count($views)>1">
          <xsl:for-each select="$views">
                <xsl:variable name="isViewDisplayed" as="xs:boolean">
                  <!-- Evaluate XPath expression to
                    see if view should be displayed
                    according to the metadata record or
                    the session information. -->
                  <xsl:variable name="isInRecord" as="xs:boolean">
                    <xsl:choose>
                      <xsl:when test="@displayIfRecord">
                        <saxon:call-template name="{concat('evaluate-', $schema, '-boolean')}">
                          <xsl:with-param name="base" select="$metadata"/>
                          <xsl:with-param name="in" select="concat('/../', @displayIfRecord)"/>
                        </saxon:call-template>
                      </xsl:when>
                      <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>

                  <xsl:variable name="isInServiceInfo" as="xs:boolean">
                    <xsl:choose>
                      <xsl:when test="@displayIfServiceInfo">
                        <saxon:call-template name="{concat('evaluate-', $schema, '-boolean')}">
                          <xsl:with-param name="base" select="$serviceInfo"/>
                          <xsl:with-param name="in" select="concat('/', @displayIfServiceInfo)"/>
                        </saxon:call-template>
                      </xsl:when>
                      <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>

                  <xsl:choose>
                    <xsl:when test="@displayIfServiceInfo and @displayIfRecord">
                      <xsl:value-of select="$isInServiceInfo and $isInRecord"/>
                    </xsl:when>
                    <xsl:when test="@displayIfServiceInfo">
                      <xsl:value-of select="$isInServiceInfo"/>
                    </xsl:when>
                    <xsl:when test="@displayIfRecord">
                      <xsl:value-of select="$isInRecord"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="true()"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <xsl:if test="$isViewDisplayed">
                  <xsl:copy-of select="."/>
                </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$views"/>
        </xsl:otherwise>
      </xsl:choose>

  </xsl:variable>

  <xsl:variable name="viewConfig"
                select="$currentView[tab/@id = $tab]"/>
  <xsl:variable name="tabConfig"
                select="$currentView/tab[@id = $tab]"/>
  <xsl:variable name="thesaurusList"
                select="$currentView[tab/@id = $tab]/thesaurusList"/>

  <xsl:variable name="isFlatMode"
                select="if (/root/request/flat) then /root/request/flat = 'true'
    else $tabConfig/@mode = 'flat'"/>

  <xsl:variable name="resourceContainerDescription"
                select="util:getResourceContainerDescription($metadataInfo/uuid, ($metadataInfo/draft != 'y'))"/>

  <xsl:variable name="resourceManagementExternalProperties"
                select="util:getResourceManagementExternalProperties()"/>

  <xsl:variable name="isDisplayingAttributes"
                select="if (/root/request/displayAttributes)
                        then /root/request/displayAttributes = 'true'
                        else if ($viewConfig/@displayAttributes)
                        then $viewConfig/@displayAttributes = 'true'
                        else false()"/>
  <xsl:variable name="isDisplayingTooltips"
                select="if (/root/request/displayTooltips)
                        then /root/request/displayTooltips = 'true'
                        else if ($viewConfig/@displayTooltips)
                        then $viewConfig/@displayTooltips = 'true'
                        else false()"/>
  <xsl:variable name="displayTooltipsMode"
                select="if (/root/request/displayTooltipsMode)
                        then /root/request/displayTooltipsMode
                        else if ($viewConfig/@displayTooltipsMode)
                        then $viewConfig/@displayTooltipsMode
                        else ''"/>


</xsl:stylesheet>
