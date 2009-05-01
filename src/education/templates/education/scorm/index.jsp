<%@taglib uri="http://www.mmbase.org/mmbase-taglib-1.0" prefix="mm"%>
<%@taglib uri="http://www.didactor.nl/ditaglib_1.0" prefix="di" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<%@page import="java.io.File"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>


<%@page import="org.apache.commons.fileupload.*"%>

<%@page import="org.mmbase.bridge.Node"%>
<%@page import="org.mmbase.bridge.NodeManager"%>
<%@page import="org.mmbase.bridge.NodeIterator"%>

<%@page import="nl.didactor.utils.zip.Unpack"%>

<%@page import="uk.ac.reload.jdom.XMLDocument"%>
<%@page import="uk.ac.reload.moonunit.contentpackaging.CP_Core"%>

<mm:cloud loginpage="/login.jsp" jspvar="cloud">
<mm:import id="import_package" jspvar="requestImportPackageID" vartype="String"><%= request.getParameter("import_package") %></mm:import>
<mm:import id="delete_package"><%= request.getParameter("delete_package") %></mm:import>

<%--
<mm:import externid="import_package" jspvar="test" vartype="String">null</mm:import>
<mm:import externid="delete_package">null</mm:import>
--%>

<%
//   System.out.println("a=" + request.);
// String directory = getServletContext().getRealPath("/education/files");

   String directory = getServletContext().getInitParameter("filemanagementBaseDirectory") + "/scorm";
   String baseUrl = getServletContext().getInitParameter("filemanagementBaseUrl");

   if (directory == null || baseUrl == null)
   {
       throw new ServletException("Please set filemanagementBaseDirectory and filemanagementBaseUrl parameters in web.xml");
   }

   SimpleDateFormat df = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
   Node nodePackage = null;
   File newDir = null;
   File newDir_ = null;
   File fileStoreDir = null;
   File fileTempDir  = null;
   String sFileName = null;
   String msg = "";
   String mtype = null;

%>
   <mm:compare referid="import_package" value="null" inverse="true">
      <mm:node number="<%= requestImportPackageID %>" notfound="skip">
         <%@include file="import.jsp"%>
      </mm:node>
   </mm:compare>
