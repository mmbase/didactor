<%@taglib uri="http://www.mmbase.org/mmbase-taglib-1.1" prefix="mm" %>
<%@taglib uri="http://www.didactor.nl/ditaglib_1.0" prefix="di" %>

<mm:import externid="extraheader" />
<mm:import externid="extrabody" />
<mm:content postprocessor="reducespace">
<mm:cloud jspvar="cloud" method="asis">
<%@include file="/shared/setImports.jsp" %>

<%--
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
--%>

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <link rel="stylesheet" type="text/css" href="<mm:treefile page="/css/base.css" objectlist="$includePath" referids="$referids" />" />
    <mm:write referid="extraheader" escape="none" />
  </head>
  <body class="componentbody" <mm:write referid="extrabody" escape="none" />>
   <div>
      <mm:treeinclude page="/cockpit/applicationbarcockpit.jsp" objectlist="$includePath" referids="$referids"/>
      <mm:treeinclude page="/cockpit/providerbar.jsp" objectlist="$includePath" referids="$referids" />
      <mm:treeinclude page="/cockpit/educationbarcockpit.jsp" objectlist="$includePath" referids="$referids" />
   </div>
</mm:cloud>
</mm:content>
