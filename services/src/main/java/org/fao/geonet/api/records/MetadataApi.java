/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.api.records;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import jeeves.constants.Jeeves;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.services.ReadWriteController;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.api.API;
import org.fao.geonet.api.ApiParams;
import org.fao.geonet.api.ApiUtils;
import org.fao.geonet.api.exception.NotAllowedException;
import org.fao.geonet.api.exception.ResourceNotFoundException;
import org.fao.geonet.api.records.model.related.FCRelatedMetadataItem.FeatureType.AttributeTable;
import org.fao.geonet.api.records.model.related.FeatureResponse;
import org.fao.geonet.api.records.model.related.RelatedItemType;
import org.fao.geonet.api.records.model.related.RelatedResponse;
import org.fao.geonet.api.tools.i18n.LanguageUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.AbstractMetadata;
import org.fao.geonet.domain.ReservedOperation;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.datamanager.IMetadataUtils;
import org.fao.geonet.kernel.mef.MEFLib;
import org.fao.geonet.kernel.search.LuceneSearcher;
import org.fao.geonet.kernel.search.MetaSearcher;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.search.SearcherType;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Attribute;
import org.jdom.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.stream.Collectors;

import static org.fao.geonet.api.ApiParams.*;
import static org.fao.geonet.kernel.mef.MEFLib.Version.Constants.MEF_V1_ACCEPT_TYPE;
import static org.fao.geonet.kernel.mef.MEFLib.Version.Constants.MEF_V2_ACCEPT_TYPE;

@RequestMapping(value = {
    "/{portal}/api/records",
    "/{portal}/api/" + API.VERSION_0_1 +
        "/records"
})
@Api(value = API_CLASS_RECORD_TAG,
    tags = API_CLASS_RECORD_TAG,
    description = API_CLASS_RECORD_OPS)
@Controller("records")
@ReadWriteController
public class MetadataApi {

    @Autowired
    SchemaManager _schemaManager;

    @Autowired
    LanguageUtils languageUtils;

    @Autowired
    DataManager dataManager;

    @Autowired
    MetadataRepository metadataRepository;

    @Autowired
    IMetadataUtils metadataUtils;

    @Autowired
    GeonetworkDataDirectory dataDirectory;

    @Autowired
    private SearchManager searchManager;

    private ApplicationContext context;

    public synchronized void setApplicationContext(ApplicationContext context) {
        this.context = context;
    }


