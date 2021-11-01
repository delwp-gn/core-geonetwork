/*
 * Copyright (C) 2001-2021 Food and Agriculture Organization of the
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

package org.fao.geonet.api;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Arrays;
import java.util.Iterator;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.Set;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.api.exception.ResourceNotFoundException;
import org.fao.geonet.api.tools.i18n.LanguageUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.AbstractMetadata;
import org.fao.geonet.domain.ReservedOperation;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.SelectionManager;
import org.fao.geonet.kernel.datamanager.IMetadataUtils;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.utils.GeonetHttpRequestFactory;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.XmlRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.dao.InvalidDataAccessApiUsageException;
import org.springframework.util.StringUtils;

import com.google.common.collect.Sets;

import jeeves.constants.Jeeves;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.server.dispatchers.ServiceManager;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;

/**
 * API utilities mainly to deal with parameters.
 *
 * Many of these methods assume a service context is available as a thread locale,
 * see {@link #createServiceContext(HttpServletRequest)} methods for details.
 */
public class ApiUtils {

    @Autowired
    static
    LanguageUtils languageUtils;

    /**
     * Return a set of UUIDs based on the input UUIDs array or based on the current selection.
     */
    static public Set<String> getUuidsParameterOrSelection(String[] uuids, String bucket, UserSession session) {
        final Set<String> setOfUuidsToEdit;
        if (uuids == null) {
            if (bucket == null) {
                bucket = SelectionManager.SELECTION_METADATA;
            }
            SelectionManager selectionManager =
                SelectionManager.getManager(session);
            synchronized (
                selectionManager.getSelection(bucket)) {
                final Set<String> selection = selectionManager.getSelection(bucket);
                setOfUuidsToEdit = Sets.newHashSet(selection);
            }
        } else {
            setOfUuidsToEdit = Sets.newHashSet(Arrays.asList(uuids));
        }
        if (setOfUuidsToEdit.size() == 0) {
            // TODO: i18n
            throw new IllegalArgumentException(
                "At least one record should be defined or selected for analysis.");
        }
        return setOfUuidsToEdit;
    }

    /**
     * Search if a record match the UUID on its UUID or an internal identifier
     */
    public static String getInternalId(String uuidOrInternalId, Boolean approved)
        throws Exception {

        IMetadataUtils metadataUtils = ApplicationContextHolder.get().getBean(IMetadataUtils.class);
        String id = String.valueOf(metadataUtils.findOneByUuid(uuidOrInternalId).getId());

        if (StringUtils.isEmpty(id)) {
            //It wasn't a UUID
            id = String.valueOf(metadataUtils.findOne(uuidOrInternalId).getId());
        } else if (approved) {
            //It was a UUID, check if draft or approved version
            id = String.valueOf(ApplicationContextHolder.get().getBean(MetadataRepository.class)
                .findOneByUuid(uuidOrInternalId).getId());
        }

        if (StringUtils.isEmpty(id)) {
            throw new ResourceNotFoundException(String.format(
                "Record with UUID '%s' not found in this catalog",
                uuidOrInternalId));
        }
        return id;
    }

    /**
     * Fixes the uri fragment portion (that the part after the "#") so it is properly encoded.
     *
     * <ul>
     * <li>http://www.thesaurus.gc.ca/concept/#Offshore area        -->   http://www.thesaurus.gc.ca/concept/#Offshore%20area</li>
     * <li>http://www.thesaurus.gc.ca/concept/#AIDS (disease)       -->   http://www.thesaurus.gc.ca/concept/#AIDS%20%28disease%29</li>
     * <li>http://www.thesaurus.gc.ca/concept/#Alzheimer's disease  -->   http://www.thesaurus.gc.ca/concept/#Alzheimer%27s%20disease</li>
     * </ul>
     *
     * Includes some special case handling for spaces and ":"
     */
    //TODO: there could be other special handling for special cases in the future
    public static String fixURIFragment(String uri) throws UnsupportedEncodingException {
        String[] parts = uri.split("#");
        if (parts.length >1) {
            parts[parts.length - 1] = parts[parts.length - 1].replace("+", " ");
            parts[parts.length - 1] = URLEncoder.encode(parts[parts.length - 1], "UTF-8");
            parts[parts.length - 1] = parts[parts.length - 1].replace("+", "%20");
            parts[parts.length - 1] = parts[parts.length - 1].replace("%3A", ":");
        }
        return String.join("#",parts);
    }

