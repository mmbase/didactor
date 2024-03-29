/*

This software is OSI Certified Open Source Software.
OSI Certified is a certification mark of the Open Source Initiative.

The license (Mozilla version 1.0) can be read at the MMBase site.
See http://www.MMBase.org/license

*/
package nl.didactor.filter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;

import org.mmbase.bridge.*;
import org.mmbase.bridge.util.*;
import org.mmbase.util.*;
import org.mmbase.util.transformers.*;
import org.mmbase.util.functions.*;
import org.mmbase.storage.search.*;

import org.mmbase.module.core.MMBase;
import org.mmbase.module.core.MMBaseContext;
import org.mmbase.servlet.*;
import org.mmbase.core.event.*;

import org.mmbase.util.logging.*;

/**
 * This files provides e.g. didactor specific stuff which are available and likely needed during
 * most requests.
 * Request scope vars are 'provider', 'education', 'class'.
 *
 * @author Michiel Meeuwissen
 * @version $Id$
 */
public class ProviderFilter implements Filter, MMBaseStarter, NodeEventListener, RelationEventListener {
    private static final Logger log = Logging.getLoggerInstance(ProviderFilter.class);
    private MMBase mmbase;


    public static String USER_KEY = "nl.didactor.user_attributes";
    public static String EDUCATION_KEY = "nl.didactor.education";

    private static Map<String, Map<String, Object>> providerCache = new HashMap<String, Map<String, Object>>();

    public static void clearCache() {
        providerCache.clear();
    }

    /**
     * Initializes the filter
     */
    public void init(javax.servlet.FilterConfig filterConfig) throws ServletException {
        log.info("Starting ProviderFilter with " + filterConfig);
        MMBaseContext.init(filterConfig.getServletContext());
        MMBaseContext.initHtmlRoot();
        // stuff that can take indefinite amount of time (database down and so on) is done in separate thread
        Thread initThread = new MMBaseStartThread(this);
        initThread.start();
    }
    public void setInitException(ServletException se) {
        // never mind, simply, ignore
    }


    public MMBase getMMBase() {
        return mmbase;
    }

    public void setMMBase(MMBase mmb) {
        mmbase = mmb;
        EventManager.getInstance().addEventListener(this);
    }

    /**
     * If something changes in provider or education nodes, clear the caches. Does not happen very
     * often, so more subtlety is not needed.
     */
    public void notify(NodeEvent event) {
        String builder = event.getBuilderName();
        if ("providers".equals(builder) || "educations".equals(builder)) {
            log.info("Clearing provider cache because " + event);
            providerCache.clear();
        }
    }
    public void notify(RelationEvent event) {
        if (event.getRelationDestinationType().equals("urls")) {
            String builder = event.getRelationSourceType();
            if ("providers".equals(builder) || "educations".equals(builder)) {
                log.info("Clearing provider cache because " + event);
                providerCache.clear();
            }
        }
    }

    /**
     * Utility method. In didactor the current provider/education are determined using related url
     * objects to provider and education objects. This method does the needed queries.
     */
    protected static NodeList selectByRelatedUrl(Cloud cloud, NodeList nodes, String url) {
        log.debug("Select for " + url);
        NodeList result = cloud.getCloudContext().createNodeList();
        NodeIterator ni = nodes.nodeIterator();
        while (ni.hasNext()) {
            Node suggestion = ni.nextNode();
            NodeList urls = suggestion.getRelatedNodes("urls");
            NodeIterator ui = urls.nodeIterator();
            while (ui.hasNext()) {
                Node urlNode = ui.nextNode();
                String u = urlNode.getStringValue("url");
                if (u.equals(url)) {
                    log.debug("found "  + suggestion.getNumber());
                    result.add(suggestion);
                }
            }
        }
        return result;
    }