    @ApiOperation(value = "Get a metadata record",
        notes = "Depending on the accept header the appropriate formatter is used. " +
            "When requesting a ZIP, a MEF version 2 file is returned. " +
            "When requesting HTML, the default formatter is used.",
        nickname = "getRecord")
    @RequestMapping(value = "/{metadataUuid:.+}",
        method = RequestMethod.GET,
        consumes = {
            MediaType.ALL_VALUE
        },
        produces = {
            MediaType.TEXT_HTML_VALUE,
            MediaType.APPLICATION_XML_VALUE,
            MediaType.APPLICATION_XHTML_XML_VALUE,
            MediaType.APPLICATION_JSON_VALUE,
            "application/pdf",
            "application/zip",
            MEF_V1_ACCEPT_TYPE,
            MEF_V2_ACCEPT_TYPE,
            MediaType.ALL_VALUE
        })
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Return the record."),
        @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW),
        @ApiResponse(code = 404, message = ApiParams.API_RESPONSE_RESOURCE_NOT_FOUND)
    })
    public String getRecord(
        @ApiParam(value = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @ApiParam(value = "Accept header should indicate which is the appropriate format " +
            "to return. It could be text/html, application/xml, application/zip, ..." +
            "If no appropriate Accept header found, the XML format is returned.",
            required = true)
        @RequestHeader(
            value = HttpHeaders.ACCEPT,
            defaultValue = MediaType.APPLICATION_XML_VALUE,
            required = false
        )
            String acceptHeader,
        HttpServletResponse response,
        HttpServletRequest request
    )
        throws Exception {
      try (ServiceContext context = ApiUtils.createServiceContext(request)) {
        try {
            ApiUtils.canViewRecord(metadataUuid, context);
        } catch (SecurityException e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new NotAllowedException(ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW);
        }
        List<String> accept = Arrays.asList(acceptHeader.split(","));

        String defaultFormatter = "xsl-view";
        if (accept.contains(MediaType.TEXT_HTML_VALUE)
            || accept.contains(MediaType.APPLICATION_XHTML_XML_VALUE)
            || accept.contains("application/pdf")) {
            return "forward:" + (metadataUuid + "/formatters/" + defaultFormatter);
        } else if (accept.contains(MediaType.APPLICATION_XML_VALUE)
            || accept.contains(MediaType.APPLICATION_JSON_VALUE)) {
            return "forward:" + (metadataUuid + "/formatters/xml");
        } else if (accept.contains("application/zip")
            || accept.contains(MEF_V1_ACCEPT_TYPE)
            || accept.contains(MEF_V2_ACCEPT_TYPE)) {
            return "forward:" + (metadataUuid + "/formatters/zip");
        } else {
            // FIXME this else is never reached because any of the accepted medias match one of the previous if conditions.
            response.setHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_XHTML_XML_VALUE);
            //response.sendRedirect(metadataUuid + "/formatters/" + defaultFormatter);
            return "forward:" + (metadataUuid + "/formatters/" + defaultFormatter);
        }
      }
    }

    @ApiOperation(value = "Get a metadata record as XML or JSON",
        notes = "",
        nickname = "getRecordAsXmlOrJSON")
    @RequestMapping(value =
        {
            "/{metadataUuid}/formatters/xml",
            "/{metadataUuid}/formatters/json"
        },
        method = RequestMethod.GET,
        produces = {
            MediaType.APPLICATION_XML_VALUE,
            MediaType.APPLICATION_JSON_VALUE + "; charset=utf-8"
        })
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Return the record."),
        @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW)
    })
    public
    @ResponseBody
    Object getRecordAsXML(
        @ApiParam(
            value = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @ApiParam(value = "Add XSD schema location based on standard configuration " +
            "(see schema-ident.xml).",
            required = false)
        @RequestParam(required = false, defaultValue = "true")
            boolean addSchemaLocation,
        @ApiParam(value = "Increase record popularity",
            required = false)
        @RequestParam(required = false, defaultValue = "true")
            boolean increasePopularity,
        @ApiParam(value = "Add geonet:info details",
            required = false)
        @RequestParam(required = false, defaultValue = "false")
            boolean withInfo,
        @ApiParam(value = "Download as a file",
            required = false)
        @RequestParam(required = false, defaultValue = "false")
            boolean attachment,
        @ApiParam(value = "Download the approved version",
            required = false, defaultValue = "true")
        @RequestParam(required = false, defaultValue = "true")
            boolean approved,
        @RequestHeader(
            value = HttpHeaders.ACCEPT,
            defaultValue = MediaType.APPLICATION_XML_VALUE
        )
            String acceptHeader,
        HttpServletResponse response,
        HttpServletRequest request
    )
        throws Exception {
      try (ServiceContext context = ApiUtils.createServiceContext(request)) {
        AbstractMetadata metadata;
        try {
            metadata = ApiUtils.canViewRecord(metadataUuid, context);
        } catch (ResourceNotFoundException e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw e;
        } catch (Exception e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new NotAllowedException(ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW);
        }
        try {
            Lib.resource.checkPrivilege(context,
                String.valueOf(metadata.getId()),
                ReservedOperation.view);
        } catch (Exception e) {
            // TODO: i18n
            // TODO: Report exception in JSON format
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new NotAllowedException(ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW);

        }

        if (increasePopularity) {
            dataManager.increasePopularity(context, metadata.getId() + "");
        }


        boolean withValidationErrors = false, keepXlinkAttributes = false, forEditing = false;

        String mdId = String.valueOf(metadata.getId());

        //Here we just care if we need the approved version explicitly.
        //ApiUtils.canViewRecord already filtered draft for non editors.
        if (approved) {
            mdId = String.valueOf(metadataRepository.findOneByUuid(metadata.getUuid()).getId());
        }

        Element xml = withInfo ?
            dataManager.getMetadata(context, mdId, forEditing,
                withValidationErrors, keepXlinkAttributes) :
            dataManager.getMetadataNoInfo(context, mdId + "");

        if (addSchemaLocation) {
            Attribute schemaLocAtt = _schemaManager.getSchemaLocation(
                metadata.getDataInfo().getSchemaId(), context);

            if (schemaLocAtt != null) {
                if (xml.getAttribute(
                    schemaLocAtt.getName(),
                    schemaLocAtt.getNamespace()) == null) {
                    xml.setAttribute(schemaLocAtt);
                    // make sure namespace declaration for schemalocation is present -
                    // remove it first (does nothing if not there) then add it
                    xml.removeNamespaceDeclaration(schemaLocAtt.getNamespace());
                    xml.addNamespaceDeclaration(schemaLocAtt.getNamespace());
                }
            }
        }

        boolean isJson = acceptHeader.contains(MediaType.APPLICATION_JSON_VALUE);

        String mode = (attachment) ? "attachment" : "inline";
        response.setHeader("Content-Disposition", String.format(
            mode + "; filename=\"%s.%s\"",
            metadata.getUuid(),
            isJson ? "json" : "xml"
        ));
        return isJson ? Xml.getJSON(xml) : xml;
      }
    }

    @ApiOperation(
        value = "Get a metadata record as ZIP",
        notes = "Metadata Exchange Format (MEF) is returned. MEF is a ZIP file containing " +
            "the metadata as XML and some others files depending on the version requested. " +
            "See http://geonetwork-opensource.org/manuals/trunk/eng/users/annexes/mef-format.html.",
        nickname = "getRecordAsZip")
    @RequestMapping(value = "/{metadataUuid}/formatters/zip",
        method = RequestMethod.GET,
        consumes = {
            MediaType.ALL_VALUE
        },
        produces = {
            "application/zip",
            MEF_V1_ACCEPT_TYPE,
            MEF_V2_ACCEPT_TYPE
        })
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Return the record."),
        @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW)
    })
    public
    @ResponseBody
    void getRecordAsZip(
        @ApiParam(
            value = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @ApiParam(
            value = "MEF file format.",
            required = false)
        @RequestParam(
            required = false,
            defaultValue = "FULL")
            MEFLib.Format format,
        @ApiParam(
            value = "With related records (parent and service).",
            required = false)
        @RequestParam(
            required = false,
            defaultValue = "true")
            boolean withRelated,
        @ApiParam(
            value = "Resolve XLinks in the records.",
            required = false)
        @RequestParam(
            required = false,
            defaultValue = "true")
            boolean withXLinksResolved,
        @ApiParam(
            value = "Preserve XLink URLs in the records.",
            required = false)
        @RequestParam(
            required = false,
            defaultValue = "false")
            boolean withXLinkAttribute,
        @RequestParam(
            required = false,
            defaultValue = "true")
            boolean addSchemaLocation,
        @ApiParam(value = "Download the approved version",
            required = false)
        @RequestParam(required = false, defaultValue = "true")
            boolean approved,
        @RequestHeader(
            value = HttpHeaders.ACCEPT,
            defaultValue = "application/x-gn-mef-2-zip"
        )
            String acceptHeader,
        HttpServletResponse response,
        HttpServletRequest request
    )
        throws Exception {
      try (ServiceContext context = ApiUtils.createServiceContext(request)) {
        AbstractMetadata metadata;
        try {
            metadata = ApiUtils.canViewRecord(metadataUuid, context);
        } catch (SecurityException e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new NotAllowedException(ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW);
        }
        Path stylePath = dataDirectory.getWebappDir().resolve(Geonet.Path.SCHEMAS);
        Path file = null;

        MEFLib.Version version = MEFLib.Version.find(acceptHeader);
        if (version == MEFLib.Version.V1) {
            // This parameter is deprecated in v2.
            boolean skipUUID = false;

            Integer id = -1;

            if (approved) {
                id = metadataRepository.findOneByUuid(metadataUuid).getId();
            } else {
                id = metadataUtils.findOneByUuid(metadataUuid).getId();
            }

            file = MEFLib.doExport(
                context, id, format.toString(),
                skipUUID, withXLinksResolved, withXLinkAttribute, addSchemaLocation
            );
            response.setContentType(MEFLib.Version.Constants.MEF_V1_ACCEPT_TYPE);
        } else {
            Set<String> tmpUuid = new HashSet<String>();
            tmpUuid.add(metadataUuid);
            // MEF version 2 support multiple metadata record by file.
            if (withRelated) {
                // Adding children in MEF file

                // Creating request for services search
                Element childRequest = new Element("request");
                childRequest.addContent(new Element("parentUuid").setText(metadataUuid));
                childRequest.addContent(new Element("to").setText("1000"));

                // Get children to export - It could be better to use GetRelated service TODO
                Set<String> childs = MetadataUtils.getUuidsToExport(
                    metadataUuid, request, childRequest);
                if (childs.size() != 0) {
                    tmpUuid.addAll(childs);
                }

                // Creating request for services search
                Element servicesRequest = new Element(Jeeves.Elem.REQUEST);
                servicesRequest.addContent(new Element(
                    org.fao.geonet.constants.Params.OPERATES_ON)
                    .setText(metadataUuid));
                servicesRequest.addContent(new Element(
                    org.fao.geonet.constants.Params.TYPE)
                    .setText("service"));

                // Get linked services for export
                Set<String> services = MetadataUtils.getUuidsToExport(
                    metadataUuid, request, servicesRequest);
                if (services.size() != 0) {
                    tmpUuid.addAll(services);
                }
            }
            Log.info(Geonet.MEF, "Building MEF2 file with " + tmpUuid.size()
                + " records.");

            file = MEFLib.doMEF2Export(context, tmpUuid, format.toString(), false, stylePath, withXLinksResolved, withXLinkAttribute, false, addSchemaLocation, approved);

            response.setContentType(MEFLib.Version.Constants.MEF_V2_ACCEPT_TYPE);
        }
        response.setHeader(HttpHeaders.CONTENT_DISPOSITION, String.format(
            "inline; filename=\"%s.zip\"",
            metadata.getUuid()
        ));
        response.setHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(Files.size(file)));
        FileUtils.copyFile(file.toFile(), response.getOutputStream());
      }
    }

    @ApiOperation(value = "Increase record popularity",
        notes = "Used when a view is based on the search results content and does not really access the record. Record is then added to the indexing queue and popularity will be updated soon.",
        nickname = "increaseRecordPopularity")
    @RequestMapping(value = "/{metadataUuid:.+}/popularity",
        method = RequestMethod.POST,
        consumes = {
            MediaType.ALL_VALUE
        })
    @ApiResponses(value = {
        @ApiResponse(code = 201, message = "Popularity updated."),
        @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW),
        @ApiResponse(code = 404, message = ApiParams.API_RESPONSE_RESOURCE_NOT_FOUND)
    })
    @ResponseStatus(HttpStatus.CREATED)
    public void getRecord(
        @ApiParam(value = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        HttpServletRequest request
    )
        throws Exception {
      try (ServiceContext context = ApiUtils.createServiceContext(request)) {
        AbstractMetadata metadata;
        try {
            metadata = ApiUtils.canViewRecord(metadataUuid, context);
        } catch (ResourceNotFoundException e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw e;
        } catch (Exception e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new NotAllowedException(ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW);
        }


        dataManager.increasePopularity(context, metadata.getId() + "");
      }
    }


    @ApiOperation(
        value = "Get record related resources",
        nickname = "getAssociated",
        notes = "Retrieve related services, datasets, onlines, thumbnails, sources, ... " +
            "to this records.<br/>" +
            "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/associating-resources/index.html'>More info</a>")
    @RequestMapping(value = "/{metadataUuid:.+}/related",
        method = RequestMethod.GET,
        produces = {
            MediaType.APPLICATION_XML_VALUE,
            MediaType.APPLICATION_JSON_VALUE
        })
    @ResponseStatus(HttpStatus.OK)
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Return the associated resources."),
        @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW)
    })
    @ResponseBody
    public RelatedResponse getRelated(
        @ApiParam(
            value = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @ApiParam(value = "Type of related resource. If none, all resources are returned.",
            required = false
        )
        @RequestParam(defaultValue = "")
            RelatedItemType[] type,
        @ApiParam(value = "Start offset for paging. Default 1. Only applies to related metadata records (ie. not for thumbnails).",
            required = false
        )
        @RequestParam(defaultValue = "1")
            int start,
        @ApiParam(value = "Number of rows returned. Default 100.")
        @RequestParam(defaultValue = "100")
            int rows,
        HttpServletRequest request) throws Exception {
      try (ServiceContext context = ApiUtils.createServiceContext(request)) {
        AbstractMetadata md;
        try {
            md = ApiUtils.canViewRecord(metadataUuid, context);
        } catch (SecurityException e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new NotAllowedException(ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW);
        }

        String language = languageUtils.iso3code(request.getLocales());

        // TODO PERF: ByPass XSL processing and create response directly
        // At least for related metadata and keep XSL only for links
        Element raw = new Element("root").addContent(Arrays.asList(
            new Element("gui").addContent(Arrays.asList(
                new Element("language").setText(language),
                new Element("url").setText(context.getBaseUrl())
            )),
            MetadataUtils.getRelated(context, md.getId(), md.getUuid(), type, start, start + rows, true)
        ));
        Path relatedXsl = dataDirectory.getWebappDir().resolve("xslt/services/metadata/relation.xsl");

        final Element transform = Xml.transform(raw, relatedXsl);
        RelatedResponse response = (RelatedResponse) Xml.unmarshall(transform, RelatedResponse.class);
        return response;
      }
    }

    @ApiOperation(
        value = "Returns a map to decode attributes in a dataset (from the associated feature catalog)",
        nickname = "getFeatureCatalog",
        notes = "Retrieve related services, datasets, onlines, thumbnails, sources, ... " +
            "to this records.<br/>" +
            "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/associating-resources/index.html'>More info</a>")
    @RequestMapping(value = "/{metadataUuid}/featureCatalog",
        method = RequestMethod.GET,
        produces = {
            MediaType.APPLICATION_XML_VALUE,
            MediaType.APPLICATION_JSON_VALUE
        })
    @ResponseStatus(HttpStatus.OK)
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Return the associated resources."),
        @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW)
    })
    @ResponseBody
    public FeatureResponse getFeatureCatalog(
        @ApiParam(
            value = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        HttpServletRequest request) throws ResourceNotFoundException {

        RelatedItemType[] type = {RelatedItemType.fcats};

        FeatureResponse response = new FeatureResponse();

        Map<String, String[]> decodeMap = new HashMap<>();

        try {
            RelatedResponse related = getRelated(metadataUuid, type, 0, 100, request);

            if (isIncludedAttributeTable(related.getFcats())) {
                for (AttributeTable.Element element : related.getFcats().getItem().get(0).getFeatureType().getAttributeTable().getElement()) {
                    if (StringUtils.isNotBlank(element.getCode())) {
                        if (!decodeMap.containsKey(element.getCode())) {
                            String[] decodedValues = {element.getName(), element.getDefinition()};
                            decodeMap.put(element.getCode(), decodedValues);
                        }
                    } else {
                        if (!decodeMap.containsKey(element.getName())) {
                            String[] decodedValues = {element.getName(), element.getDefinition()};
                            decodeMap.put(element.getName(), decodedValues);
                        }
                    }
                }
            }

            response.setDecodeMap(decodeMap);

            return response;
        } catch (Exception e) {
            Log.error(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new ResourceNotFoundException();
        }

    }

    @ApiOperation(
        value = "Verifies if a metadata field value is in use. Allowed fields: title, altTitle, identifier.",
        nickname = "checkMetadataTitleDuplicated")
    @PostMapping(value = "/{metadataUuid:.+}/checkDuplicatedFieldValue",
        produces = {
            MediaType.APPLICATION_JSON_VALUE
        })
    @ResponseStatus(HttpStatus.OK)
    @PreAuthorize("hasRole('Editor')")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Return if the field value is duplicated or not."),
        @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW),
        @ApiResponse(code = 400, message = "Return if the field name is not allowed or if the value is empty.")
    })
    @ResponseBody
    public ResponseEntity<Boolean> checkDuplicatedFieldValue(
        @ApiParam(value = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
        String metadataUuid,
        @ApiParam(value = "Metadata field information to check",
            required = true)
        @RequestBody DuplicatedValueDto duplicatedValueDto,
        HttpServletRequest request
    )
        throws Exception {
        try {
            ApiUtils.canViewRecord(metadataUuid, request);
        } catch (SecurityException e) {
            Log.debug(API.LOG_MODULE_NAME, e.getMessage(), e);
            throw new NotAllowedException(ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW);
        }

        List<String> validFields = Arrays.asList("_title", "altTitle", "identifier");

        if (!validFields.contains(duplicatedValueDto.getField())) {
            throw new IllegalArgumentException(String.format("A valid Lucene field name is required:", String.join(",", validFields)));
        }

        if (StringUtils.isEmpty(duplicatedValueDto.getValue())) {
            throw new IllegalArgumentException("A non-empty value is required.");
        }


        try (ServiceContext serviceContextToCheckDuplicatedTitles = ApiUtils.createServiceContext(request)) {
            Set<String> uuidsWithSameTitle = retrieveMetadataUuidsFromFieldValue(serviceContextToCheckDuplicatedTitles,
                duplicatedValueDto.getField(), duplicatedValueDto.getValue(), metadataUuid);
            return ResponseEntity.ok(!uuidsWithSameTitle.isEmpty());
        }
    }

    private boolean isIncludedAttributeTable(RelatedResponse.Fcat fcat) {
        return fcat != null
            && fcat.getItem() != null
            && fcat.getItem().size() > 0
            && fcat.getItem().get(0).getFeatureType() != null
            && fcat.getItem().get(0).getFeatureType().getAttributeTable() != null
            && fcat.getItem().get(0).getFeatureType().getAttributeTable().getElement() != null;
    }

    /**
     * Retrieves the list of metadata uuids that have the same value for a Lucene index field.
     *
     * @param serviceContext        ServiceContext.
     * @param fieldName             Lucene field to check.
     * @param fieldValue            Field value to check.
     * @param metadataUuidToExclude Metadata identifier to exclude from the search.
     * @return  A list of metadata uuids that have the same value for a field.
     */
    private Set<String> retrieveMetadataUuidsFromFieldValue(ServiceContext serviceContext,
                                                       String fieldName,
                                                       String fieldValue,
                                                       String metadataUuidToExclude) {

        Set<String> uuids = new HashSet<>();

        Element request = new Element(Jeeves.Elem.REQUEST);
        request.addContent(new Element(fieldName).setText(fieldValue));
        request.addContent(new Element("fast").setText("true"));
        // perform the search and return the results read from the index

        try (MetaSearcher searcher = searchManager.newSearcher(SearcherType.LUCENE, Geonet.File.SEARCH_LUCENE)) {
            ServiceConfig serviceConfig = new ServiceConfig();
            serviceConfig.setValue(Geonet.SearchConfig.SEARCH_IGNORE_PORTAL_FILTER_OPTION, "true");

            ((LuceneSearcher) searcher).searchAdmin(serviceContext, request, serviceConfig);

            if (searcher.getSize() > 0) {
                Map<Integer, AbstractMetadata> allMdInfo = ((LuceneSearcher) searcher).getAllMdInfo(serviceContext, searcher.getSize());

                uuids = allMdInfo.values().stream().map(m -> m.getUuid()).collect(Collectors.toSet());
                uuids.remove(metadataUuidToExclude);
            }

        } catch (Exception ex) {
            Log.error(API.LOG_MODULE_NAME, ex.getMessage(), ex);
        }

        return uuids;
    }

    private static class DuplicatedValueDto {
        private String field;
        private String value;

        public String getField() {
            return field;
        }

        public void setField(String field) {
            this.field = field;
        }

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }
    }
}