    /**
     * Look up metadata record.
     *
     * @param uuidOrInternalId
     * @return record
     * @throws ResourceNotFoundException
     */
    public static AbstractMetadata getRecord(String uuidOrInternalId) throws ResourceNotFoundException {
        IMetadataUtils metadataRepository = ApplicationContextHolder.get().getBean(IMetadataUtils.class);
        AbstractMetadata metadata = null;

        try {
            metadata = metadataRepository.findOneByUuid(uuidOrInternalId);
            if (metadata != null) {
                Log.trace(Geonet.DATA_MANAGER, "ApiUtils.getRecord(" + uuidOrInternalId + ") -> " + metadata);
                return metadata;
            }
        } catch (IncorrectResultSizeDataAccessException e) {
            Log.warning(Geonet.GEONETWORK, String.format(
                "More than one record found with UUID '%s'. Error is '%s'.",
                uuidOrInternalId, e.getMessage()));
        }

        try {
            Log.trace(Geonet.DATA_MANAGER, uuidOrInternalId + " not recognized as UUID. Trying ID.");
            metadata = metadataRepository.findOne(uuidOrInternalId);
            if (metadata != null) {
                if (Log.isTraceEnabled(Geonet.DATA_MANAGER)) {
                    Log.trace(Geonet.DATA_MANAGER, "ApiUtils.getRecord(" + uuidOrInternalId + ") -> " + metadata);
                }
                return metadata;
            }
        } catch (NumberFormatException e) {
        } catch (InvalidDataAccessApiUsageException e) {
        }

        Log.trace(Geonet.DATA_MANAGER, "Record identified by " + uuidOrInternalId + " not found.");
        throw new ResourceNotFoundException(String.format("Record with UUID '%s' not found in this catalog", uuidOrInternalId));
    }

    /**
     * Return the Jeeves user session.
     * <p>
     * If session is null, it's probably a bot due to {@link AllRequestsInterceptor#createSessionForAllButNotCrawlers(HttpServletRequest)}.
     * In such case return an exception.
     *
     * @param httpSession HTTP session
     * @return Jeeves user session
     */
    static public UserSession getUserSession(HttpSession httpSession) {
        if (httpSession == null) {
            throw new SecurityException("The service requested is not available for crawlers. HTTP session is not activated for bots.");
        }
        UserSession userSession = (UserSession) httpSession.getAttribute(Jeeves.Elem.SESSION);
        if (userSession == null) {
            throw new SecurityException("The service requested is not available for crawlers. Catalog session is null.");
        }
        return userSession;
    }

    /**
     * If you really need a ServiceContext use this. Try to avoid in order to reduce dependency on
     * Jeeves.
     * <p>
     * This method has a side effect of setting the created service context for the current thread.
     * If you create a service context you are responsible for managing on the current thread and any cleanup:
     * </p>
     * Using auto closable:
     * <pre><code>
     * try(ServiceContext context = ApiUtils.createServiceContext(request, iso3langCode)){
     *    ...
     * }
     * </code></pre>
     *
     * Or manually:
     * <pre><code>
     * ServiceContext context = ApiUtils.createServiceContext(request, iso3langCode);
     * try {
     *     ...
     * }
     * finally {
     *     context.clearAsThreadLocal();
     *     context.clear();
     * }
     * </code></pre>
     * @param request
     * @return new sevice context, assigned to the current thread
     */
    static public ServiceContext createServiceContext(HttpServletRequest request) {
        String iso3langCode = ApplicationContextHolder.get().getBean(LanguageUtils.class)
            .iso3code(request.getLocales());
        return createServiceContext(request, iso3langCode);
    }

    /**
     * If you really need a ServiceContext use this. Try to avoid in order to reduce dependency on
     * Jeeves.
     *
     * This method has a side effect of setting the created service context for the current thread.
     * If you create a service context you are responsible for managing on the current thread and any cleanup:
     *
     * Using auto closable:
     * <pre><code>
     * try(ServiceContext context = ApiUtils.createServiceContext(request, iso3langCode)){
     *    ...
     * }
     * </code></pre>
     *
     * Or manually:
     * <pre><code>
     * ServiceContext context = ApiUtils.createServiceContext(request, iso3langCode);
     * try {
     *     ...
     * }
     * finally {
     *     context.clearAsThreadLocal();
     *     context.clear();
     * }
     * </code></pre>
     *
     * @param request
     * @param iso3langCode
     * @return new sevice context, assigned to the current thread
     */
    static public ServiceContext createServiceContext(HttpServletRequest request, String iso3langCode) {
        ServiceManager serviceManager = ApplicationContextHolder.get().getBean(ServiceManager.class);
        String contextName = "Api"+request.getPathInfo();
        ServiceContext serviceContext = serviceManager.createServiceContext(contextName, iso3langCode, request);
        serviceContext.setAsThreadLocal();
        return serviceContext;
    }