<%

   boolean uploadOK = false;
   String fileName = null;

   if (request.getSession(false) != null && "true".equals(request.getSession(false).getAttribute("mayupload")))
   {
      if (FileUpload.isMultipartContent(request))
      {
         DiskFileUpload upload = new DiskFileUpload();
         upload.setSizeMax(250*1024*1024);
         upload.setSizeThreshold(4096);
         upload.setRepositoryPath(System.getProperties().getProperty("java.io.tmpdir"));
         List items = upload.parseRequest(request);
         Iterator itr = items.iterator();
         while(itr.hasNext())
         {
            FileItem item = (FileItem) itr.next();
            if (item.isFormField())
            {
               if (item.getFieldName().equals("manager"))
               {
                   mtype = item.getString();
               }
            }
            else
            {
               String fieldName = item.getFieldName();
               File fileSrc = null;
               if(fieldName.equals("filename"))
               {
                  //------------- Uploading of new package ----------------

                  //Create a new node which describes this package
                  nodePackage = cloud.getNodeManager("packages").createNode();
                  nodePackage.setValue("uploaddate", "" + ((new Date()).getTime() / 1000));
                  nodePackage.setValue("type", "SCORM");
                  nodePackage.commit();

                  fileName = item.getName().replaceFirst("\\A.*?[/\\\\:]([^/\\\\:]+)$\\z","$1");

                  try
                  {//Internal server error
                     newDir = new File(Unpack.fixPath(directory + File.separator + nodePackage.getNumber()));
                     newDir.mkdirs();
                     newDir_ = new File(newDir.getAbsolutePath() + "_");
                     newDir_.mkdirs();

                     File savedFile = new File(Unpack.fixPath(directory) + File.separator + nodePackage.getNumber(), fileName);
                     item.write(savedFile);
                     fileSrc = new File(Unpack.fixPath(directory + File.separator + fileName));

                     uploadOK = true;
                     savedFile = null;
                  }
                  catch(Exception e)
                  {
                     msg = "Internal server error: " + e.toString();
                     uploadOK = false;
                  }

                  try
                  {// A error during unpacking .zip
                     if(uploadOK)
                     {
                        Unpack.unzipFileToFolder(Unpack.fixPath(directory + File.separator + nodePackage.getNumber() + File.separator + fileName), Unpack.fixPath(directory + File.separator + nodePackage.getNumber() + "_"));
                     }
                  }
                  catch(Exception e)
                  {
                     msg = "UNZIP Error: " + e.toString();
                     nodePackage.delete(true);
                     Unpack.deleteFolderIncludeSubfolders(newDir.getAbsolutePath(), false);
                     Unpack.deleteFolderIncludeSubfolders(newDir_.getAbsolutePath(), false);
                     uploadOK = false;
                  }


                  //check manifest file here
                  if(uploadOK)
                  {
                     try
                     {
                        File file = new File(Unpack.fixPath(directory + File.separator + nodePackage.getNumber() + "_" + File.separator + CP_Core.MANIFEST_NAME));
                        XMLDocument xmlDocument = new XMLDocument();
                        xmlDocument.loadDocument(file);
                        CP_Core cp_core = new CP_Core(xmlDocument);
                        nodePackage.setValue("version", "" + cp_core.getRootManifestElement().getAttributeValue("version"));
                        nodePackage.setValue("name", fileName);
                        nodePackage.commit();
                     }
                     catch(Exception e)
                     {
                        msg = "Error parsing manifest file: " + e.toString();
                        nodePackage.delete(true);
                        Unpack.deleteFolderIncludeSubfolders(newDir.getAbsolutePath(), false);
                        Unpack.deleteFolderIncludeSubfolders(newDir_.getAbsolutePath(), false);
                        uploadOK = false;
                     }
                  }

                  if(uploadOK)
                  {
                     //Clean up the folder
                     Unpack.deleteFolderIncludeSubfolders(newDir_.getAbsolutePath(), false);
                  }
               }
            }
         }
      }
   }
%>

<%@include file="/shared/setImports.jsp"%>
<%@include file="/education/wizards/roles_defs.jsp" %>
<mm:import id="editcontextname" reset="true">filemanagement</mm:import>
<%@include file="/education/wizards/roles_chk.jsp" %>
<mm:islessthan inverse="true" referid="rights" referid2="RIGHTS_RW">

<%
   String bundleEducation = null;
%>

<mm:write referid="lang_code" jspvar="sLangCode" vartype="String" write="false">
   <%
      bundleEducation  = "nl.didactor.component.education.EducationMessageBundle";
   %>
</mm:write>

<fmt:bundle basename="<%= bundleEducation %>">

<% request.getSession().setAttribute("mayupload","true"); %>

<%
   //------------- Import of new package ----------------

   if (uploadOK && fileName != null)
   {
/*


*/
   }
%>



<html>
<head>
<title>File manager</title>
   <link rel="stylesheet" type="text/css" href='<mm:treefile page="/css/base.css" objectlist="$includePath" referids="$referids" />' />
   <link rel="stylesheet" type="text/css" href="<mm:treefile page="/editwizards/style/layout/list.css" objectlist="$includePath" referids="$referids" />" />
   <link rel="stylesheet" type="text/css" href="<mm:treefile page="/editwizards/style/color/list.css" objectlist="$includePath" referids="$referids" />" />
</head>
<body>
<%--
<script>
if (top == self) {
    var loc = document.location.href;
    loc = loc.replace(/&amp;/ig,'&').replace(/(education\/).*/,"$1wizards/index.jsp");
    document.location.href = loc;
}
</script>
--%>
<%
    File dir = new File(directory);
    File[] farray = dir.listFiles();
    if (farray == null)
    {
       throw new ServletException("'" + directory + "' does not appear to be a directory! Please set filemanagementBaseDirectory and filemanagementBaseUrl parameters in web.xml");
    }
%>

