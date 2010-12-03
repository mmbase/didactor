package nl.didactor.taglib;

import org.mmbase.bridge.jsp.taglib.ParamHandler;
import org.mmbase.bridge.jsp.taglib.Writer;
import org.mmbase.bridge.jsp.taglib.ContextReferrerTag;
import java.io.IOException;
import java.util.*;
import java.text.*;
import javax.servlet.jsp.tagext.*;
import javax.servlet.jsp.*;
import javax.servlet.Servlet;
import org.mmbase.util.logging.Logger;
import org.mmbase.util.logging.Logging;
import org.mmbase.util.Casting;

/**
 * Translate tag: it will figure out a translation for a given
 * abstract locale.
 * @TODO This is absolutely the same as fmt:message. It should be dropped
 * @author Johannes Verelst &lt;johannes.verelst@eo.nl&gt;
 */
public class TranslateTag extends ContextReferrerTag implements Writer, ParamHandler {
    private static final Logger log = Logging.getLoggerInstance(TranslateTag.class);

    private TreeMap<Integer, Object> parameters = new TreeMap<Integer, Object>();

    @Override
    public void addParameter(String key, Object value) throws JspTagException {
        int k = Integer.parseInt(key);
        parameters.put(k, value);
    }

    // These parameters are set with the different setXyz() methods
    // they may not be manipulated by this class, because that will
    // mess up in case we have tagpooling enabled.
    private String debug;
    private String key;

    private String arg0, arg1, arg2, arg3, arg4;

    public void setKey(String key) {
        if (log.isDebugEnabled()) {
            log.debug("set key to [" + key + "]");
        }
        this.key = key;
    }

    public void setDebug(String value) {
        this.debug = value;
    }

    // It's a giant wtf
    public void setArg0(String value) {
        arg0 = value;
    }

    public void setArg1(String value) {
        arg1 = value;
    }

    public void setArg2(String value) {
        arg2 = value;
    }

    public void setArg3(String value) {
        arg3 = value;
    }

    public void setArg4(String value) {
        arg4 = value;
    }

    private String translateDebug  = "";


    protected CharSequence getTranslation() {
        return new CharSequence() {
                protected String get() {
                    try {
                        TranslateTable.init();

                        if (log.isDebugEnabled()) {
                            log.debug("Getting translation table for locale '" + getLocale() + "'");
                        }

                        TranslateTable tt = new TranslateTable(getLocale());
                        String translation = "";

                        if (key != null) {
                            Integer size = parameters.size() == 0 ? 0 : parameters.lastKey() + 1;
                            String[] params = new String[size];
                            if (size > 0) {
                                for (Integer i = parameters.ceilingKey(0); i != null; i = parameters.higherKey(i)) {
                                    params[i] = Casting.toString(parameters.get(i));
                                }
                            }
                            translation = tt.translate(key, params);
                            if (log.isDebugEnabled()) {
                                log.debug("Translating '" + key + "' to '" + translation + "' " + tt.translate(key));
                            }
                        } else {
                            return "";
                        }

                        if (translation == null || "".equals(translation)) {
                            if ("true".equals(translateDebug)) {
                                translation = "???[" + key + "]???";
                            }
                        }

                        // Save some debugging information about the translation id's that are
                        // used on this page.
                        if ("true".equals(translateDebug)) {
                            List usedTranslations = (List)pageContext.getAttribute("t_usedtrans", PageContext.REQUEST_SCOPE);
                            if (usedTranslations == null) {
                                usedTranslations = new ArrayList();
                            }
                            if (!usedTranslations.contains(key)) {
                                usedTranslations.add(key);
                                pageContext.setAttribute("t_usedtrans", usedTranslations, PageContext.REQUEST_SCOPE);
                            }
                        }

                        return translation;
                    } catch (JspTagException jte ) {
                        log.warn(jte.getMessage(), jte);
                        return key + "[" + jte.getMessage() + "]";
                    }
                }
                public char charAt(int index) {
                    return get().charAt(index);
                }
                public int length() {
                    return get().length();
                }
                public CharSequence subSequence(int start, int end) {
                    return get().subSequence(start, end);
                }

                public String toString() {
                    // this means that it is written to page by ${_} and that consequently there _must_ be a body.
                    // this is needed when body is not buffered.
                    TranslateTag.this.haveBody();
                    return get();
                }
                public int compareTo(Object o) {
                    return toString().compareTo(Casting.toString(o));
                }

            };
    }


    public int doStartTag() throws JspTagException {
        parameters.clear();
        parameters.put(0, arg0);
        parameters.put(1, arg1);
        parameters.put(2, arg2);
        parameters.put(3, arg3);
        parameters.put(4, arg4);
        translateDebug  = "";
        helper.useEscaper(false);
        if (debug == null) {
            // if no debug is given in the tag, then we look it up in the page context
            translateDebug = (String)pageContext.getAttribute("t_debug");
            if (translateDebug == null) {
                translateDebug = "";
            }
        } else {
            // if debug is given in the tag, then we put it in the page context
            pageContext.setAttribute("t_debug", debug);
            translateDebug = debug;
        }
        helper.setValue(getTranslation());
        return EVAL_BODY; // lets try _not_ buffering the body.
    }

    public int doEndTag() throws JspTagException {
        helper.doEndTag();
        return super.doEndTag();
    }

    public int doAfterBody() throws JspException {
        return helper.doAfterBody();
    }
    public void release() {
        key = null;
        debug = null;
    }
}
