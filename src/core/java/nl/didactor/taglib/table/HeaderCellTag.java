package nl.didactor.taglib.table;

import java.io.IOException;
import java.util.*;
import java.text.*;
import javax.servlet.jsp.tagext.*;
import javax.servlet.jsp.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.mmbase.bridge.jsp.taglib.*;
import org.mmbase.module.core.*;

/**
 * @author Johannes Verelst &lt;johannes.verelst@eo.nl&gt;
 * TODO: make it work in a mm:relatedcontainer
 */
public class HeaderCellTag extends CloudReferrerTag { 
    String sortfield = "";
    String defaultfield = "";

    /**
     */
    public void setSortfield(String sortfield) {
        this.sortfield = sortfield;
    }

    public void setDefault(String defaultfield) {
        this.defaultfield = defaultfield;
    }

    /**
     */
    public int doStartTag() throws JspTagException {
        return EVAL_BODY_BUFFERED;
    }

    public void release() {
        sortfield = "";
        defaultfield = "";
    }

    // Code copied from MMBase 'CloudTag' code. Don't know why this is the case
    // but apparently there is no body written if this code is not included here
    // if EVAL_BODY == EVAL_BODY_BUFFERED
    public int doAfterBody() throws JspTagException {
        TableTag tt = (TableTag)findParentTag(TableTag.class, null, true);
        String tableSortfield = tt.getActiveSortfield();
        boolean sortingHere = false;
        if (tableSortfield == null) tableSortfield = "";
        if (sortfield == null) sortfield = "";
        
        if ((!sortfield.equals("") && sortfield.equals(tableSortfield)) ||
            (tableSortfield.equals("") && "true".equals(defaultfield) && !sortfield.equals(""))) {
            sortingHere = true;
        }

        if (tableSortfield.equals("") && "true".equals(defaultfield) && !sortfield.equals("")) {
            String sortorder = pageContext.getRequest().getParameter(tt.PARAM_ORDER);
            if (sortorder != null && !"".equals(sortorder))
                tt.setSort(sortfield, sortorder);
            else 
                tt.setSort(sortfield);
        }

        String prefix = tt.getLabel("headercell.start");
        String postfix = tt.getLabel("headercell.end");

        // For all fields which are sortable, but which are not sorted on
        // at the moment, create a correct link
        if (!sortingHere && !"".equals(sortfield)) {
            ArrayList disallowed = new ArrayList();
            disallowed.add(tt.PARAM_FIELD);
            disallowed.add(tt.PARAM_PAGE);
            disallowed.add(tt.PARAM_ORDER);
            StringBuffer url = Util.getCurrentUrl(pageContext, disallowed);
            url.append(tt.PARAM_FIELD + "=" + sortfield);
            
            prefix += "<a href=\"" + url + "\">";
            postfix = tt.getLabel("sorting.none.label") + "</a>" + postfix;
        }

        if (sortingHere) {
            ArrayList disallowed = new ArrayList();
            disallowed.add(tt.PARAM_PAGE);
            disallowed.add(tt.PARAM_ORDER);
            StringBuffer url = Util.getCurrentUrl(pageContext, disallowed);
            String newOrder = "";
            if (tt.getSortOrder() == 2) { //org.mmbase.storage.search.SortOrder.DESCENDING
                // now sorting down, show stuff for sorting up
                newOrder = tt.getLabel("sorting.up.label");
                url.append(tt.PARAM_ORDER + "=up");
            } else {
                // now sorting up, show stuff for sorting down
                newOrder = tt.getLabel("sorting.down.label");
                url.append(tt.PARAM_ORDER + "=down");
            }
            newOrder = "<a href=\"" + url + "\">" + newOrder + "</a>";
            postfix = newOrder + postfix;
        }

        try {
            if (bodyContent != null) {
                getPreviousOut().print(prefix);
                bodyContent.writeOut(bodyContent.getEnclosingWriter());
                getPreviousOut().print(postfix);
            }
        } catch (IOException ioe) {
            throw new TaglibException(ioe);
        }
        return SKIP_BODY;
    }

    public int doEndTag() throws JspTagException {
        release();
        return EVAL_PAGE;
    }
}