    protected static NodeList selectForUser(Cloud cloud, NodeList nodes) {
        int userNode = cloud.getCloudContext().getAuthentication().getNode(cloud.getUser());
        if (cloud.hasNode(userNode)) {
            Node user = cloud.getNode(userNode);
            Set<Node> related = (Set<Node>) user.getFunctionValue("educations", null).get();

            NodeList result = cloud.getCloudContext().createNodeList();

            for (Node e : nodes) {
                if (related.contains(e)) {
                    result.add(e);
                }
            }
            if (log.isDebugEnabled()) {
                log.debug("Fitered for user " + userNode + " " + related + " -> " + result);
            }

            return result;
        } else {
            log.debug("No such user " + userNode);
            return nodes;
        }
    }


    /**
     * With education, provider a certain locale is defined. Determin it.
     */
    protected static Locale findLocale(Node provider, Node education) {
        Locale locale;
        {
            String ls = provider.getStringValue("locale");
            if (ls == null || "".equals(ls)) {
                locale = provider.getCloud().getCloudContext().getDefaultLocale();
            } else {
                locale = LocalizedString.getLocale(ls);
            }
        }

        String variant = provider.getStringValue("path");
        if (variant != null && (! "".equals(variant)) && education != null) {
            String educationPath = education.getStringValue("path");
            if (educationPath != null && (! "".equals(educationPath))) {
                variant += "_" + educationPath;
            }
        }
        if (variant != null && ! "".equals(variant)) {
            return new Locale(locale.getLanguage(), locale.getCountry(), variant);
        } else {
            return locale;
        }

    }

    public static String getSessionName() {
        return "cloud_mmbase";
    }

    protected static Cloud getCloud(HttpServletRequest req, boolean anonymous) {
        HttpSession session = req.getSession(false); // false: do not create a session, only use it
        if (anonymous || session == null) {
            return ContextProvider.getDefaultCloudContext().getCloud("mmbase");
        } else {
            log.trace("from session");
            Object c = session.getAttribute(getSessionName());
            if (c != null) {
                if (c instanceof Cloud) {
                    Cloud cloud = (Cloud) c;
                    if (cloud.getUser() != null && cloud.getUser().isValid()) {
                        return cloud;
                    } else {
                        log.service("" + c + " is not a valid Cloud");
                        return ContextProvider.getDefaultCloudContext().getCloud("mmbase");
                    }
                } else {
                    log.warn("" + c + " is not a Cloud, but a " + c.getClass());
                    return ContextProvider.getDefaultCloudContext().getCloud("mmbase");
                }
            } else {
                return ContextProvider.getDefaultCloudContext().getCloud("mmbase");
            }
        }
    }



    /**
     * Determin the education
     * @param provider If provider already determined, it can be given.
     * @param
     */
    protected static Node getEducation(Cloud cloud, Node provider, String[] urls) {
        if (log.isDebugEnabled()) {
            log.debug("Finding education for " + provider.getNumber() + " " + Arrays.asList(urls));
        }
        Node education = null;
        NodeList educations;
        if (provider != null) {
            educations = provider.getRelatedNodes("educations");
            if (educations.size() == 0) {
                log.warn("Provider " + provider + " has no education");
                educations = cloud.getNodeManager("educations").getList(null, null, null);
            }
        } else {
            log.warn("No provider, using all educations");
            // there was no provider found yet, so we try educations only
            educations = cloud.getNodeManager("educations").getList(null, null, null);
        }

        {
            NodeList e = educations;
            for (String u : urls) {
                e = selectByRelatedUrl(cloud, e, u);
            }
            if (e.size() > 0) {
                educations = e;
            } else {
                // no match at all, ignore the urls
            }
            log.debug("Filtered for url " + education);
        }

        educations = selectForUser(cloud, educations);

        if (educations.size() > 0) {
            education = educations.getNode(0);
            log.debug("Education matched for user " + education.getNumber());
        }

        if (education == null && provider != null) {
            log.service("No education found");
            // no url related to the educations, simply take one related to the provider if
            // that was found.
            NodeList eds = provider.getRelatedNodes("educations");
            if (eds.size() > 0) {
                education = eds.nodeIterator().nextNode();
            }
        }

        if (education == null && educations.size() > 0) {
            // Still no education found, if there are education at all, simply guess one.
            education = educations.nodeIterator().nextNode();
            log.debug("No education matched, taking " + education.getNumber());
        }

        return education;
    }


