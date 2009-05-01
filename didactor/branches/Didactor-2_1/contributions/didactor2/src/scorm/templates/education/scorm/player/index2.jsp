<!--
/**
 *  RELOAD Scorm Player 1.2
 *
 *  Copyright (c) 2003 Oleg Liber, Bill Olivier, Phillip Beauvoir
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *  Project Management Contact:
 *
 *  Oleg Liber
 *  Bolton Institute of Higher Education
 *  Deane Road
 *  Bolton BL3 5AB
 *  UK
 *
 *  e-mail:   o.liber@bolton.ac.uk
 *
 *
 *  Technical Contact:
 *
 *  Phillip Beauvoir
 *  e-mail:   p.beauvoir@bolton.ac.uk
 *
 *  Web:      http://www.reload.ac.uk
 *
 */
// -->



<html>
<head>
<title></title>
<script language="javascript">
<!--
/*
* Dummy SCORM API
*/

function GenericAPIAdaptor(){
   this.LMSInitialize = LMSInitializeMethod;
   this.LMSGetValue = LMSGetValueMethod;
   this.LMSSetValue = LMSSetValueMethod;
   this.LMSCommit = LMSCommitMethod;
   this.LMSFinish = LMSFinishMethod;
   this.LMSGetLastError = LMSGetLastErrorMethod;
   this.LMSGetErrorString = LMSGetErrorStringMethod;
   this.LMSGetDiagnostic = LMSGetDiagnosticMethod;
}
/*
* LMSInitialize.
*/
function LMSInitializeMethod(parameter){return "true";}
/*
* LMSFinish.
*/
function LMSFinishMethod(parameter){return "true";}
/*
* LMSCommit.
*/
function LMSCommitMethod(parameter){return "true";}
/*
* LMSGetValue.
*/
function LMSGetValueMethod(element){return "";}
/*
* LMSSetValue.
*/
function LMSSetValueMethod(element, value){return "true";}
/*
* LMSGetLastErrorString
*/
function LMSGetErrorStringMethod(errorCode){return "No error";}
/*
* LMSGetLastError
*/
function LMSGetLastErrorMethod(){return "0";}
/*
* LMSGetDiagnostic
*/
function LMSGetDiagnosticMethod(errorCode){return "No error. No errors were encountered. Successful API call.";}

var API = new GenericAPIAdaptor;
//-->
</script>
<meta http-equiv="Pragma" content="no-cache">

<%
   String sTopFrame = "0";
   String sLeftFrame= "0";
   String sBorder = "no";

   if((request.getParameter("path") == null) || (request.getParameter("path").equals("")))
   {
      sTopFrame = "42";
      sLeftFrame= "300";
      sBorder = "yes";
   }
%>

<frameset rows="<%= sTopFrame %>,*" name="ContentPreview" framespacing="0" frameborder="no" border="0">
    <frame id="CPFrame" name="CPFrame" src="ReloadContentPreviewFiles/CPFrame.jsp?path=<%= request.getParameter("path") %>" frameborder="no" border="1" scrolling="no" noresize>
    <frameset cols="<%= sLeftFrame %>,*" framespacing="1" frameborder="<%= sBorder %>" border="1" resize>
         <frameset rows="0,*,0" cols="*" framespacing="0" frameborder="no" border="0" noresize>
               <frame id="code" src="ReloadContentPreviewFiles/code.htm" name="code" frameborder="no" border="0" scrolling="no" resize>
               <frame src="ReloadContentPreviewFiles/menu_empty.htm" name="menu" frameborder="no" border="0" scrolling="auto" resize>
               <frame src="ReloadContentPreviewFiles/search.htm" name="search" frameborder="no" border="0" scrolling="auto" resize>
            </frameset>
    <frame src="ReloadContentPreviewFiles/CPStart.htm" id="text" name="text" framespacing="1" frameborder="no" border="0" scrolling="auto" resize>
    </frameset>
</frameset>
<noframes>
No frame support. Please download a newer browser version which can handle frames.
</noframes>
</head>
<body>
</body>
</html>
