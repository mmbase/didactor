<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://www.mmbase.org/mmbase-taglib-1.0" prefix="mm" %>
<%@taglib uri="http://www.didactor.nl/ditaglib_1.0" prefix="di" %>
<mm:content postprocessor="reducespace" expires="0">
<mm:cloud loginpage="/login.jsp" jspvar="cloud">
<%@include file="/shared/setImports.jsp" %>

<di:hasrole role="systemadministrator">
<mm:listnodes type="icaches">
    deleting <mm:field name="ckey"/><br>
    <mm:deletenode deleterelations="true"/>
</mm:listnodes>
done
</di:hasrole>
</mm:cloud>
</mm:content>
