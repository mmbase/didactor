<jsp:root version="2.0"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:mm="http://www.mmbase.org/mmbase-taglib-2.0"
          xmlns:os="http://www.opensymphony.com/oscache"
          xmlns:di="http://www.didactor.nl/ditaglib_1.0"
          >
  <di:html
      styleClass="education"
      type="application/xhtml+xml"
      title_key="education.learnenvironmenttitle"
      expires="0"
      component="education">
    <os:cache>

      <!-- wtf -->
      <mm:hasnode number="component.drm">
        <mm:haspage page="/drm/testlicense.jsp">
          <di:include page="/drm/testlicense.jsp" />
        </mm:haspage>
      </mm:hasnode>

      <di:include
          debug="${applicationScope.includeDebug}"
          page="/education/bookmark.jspx" />

      <div class="rows" id="rows">
        <c:choose>
          <c:when test="${empty education}">
            NO EDUCATION YET
          </c:when>
          <c:otherwise>
            <di:include debug="${applicationScope.includeDebug}"
                        page="/education/navigation.jspx" />
            <di:include debug="${applicationScope.includeDebug}"
                        page="/education/main.jspx" />
          </c:otherwise>
        </c:choose>
      </div>
    </os:cache>
  </di:html>

</jsp:root>