    private static final CharTransformer escaper = new Xml(Xml.ESCAPE);

    private static Set<String> NODE_KEYS = new HashSet<String>();
    static {
        //NODE_KEYS.add("class");
        NODE_KEYS.add("classNode");
        NODE_KEYS.add("education");
        NODE_KEYS.add("provider");
    }


    protected static Map<String, Serializable> getUserAttributes(Cloud cloud, HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        Map<String, Serializable> userAttributes;
        if (session == null) {
            log.debug("no session");
            userAttributes = new HashMap<String, Serializable>();
            userAttributes.put("user", 0);
        } else {
            try {
                userAttributes = (Map<String, Serializable>) session.getAttribute(USER_KEY);
            } catch (ClassCastException cce) {
                userAttributes = null;
            }
            if (userAttributes == null) {
                userAttributes = new HashMap<String, Serializable>();
                session.setAttribute(USER_KEY, userAttributes);
            } else {
                if (log.isDebugEnabled()) {
                    log.debug("User attributes from session " + userAttributes);
                }
            }
            int userNumber = cloud.getCloudContext().getAuthentication().getNode(cloud.getUser());
            if (userNumber < 0) {
                userNumber = 0;
            }
            userAttributes.put("user", userNumber);
        }
        return userAttributes;
    }
    protected static boolean isAnonymous(HttpServletRequest req) {
        String sp = req.getServletPath();
        for (String ignoreStart : ANONYMOUS_DIRS) {
            if (sp.startsWith(ignoreStart)) {
                return true;
            }
        }
        return false;

    }
    public static boolean decorateRequest(HttpServletRequest req, HttpServletResponse res) throws IOException {

        boolean anonymous   = isAnonymous(req);
        String serverName   = req.getServerName();
        String contextPath  = req.getContextPath();
        HttpSession session = anonymous ? null : req.getSession(true);

        String parameterEducation = req.getParameter("education");
        if (parameterEducation != null && parameterEducation.length() == 0) {
            parameterEducation = null;
        }
        if (session != null) {
            if (parameterEducation == null) {
                parameterEducation = (String) session.getAttribute(EDUCATION_KEY);
                log.debug("education found from session " + parameterEducation);
            } else {
                session.setAttribute(EDUCATION_KEY, parameterEducation);
                log.debug("education found on request put on session " + parameterEducation + " for " + req + " " + req.getRequestURL());
            }
        }


        String parameterProvider  = req.getParameter("provider");

        log.debug("Provider found from request " + parameterProvider);

        final Cloud cloud = getCloud(req, anonymous);
        final Map<String, Serializable> userAttributes = getUserAttributes(cloud, req);
        final int userNumber = (Integer) userAttributes.get("user");

        String key = serverName + contextPath + ':' + parameterEducation + ':' + parameterProvider  + ":" + cloud.getUser().getIdentifier();


        log.debug("key " + key);
        Map<String, Object> attributes = providerCache.get(key);
        if (attributes == null) {

            String[] urls = {"http://" + serverName + contextPath,
                             "http://" + serverName,
                            //serverName cannot alone consitute a valid URL, but this was the only
                            //implemention in previous versions of Didactor.
                             serverName};

            attributes = new HashMap<String, Object>();

            Node provider = null;
            {
                if (cloud.hasNode(parameterProvider)) {
                    // explicitely stated provider on the URL.
                    // Don't know if that should be maintained.
                    provider = cloud.getNode(parameterProvider);
                } else {
                    NodeList providers = cloud.getNodeManager("providers").getList(null, null, null);
                    if (providers.size() == 0) {
                        // create one
                        log.info("No provider objects found, should at least be one");
                    } else if (providers.size() == 1) {
                        provider = providers.getNode(0);
                        log.debug("Only one provider " + provider.getNumber());
                    } else {
                        // which are we going to use?
                        for (String u : urls) {
                            providers = selectByRelatedUrl(cloud, providers, u);
                            if (providers.size() > 0) {
                                provider = providers.getNode(0);
                                break;
                            }
                        }
                        log.debug("Provider " + provider);

                        // no matching URL object directly related to provider.
                        // Try via education object too.
                    }
                }
            }
            Node defaultEducation = getEducation(cloud, provider, urls);
            Node education =
                parameterEducation != null ?
                cloud.getNode(parameterEducation) : // explicit education always takes preference
                defaultEducation;
            if (log.isDebugEnabled()) {
                log.debug("Default education " + defaultEducation + " education " + education);
            }


            // try determining provider if education found, but not yet a provider
            if (provider == null && education != null) {
                NodeList providers = education.getRelatedNodes("providers");
                if (providers.size() > 0) {
                    provider = providers.nodeIterator().nextNode();
                }
            }


            if (provider == null) {
                NodeList providers = cloud.getNodeManager("providers").getList(null, "number", "descending");
                for (Node prov : providers) {
                    if (prov.getRelations("related", "educations").size() > 0) {
                        provider = prov;
                        break;
                    }
                }
                if (provider == null && providers.size() > 0) {
                    provider = providers.get(0);
                    log.debug("Found provider " + provider.getNumber());
                }
                defaultEducation = getEducation(cloud, provider, urls);
                log.debug("Found education " + defaultEducation);
                education = defaultEducation;

            }

            if (education != null) {
                log.debug("Found education " + education.getNumber());
                attributes.put("education", education.getNumber());
            } else {
                //attributes.put("education", null);
            }

            Locale locale;
            if (provider != null) {
                log.debug("Found provider " + provider.getNumber());
                attributes.put("provider", provider.getNumber());
                locale = findLocale(provider, education);
            } else {
                log.warn("No provider found for " + key);
                attributes.put("provider", null);
                locale = cloud.getLocale();
            }

            attributes.put("javax.servlet.jsp.jstl.fmt.locale.request", locale);
            attributes.put("language", locale.toString());
            attributes.put("locale", locale);

            if (education == null) {
                log.warn("No education found for " + key);
            }

            if (provider == null) {
                req.setAttribute("org.mmbase.servlet.error.message", "No provider found for '" + key + "'");
                if (res != null) {
                    res.sendError(HttpServletResponse.SC_NOT_FOUND, "No provider found for '" + key + "'");
                }
                return false;

            }

            if (education != null) {
                attributes.put("includePath", provider.getNumber() + "," + education.getNumber());
            } else {
                attributes.put("includePath", "" + provider.getNumber());
            }

            attributes.put("referids", "class?,workgroup?,student?,c?" + ((education != null && defaultEducation != null && education.getNumber() != defaultEducation.getNumber()) ? ",education" : ""));


            providerCache.put(key, attributes);

            if (log.isDebugEnabled()) {
                log.debug("Found attributes for " + key + " " + attributes);
            }
        } else {
            if (log.isTraceEnabled()) {
                log.trace("Found attributes for " + key + " " + attributes);
            }
        }


        // Based on the student and the education, try to find the class.
        String c = req.getParameter("class");
        if (c != null) {
            if (cloud.hasNode(c)) {
                userAttributes.put("classNode", cloud.getNode(c).getNumber());
                //userAttributes.put("class", cloud.getNode(c).getNumber()); // not compatible with tomcat 7
            }
        } else {
            Integer userClass = (Integer) userAttributes.get("classNode");
            Integer education = (Integer) attributes.get("education");
            if (userClass != null) {
                // check if this class is consisten with the selected education.
                Node claz = cloud.getNode(userClass);
                if (education == null) {
                    attributes.put("education", claz.getIntValue("education"));
                } else {
                    if (education != claz.getIntValue("education")) {
                        userClass = null;
                        userAttributes.put("classNode", null);
                        //userAttributes.put("class", null);
                    }
                }

            }

            if (userClass == null) {
                if (education != null) {
                    if (userNumber > 0) {
                        try {
                            Node user = cloud.getNode(userNumber);
                            Function fun = user.getFunction("class");
                            Parameters params = fun.createParameters();
                            params.set("education", education);
                            Node claz = (Node) fun.getFunctionValue(params);
                            userAttributes.put("classNode", claz == null ? null : claz.getNumber());
                            //userAttributes.put("class", claz == null ? null : claz.getNumber());
                            log.debug("Found " + (claz == null ? "NULL" : claz.getNumber()) + " for user " + (user == null ? "NULL" : user.getNumber()) + " and education " + (education == null ? "NULL" : education));
                        } catch (NotFoundException nfe) {
                            log.warn(nfe);
                            // never mind
                            userAttributes.put("classNode", null);
                            // userAttributes.put("class", null);
                        }
                    }
                } else {
                    log.warn("No education found");
                }
            } else {
                log.debug("Explicit class in " + userAttributes);
            }
        }

        // copy all attributes to the request.
        for (Map.Entry<String, Object> entry : attributes.entrySet()) {
            String k = entry.getKey();
            Object value = entry.getValue();
            if (NODE_KEYS.contains(k)) {
                if (value != null) {
                    value = Casting.wrap(cloud.getNode("" + value), escaper);
                }
            }
            req.setAttribute(k, value);
        }
        req.setAttribute(org.mmbase.framework.Framework.COMPONENT_INCLUDEPATH_KEY, req.getAttribute("includePath"));

        assert req.getAttribute("provider") != null : "attributes" + attributes;
        for (Map.Entry<String, Serializable> entry : userAttributes.entrySet()) {
            //log.info("Putting " + entry + " " + (entry.getValue() == null ? "" : entry.getValue().getClass()));
            //Casting.wrap(claz, escaper));
            String k = entry.getKey();
            Object value = entry.getValue();
            if (NODE_KEYS.contains(k)) {
                if (value != null) {
                    value = Casting.wrap(cloud.getNode("" + value), escaper);
                }
            }
            req.setAttribute(k, value);
        }
        return true;

    }

