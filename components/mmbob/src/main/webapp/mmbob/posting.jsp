<%-- !DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml/DTD/transitional.dtd" --%>
<%@ page contentType="text/html; charset=utf-8" language="java" 
%><%@taglib uri="http://www.didactor.nl/ditaglib_1.0" prefix="di" 
%><%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"
%><%@taglib uri="http://www.mmbase.org/mmbase-taglib-2.0" prefix="mm" 
%><mm:cloud method="delegate" jspvar="cloud">
<%@include file="/shared/setImports.jsp" %>
<%@ include file="thememanager/loadvars.jsp" %>
<%@ include file="settings.jsp" %>
<html>
<head>
   <link rel="stylesheet" type="text/css" href="<mm:write referid="style_default" />" />
   <link rel="stylesheet" type="text/css" href="<mm:treefile page="/css/base.css" objectlist="$includePath" referids="$referids" />" />
   <title>MMBob</title>
   <script language="JavaScript1.1" type="text/javascript" src="js/smilies.js"></script>

</head>
<mm:import externid="forumid" />
<mm:import externid="postareaid" />
<mm:import externid="postthreadid" />

<!-- login part -->
<%@ include file="getposterid.jsp" %>
<!-- end login part -->

<!-- action check -->
<mm:import externid="action" />
<mm:present referid="action">
 <mm:include page="actions.jsp" />
</mm:present>
<!-- end action check -->

<mm:node referid="postthreadid">
  <mm:field name="state">
    <mm:import id="tstate"><mm:field name="state" /></mm:import>
    <mm:compare value="closed"><mm:import id="noedit">true</mm:import></mm:compare>
    <mm:compare value="pinned"><mm:import id="noedit">true</mm:import></mm:compare>
  </mm:field>
</mm:node>

<center>
<table cellpadding="0" cellspacing="0" class="list" style="margin-top : 50px;" width="75%">
  <mm:import externid="postingid" />
  
  <mm:notpresent referid="noedit">
  <tr><th colspan="3" ><di:translate key="mmbob.editmessage" /></th></tr>
  <mm:node referid="postingid">
  <form action="<mm:url page="thread.jsp">
    <mm:param name="forumid" value="$forumid" />
    <mm:param name="postareaid" value="$postareaid" />
    <mm:param name="postthreadid" value="$postthreadid" />
    <mm:param name="postingid" value="$postingid" />
    </mm:url>" method="post" name="posting">
    <tr><th><di:translate key="mmbob.name" /></th><td colspan="2">
        <mm:compare referid="posterid" value="-1" inverse="true">
        <mm:node number="$posterid">
        <mm:field name="account" /> (<di:person  />)
        <input name="poster" type="hidden" value="<mm:field name="account" />" >
        </mm:node>
        </mm:compare>
        <mm:compare referid="posterid" value="-1">
        <input name="poster" size="32" value="gast" >
        </mm:compare>
    </td></tr>
    <tr><th><di:translate key="mmbob.subject" /></th><td colspan="2"><input name="subject" style="width: 100%" value="Re: <mm:field name="subject" />" ></td></th>
    <tr><th valign="top"><di:translate key="mmbob.message" /> <center><table width="99"><tr><th><%@ include file="includes/smilies.jsp" %></th></tr></table></center> </th><td colspan="2"><textarea name="body" rows="20" style="width: 100%"><quote poster="<mm:field name="poster"/>"><mm:formatter xslt="xslt/posting2textarea.xslt"><mm:field name="body" /></mm:formatter></quote></textarea></td></tr>
    <tr><th>&nbsp;</th><td>
    <input type="hidden" name="action" value="postreply">
    <center><input type="submit" value="<di:translate key="mmbob.commit" />">
    </form>
    </td>
    <td>
    </mm:node>
    <form action="<mm:url page="thread.jsp">
    <mm:param name="forumid" value="$forumid" />
    <mm:param name="postareaid" value="$postareaid" />
    <mm:param name="postthreadid" value="$postthreadid" />
    </mm:url>"
    method="post">
    <p />
    <center>
    <input type="submit" value="<di:translate key="mmbob.cancel" />">
    </form>
    </td>
    </tr>
    </mm:notpresent>
        <mm:present referid="noedit">
    <tr><th colspan="3"><di:translate key="mmbob.subjhbclosed" /></th></tr>
    <td>
    <form action="<mm:url page="thread.jsp">
    <mm:param name="forumid" value="$forumid" />
    <mm:param name="postareaid" value="$postareaid" />
    <mm:param name="postthreadid" value="$postthreadid" />
    </mm:url>"
    method="post">
    <p />
    <center>
    <input type="submit" value="<di:translate key="mmbob.ok" />">
    </form>
    </td>
    </tr>
    </mm:present>

</table>
</center>
</html>
</mm:cloud>
