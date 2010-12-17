<%-- This is the domain used for email 
--%><%
String domain = org.mmbase.module.Module.getModule("sendmail").getInitParameter("emailsenderdomain");
if (domain == null) domain = "@localhost";
%><%= domain %>