    // all kind of generic jsp's can be there. request parameters can be used for something  else.
    private static final String[] IGNORE_DIRS = new String[] {
        "/images/",
        "/attachments",
        "/mmbase/edit/",
        "/mmbase/admin/",
        "/mmbase/kupu/"
    };
    private static final String[] ANONYMOUS_DIRS = new String[] {
        "/core/",
        "/login/"
    };

    /**
     * Filters the request: tries to find a jumper and redirects to this url when found, otherwise the
     * request will be handled somewhere else in the filterchain.
     * @param servletRequest The ServletRequest.
     * @param servletResponse The ServletResponse.
     * @param filterChain The FilterChain.
     */
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws java.io.IOException, ServletException {
        HttpServletResponse res = (HttpServletResponse) response;
        HttpServletRequest req = (HttpServletRequest) request;

        final String sp = req.getServletPath();
        if (sp.endsWith(".css") ||
            sp.endsWith(".png") ||
            sp.endsWith(".gif") ||
            sp.endsWith(".js"))
            {
            filterChain.doFilter(request, response);
            return;
        }

        // if mmbase not yet.503.
        if (mmbase == null) {
            res.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE, this.getClass().getName() + ". MMBase not yet initialized (check mmbase log)");
            return;
        }
        if (! mmbase.getState()) {
            res.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE, this.getClass().getName() + ". MMBase not yet sucessfully initialized (check mmbase log)");
            return;
        }

        for (String ignoreStart : IGNORE_DIRS) {
            if (sp.startsWith(ignoreStart)) {
                log.debug("No need to filter for " + sp + " (because of " + ignoreStart + ")");
                filterChain.doFilter(request, response);
                return;
            }
        }

        if (decorateRequest(req, res)) {

            if (request.getAttribute("includePath") == null) {
                res.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE, "Didactor not yet initialized");
                return;
            }
            HttpSession session = req.getSession(false);
            if (session != null) {
                res.setHeader("X-Didactor-Education", "" + session.getAttribute(EDUCATION_KEY) + "/" + req.getAttribute("education"));
                res.setHeader("X-Didactor-User", "" + session.getAttribute(USER_KEY));
            }
            filterChain.doFilter(request, response);
        }

    }



    public void destroy() {
    }


}
