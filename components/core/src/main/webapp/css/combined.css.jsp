/*<%@taglib uri="http://www.mmbase.org/mmbase-taglib-2.0" prefix="mm"
%><%@ taglib uri="http://www.opensymphony.com/oscache" prefix="os"
%><jsp:directive.page session="false" />
*///<mm:content  expires="604800" type="text/css" postprocessor="none"><os:cache key="combinedcss" refresh="${param.refresh eq 'true' ? 'true' : 'false'}" time="3600"><mm:escape escape="css-compress">
  <mm:treeinclude debug="css" page="/css/base.css.jsp"
                  objectlist="$includePath"  />
  <mm:haspage page="/mmbase/style/css/mmxf.css">
    <mm:include page="/mmbase/style/css/mmxf.css" />
  </mm:haspage>
</mm:escape></os:cache></mm:content>
