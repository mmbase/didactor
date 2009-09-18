<jsp:root version="2.0"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:mm="http://www.mmbase.org/mmbase-taglib-2.0"
          xmlns:di="http://www.didactor.nl/ditaglib_1.0"
          >
  <di:html
      rank="anonymous"
      title="Didactor version">
    <mm:functioncontainer>
      <mm:param name="name">didactor_core</mm:param>
      <mm:function set="components" name="get" id="c">
        <c:forEach items="${c.manifest.entries['org/mmbase']}" var="e">
          <p><b>${e.key}</b> ${e.value}</p>
        </c:forEach>
      </mm:function>
    </mm:functioncontainer>
    <p><b>Provider:</b> ${provider}</p>
    <p><b>Education:</b> ${education}</p>
  </di:html>
</jsp:root>
