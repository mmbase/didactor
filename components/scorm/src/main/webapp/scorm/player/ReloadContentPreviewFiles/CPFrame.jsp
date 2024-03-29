<!--
/**
 *  RELOAD TOOLS
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
 *  @author Paul Sharples
 *  @version $Id: CPFrame.jsp,v 1.1 2007-04-30 16:40:49 michiel Exp $
 */
// -->
<html>
<head>
<meta http-equiv="Pragma" content="no-cache">
<script language="javascript" src="CPModel.js"></script>
<script language="javascript" src="CPOrgs.jsp?number=${param.number}"></script>

<script>
<!--
// Some vars I need to set up...

//var CPAPI = parent.window.frames.CPAPI;
var prevLink, prevLinkDisabled, nextLink, nextLinkDisabled, showImage, hideImage;
prevLink = 'menu-images/prev.gif';
prevLinkDisabled = 'menu-images/prev_disabled.gif';
nextLink = 'menu-images/next.gif';
nextLinkDisabled = 'menu-images/next_disabled.gif';
showImage = 'menu-images/hide.gif';
hideImage = 'menu-images/show.gif';

var isNavVisisble = "false";

/*
* Dreamweaver functions
*/
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_setTextOfLayer(objName,x,newText) { //v4.01
  if ((obj=MM_findObj(objName))!=null) with (obj)
    if (document.layers) {document.write(unescape(newText)); document.close();}
    else innerHTML = unescape(newText);
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments;
  document.MM_sr=new Array;
  for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){
         document.MM_sr[j++]=x;
      if(!x.oSrc)
         x.oSrc=x.src;
         x.src=a[i+2];
   }
}



/*
* CPAPI functions
*/
function updateNavigation(item){
   if (CPAPI.orgArray(CPAPI._currentOrg)._currentItem != -1){
      if (item == 'prev'){
         if (CPAPI.orgArray(CPAPI._currentOrg)._currentItem != CPAPI.orgArray(CPAPI._currentOrg)._firstItem){
            CPAPI.changeItem(CPAPI.orgArray(CPAPI._currentOrg).getPrevItem());
         }
      }
      if (item == 'next'){
         if (CPAPI.orgArray(CPAPI._currentOrg)._currentItem != CPAPI.orgArray(CPAPI._currentOrg)._lastItem){
            CPAPI.changeItem(CPAPI.orgArray(CPAPI._currentOrg).getNextItem());
         }
      }

      if((navigator.appName == "Netscape" && parseInt(navigator.appVersion) >= 3 && navigator.userAgent.indexOf("Opera") == -1) || (navigator.appName == "Microsoft Internet Explorer" && parseInt(navigator.appVersion) >= 4) || (navigator.appName == "Opera" && parseInt(navigator.appVersion) >= 5)) {
         var MTMCodeFrame = "code";
         for(i = 0; i < parent.frames.length; i++) {
            if(parent.frames[i].name == MTMCodeFrame && parent.frames[i].MTMLoaded) {
               parent.frames[i].MTMTrack = true;
               temp1 = parseInt(CPAPI.orgArray(CPAPI._currentOrg).itemArray(CPAPI.orgArray(CPAPI._currentOrg)._currentItem).numberInAllItems);
               parent.frames[i].MTMTrackedItem = parseInt(temp1+1);
               setTimeout("parent.frames[" + i + "].MTMDisplayMenu()", 50);
               break;
            }
         }
      }
   }
}

function updateTitles(param){
   var theTitles = param.replace('\\\'', '\'') ;
   MM_setTextOfLayer('itemTitles','','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+theTitles);
}

function disablePrevButton(){
   MM_swapImage('prev', '', prevLinkDisabled, 1);
   MM_swapImage('next', '', nextLink, 1);
}

function disableNextButton(){
   MM_swapImage('prev', '', prevLink, 1);
   MM_swapImage('next', '', nextLinkDisabled, 1);
}

function enableBothButtons(){
   MM_swapImage('prev', '', prevLink, 1);
   MM_swapImage('next', '', nextLink, 1);
}

function disableBothButtons(){
   MM_swapImage('prev', '', prevLinkDisabled, 1);
   MM_swapImage('next', '', nextLinkDisabled, 1);
}

function showHideNav(){

   var oFramesets=parent.window.document.getElementsByTagName("frameset");
   if (isNavVisisble == "true"){
      oFramesets.item(1).cols="1,*";
      isNavVisisble = "false";
      MM_swapImage('showhide', '', hideImage, 1);
   }
   else{
      oFramesets.item(1).cols="300,*";
      isNavVisisble = "true";
      MM_swapImage('showhide', '', showImage, 1);
   }
}

function showSearch(){
   if(CPAPI.showSearch == true){
      var oFramesets=parent.window.document.getElementsByTagName("frameset");
      oFramesets.item(2).rows="0,*,70";
   }
}

/*
* init() - this function is here in case the browser tries to call startup before
* the "code" frame had loaded fully (this sometimes happen on first load into the browser)
*/
function init(){
   try{
      parent.window.frames.code.startUp();
      showSearch();
   }
   catch(ex){
      alert("Please refresh your browser to view this package");
   }
}
//-->
</script>
<link href="reload.css" rel="stylesheet" type="text/css">
</head>


<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onload="init()">



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#5a79ef">
   <tr>
      <td bgcolor="#DDDDDD">
         <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
               <td>
                  <table border="0" cellpadding="0" cellspacing="0" style="border-color:#FF0000">
                     <tr>
                        <td width="100%" style="border:0px"><font size='2' face='verdana'><b><div id="itemTitles">&nbsp;</div></b></font></td>
                        <td style="background:#000000"><font style="font-size:1px">&nbsp;</font></td>
                        <td><a href="#" onClick="showHideNav()"><img src="menu-images/hide.gif" name="showhide" width="61" height="20" id="showhide" border="0"></a></td>
                        <td style="background:#000000"><font style="font-size:1px">&nbsp;</font></td>
                        <td><a href="#" onClick="updateNavigation('prev')" style="color:#000000; font-size:13px; font-weight:bold"><nobr><img src="menu-images/prev_disabled.gif" name="prev" id="prev" border="0" align="middle">&nbsp;vorige&nbsp;&nbsp;</nobr></a></td>
                        <td style="background:#000000"><font style="font-size:1px">&nbsp;</font></td>
                        <td><a href="#" onClick="updateNavigation('next')" style="color:#000000; font-size:13px; font-weight:bold"><nobr>&nbsp;&nbsp;volgende&nbsp;<img src="menu-images/next_disabled.gif" name="next" id="next" border="0" align="middle"></nobr></a></td>
                     </tr>
                  </table>
               </tr>
            </tr>
            <tr bgcolor="#5a79ef">
               <td height="1" colspan="4"></td>
            </tr>
         </table>
      </td>
   </tr>
</table>
</body>
</html>