    /**
     * Generate the filesize of files in a directory in KiB.
     *
     * @param lDir directory location
     * @return size of files in directory in KiB
     * @throws IOException
     */
    public static long sizeOfDirectory(Path lDir) throws IOException {
        final long[] size = new long[]{0};
        Files.walkFileTree(lDir, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                size[0] += Files.size(file);
                return FileVisitResult.CONTINUE;
            }
        });

        return size[0] / 1024; // convert to KiB
    }

    /**
     * Download xml file into temporary location.
     *
     * @param url
     * @return temporary file
     * @throws IOException
     * @throws URISyntaxException
     */
    public static Path downloadUrlInTemp(String url) throws IOException, URISyntaxException {

        URI uri = new URI(url);
        Path file = Files.createTempFile("file-from-url", ".xml");

        ApplicationContext applicationContext = ApplicationContextHolder.get();
        XmlRequest httpReq = applicationContext
            .getBean(GeonetHttpRequestFactory.class)
            .createXmlRequest(uri.toURL());

        httpReq.setAddress(uri.getPath());

        Lib.net.setupProxy(applicationContext.getBean(SettingManager.class), httpReq);

        httpReq.executeLarge(file);
        return file;
    }

    /**
     * Check if the current user can edit this record.
     *
     * This method creates a temporary service context using the provided request to check record access,
     * if you have a service context already please use {@link #canEditRecord(String, ServiceContext)}.
     *
     * @param metadataUuid Look up metadata record
     * @param request Request to identify current user
     * @return metadata record
     * @throws SecurityException if user is not allowed to edit
     */
    static public AbstractMetadata canEditRecord(String metadataUuid, HttpServletRequest request) throws Exception {
        ServiceContext previous = ServiceContext.get();
        if (previous != null) previous.clearAsThreadLocal();

        try (ServiceContext context = createServiceContext(request)) {
            return canEditRecord(metadataUuid, context);
        }
        finally {
            if (previous != null) previous.setAsThreadLocal();
        }
    }

    /**
     * Check if the current user can edit this record.
     *
     * @param metadataUuid Look up metadata record
     * @return metadata record
     * @throws SecurityException if user is not allowed to edit
     */
    static public AbstractMetadata canEditRecord(String metadataUuid, ServiceContext context) throws Exception {
        AbstractMetadata metadata = getRecord(metadataUuid);
        AccessManager accessManager = context.getBean(AccessManager.class);
        if (!accessManager.canEdit(context, String.valueOf(metadata.getId()))) {
            throw new SecurityException(String.format(
                "User %s can't edit record with UUID %s", context.userName(), metadataUuid));
        }
        return metadata;
    }

    /**
     * Check if the current user can review this record.
     *
     * This method creates a temporary service context using the provided request to check record access,
     * if you have a service context already please use {@link #canReviewRecord(String, ServiceContext)}.
     *
     * @param metadataUuid Look up metadata record
     * @param request Request to identify current user
     * @return metadata record
     * @throws SecurityException if user is not allowed to review
     * @deprecated Not presently used
     */
    static public AbstractMetadata canReviewRecord(String metadataUuid, HttpServletRequest request) throws Exception {
        ServiceContext previous = ServiceContext.get();
        if (previous != null) previous.clearAsThreadLocal();

        try (ServiceContext context = createServiceContext(request)) {
            return canReviewRecord(metadataUuid,context);
        }
        finally {
            if (previous != null) previous.setAsThreadLocal();
        }
    }

    /**
     * Check if the current user can review this record.
     *
     * @param metadataUuid Look up metadata record
     * @return metadata record
     * @throws SecurityException if user is not allowed to review
     */
    static public AbstractMetadata canReviewRecord(String metadataUuid,ServiceContext context) throws Exception {
        AbstractMetadata metadata = getRecord(metadataUuid);
        AccessManager accessManager = context.getBean(AccessManager.class);
        if (!accessManager.canReview(context, String.valueOf(metadata.getId()))) {
            throw new SecurityException(String.format(
                "User %s can't review or edit record with UUID %s", context.userName(), metadataUuid));
        }
        return metadata;
    }

    /**
     * Check if the current user can change status of this record.
     *
     * This method creates a temporary service context using the provided request to check record access,
     * if you have a service context already please use {@link #canChangeStatusRecord(String, ServiceContext)}.
     *
     * @param metadataUuid Look up metadata record
     * @param request Request to identify current user
     * @return metadata record
     * @throws SecurityException if user is not allowed to review
     * @deprecated Not presently used
     */
    static public AbstractMetadata canChangeStatusRecord(String metadataUuid, HttpServletRequest request) throws Exception {
        ServiceContext previous = ServiceContext.get();
        if (previous != null) previous.clearAsThreadLocal();

        try (ServiceContext context = createServiceContext(request)) {
            return canChangeStatusRecord(metadataUuid,context);
        }
        finally {
            if (previous != null) previous.setAsThreadLocal();
        }
    }

    /**
     * Check if the current user can change status of this record.
     *
     * @param metadataUuid Look up metadata record
     * @return metadata record
     * @throws SecurityException if user is not allowed to change status
     */
    static public AbstractMetadata canChangeStatusRecord(String metadataUuid, ServiceContext context) throws Exception {
        AbstractMetadata metadata = getRecord(metadataUuid);
        AccessManager accessManager = context.getBean(AccessManager.class);
        if (!accessManager.canChangeStatus(context, String.valueOf(metadata.getId()))) {
            throw new SecurityException(String.format(
                "User %s can't change status of record with UUID %s", context.userName(), metadataUuid));
        }
        return metadata;
    }

    /**
     * Check if the current user can view this record.
     *
     * This method creates a temporary service context using the provided request to check record access,
     * if you have a service context already please use {@link #canViewRecord(String, ServiceContext)}.
     *
     * @param metadataUuid Look up metadata record
     * @param request Request to identify current user
     * @return metadata record
     * @throws SecurityException if user is not allowed to view
     */
    public static AbstractMetadata canViewRecord(String metadataUuid, HttpServletRequest request) throws Exception {
        ServiceContext previous = ServiceContext.get();
        if (previous != null) previous.clearAsThreadLocal();

        try (ServiceContext context = createServiceContext(request)) {
            return canViewRecord(metadataUuid,context);
        }
        finally {
            if (previous != null) previous.setAsThreadLocal();
        }
    }
    /**
     * Check if the current user can view this record.
     *
     * @param metadataUuid Look up metadata record
     * @return metadata record
     * @throws SecurityException if user is not allowed to view
     */
    public static AbstractMetadata canViewRecord(String metadataUuid, ServiceContext context) throws Exception {
        AbstractMetadata metadata = getRecord(metadataUuid);
        try {
            Lib.resource.checkPrivilege(context, String.valueOf(metadata.getId()), ReservedOperation.view);
        } catch (Exception e) {
            throw new SecurityException(String.format(
                "User %s can't view record with UUID %s", context.userName(), metadataUuid));
        }
        return metadata;
    }

    /**
     * Create a favicon from the provided image.
     *
     * @param img
     * @param outFile
     * @throws IOException
     */
    public static void createFavicon(Image img, Path outFile) throws IOException {
        int width = 32;
        int height = 32;
        String type = "png";

        Image thumb = img.getScaledInstance(width, height,
            BufferedImage.SCALE_SMOOTH);

        BufferedImage bimg = new BufferedImage(width, height,
            BufferedImage.TRANSLUCENT);

        Graphics2D g = bimg.createGraphics();
        g.drawImage(thumb, 0, 0, null);
        g.dispose();

        try (OutputStream out = Files.newOutputStream(outFile)) {
            ImageIO.write(bimg, type, out);
        }
    }

    /**
     * Process request validation, returning an string with the validation errors.
     *
     * @param bindingResult
     * @param messages
     */
    public static String processRequestValidation(BindingResult bindingResult, ResourceBundle messages) {
        if (bindingResult.hasErrors()) {
            java.util.List<ObjectError> errorList = bindingResult.getAllErrors();

            StringBuilder sb = new StringBuilder();
            Iterator<ObjectError> it = errorList.iterator();
            while (it.hasNext()) {
                ObjectError err = it.next();
                String msg = "";
                for(int i = 0; i < err.getCodes().length; i++) {
                    try {
                        msg = messages.getString(err.getCodes()[i]);

                        if (!StringUtils.isEmpty(msg)) {
                            break;
                        }
                    } catch (MissingResourceException ex) {
                        // Ignore
                    }
                }

                if (StringUtils.isEmpty(msg)) {
                    msg = err.getDefaultMessage();
                }

                sb.append(msg);
                if (it.hasNext()) {
                    sb.append(", ");
                }
            }

            return sb.toString();
        } else {
            return "";
        }
    }
}