<table class="head">
   <tr class="headsubtitle">
      <td>
         <%
            String sResults = "";
            String sTotalItems = "0";
         %>
         <mm:import jspvar="sTemplate" vartype="String" reset="true"><fmt:message key="scormPackageListTotalAmount"/></mm:import>
         <mm:listnodes type="packages">
            <mm:size jspvar="sItems" vartype="String">
               <%
                  sTotalItems = sItems;
               %>
            </mm:size>
         </mm:listnodes>
         <%
            sResults = sTemplate.replaceAll("\\{\\$\\$\\$\\}", sTotalItems);
         %>
         <div><%= sResults %></div>
      </td>
   </tr>
</table>

<table class="body">
   <tr class="searchcanvas">
      <td>
         <table class="searchcontent">
            <tr>
               <td>
                  <form action="index.jsp" method="POST" enctype="multipart/form-data">
                     <input type="file" name="filename"  style="width:200px; height:20px">
                     <input type="submit" value="Upload" style="width:60px; text-align:center">
                  </form>
                  <%
                     if (uploadOK)
                     {
                        %><b><fmt:message key="scormPackageListUploadOk"/></b><%
                     }
                  %>
                  <b><%= msg %></b>
               </td>
            </tr>
         </table>
      </td>
   </tr>
   <tr class="listcanvas">
      <td>
         <table class="listcontent">
            <tr class="listheader">
               <mm:islessthan inverse="true" referid="rights" referid2="RIGHTS_RWD">
                  <th/>
               </mm:islessthan>

               <th>#</th>
               <th><fmt:message key="scormPackageListTableName"/></th>
               <th><fmt:message key="scormPackageListTableVersion"/></th>
               <th><fmt:message key="scormPackageListTableStatus"/></th>
               <th><fmt:message key="scormPackageListTableUploadDate"/></th>
               <th><fmt:message key="scormPackageListTableImportDate"/></th>
            </tr>

            <%
               int fileNum = 0;
            %>
            <mm:listnodes type="packages" orderby="uploaddate">

               <mm:import id="imported" reset="true"><mm:field name="importdate"/></mm:import>
<%--
                  if (deletefile != null && file.getName().equals(deletefile))
                  {
                     String[] managers = {"audiotapes","videotapes","urls"};

                     for (int i = 0; i < managers.length; i++)
                     {
                        NodeIterator ni = cloud.getNodeManager(managers[i]).getList("url='"+baseUrl+"/"+deletefile+"'",null,null).nodeIterator();

                        while(ni.hasNext())
                        {
                           ni.nextNode().delete(true); // delete next node related with this file ...
                        }
                     }
                     file.delete(); // and delete file itself ...
                     continue;
                  }
--%>

                  <%
                     fileNum++;
                  %>
                     <tr>
                        <mm:islessthan inverse="true" referid="rights" referid2="RIGHTS_RWD">
                           <td class="deletebutton">
                              <a
                                 href='index.jsp?deletefile=<mm:field name="number"/>'
                                 onclick="return confirm('<fmt:message key="filemanagementDeletePrompt"/>');">
                                   <img border="0" src="<%= request.getContextPath() %>/editwizards/media/remove.gif"/>
                              </a>
                           </td>
                        </mm:islessthan>

                        <td class="field"><mm:field name="name"/></td>
                        <td class="field"><mm:field name="filename"/></td>
                        <td class="field"><mm:field name="version"/></td>
                        <td>
                           <mm:compare referid="imported" value="-1" inverse="true">
                              <fmt:message key="scormPackageListImported"/>
                           </mm:compare>
                           <mm:compare referid="imported" value="-1">
                              <fmt:message key="scormPackageListUploaded"/> (<a href="?import_package=<mm:field name="number"/>"><fmt:message key="scormPackageListImportLink"/></a>)
                           </mm:compare>
                        </td>
                        <td>
                           <mm:field name="uploaddate" jspvar="date" vartype="date">
                              <%= df.format(date) %>
                           </mm:field>
                        </td>
                        <td>
                           <mm:compare referid="imported" value="-1" inverse="true">
                              <mm:field name="importdate" jspvar="date" vartype="date">
                                 <%= df.format(date) %>
                              </mm:field>
                           </mm:compare>
                        </td>
                     </tr>
            </mm:listnodes>
         </table>
      </td>
   </tr>
</table>

</body>
</html>

</fmt:bundle>
</mm:islessthan>
</mm:cloud>

