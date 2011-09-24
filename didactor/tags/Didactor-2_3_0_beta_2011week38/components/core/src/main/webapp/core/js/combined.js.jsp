/*<%@taglib uri="http://www.mmbase.org/mmbase-taglib-2.0" prefix="mm"
%><%@ taglib uri="http://www.opensymphony.com/oscache" prefix="os"
%><jsp:directive.page session="false" />
*///<mm:content type="text/javascript" expires="604800" postprocessor="none"><os:cache key="combinedjs" refresh="${param.refresh eq 'true' ? 'true' : 'false'}" time="3600"><mm:escape escape="javascript-compress">
  <jsp:directive.include file="/mmbase/jquery/jquery-1.6.1.min.js" />
  <jsp:directive.include file="/mmbase/jquery/jquery.form.js" />
  <jsp:directive.include file="/mmbase/validation/validation.js.jsp" />
  <jsp:directive.include file="/mmbase/jquery/jquery.timer.js" />
  <jsp:directive.include file="/core/js/utils.js" />
  <jsp:directive.include file="/core/js/jquery.query.js" />
  <jsp:directive.include file="/core/js/Didactor.js" />
  <mm:treeinclude page="/content/js/open.jsp"
                  objectlist="$includePath"  />
  <mm:treeinclude page="/core/js/specific.js"
                  objectlist="$includePath"  />

</mm:escape></os:cache></mm:content>
