/*<%@taglib uri="http://www.mmbase.org/mmbase-taglib-2.0" prefix="mm"
%><%@ taglib uri="http://www.opensymphony.com/oscache" prefix="os"
%><jsp:directive.page session="false" />
*/
<mm:content type="text/css" expires="3600" postprocessor="none"><os:cache key="combinedcss" refresh="${param.refresh eq 'true' ? 'true' : 'false'}" time="3600"><mm:escape escape="css-compress">

  <mm:treeinclude page="/css/print.css"
                  objectlist="$includePath"  />
//</mm:escape></os:cache></mm:content>