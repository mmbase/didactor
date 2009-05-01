<%--
  This template shows sources (in dutch: informatiebronnen). Sources are
  hyperlinks that are grouped in url-categories. These folders are related
  to the current education.
--%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://www.mmbase.org/mmbase-taglib-1.0" prefix="mm" %>
<%@taglib uri="http://www.didactor.nl/ditaglib_1.0" prefix="di" %>

<mm:content postprocessor="reducespace">
<mm:cloud loginpage="/login.jsp" jspvar="cloud">

<mm:import externid="urlcat">-1</mm:import>

<%@include file="/shared/setImports.jsp" %>
<fmt:bundle basename="nl.didactor.component.sources.SourcesMessageBundle">
<mm:treeinclude page="/cockpit/cockpit_header.jsp" objectlist="$includePath" referids="$referids">
  <mm:param name="extraheader">
    <title><fmt:message key="SOURCES" /></title>
  </mm:param>
</mm:treeinclude>

<div class="rows">

<div class="navigationbar">
  <div class="titlebar">
    <img src="<mm:treefile write="true" page="/gfx/icon_sources.gif" objectlist="$includePath" />" width="25" height="13" border="0" alt="<fmt:message key="SOURCES" />" />
    <fmt:message key="SOURCES" />
  </div>
</div>

<div class="folders">
  <div class="folderHeader">
    <fmt:message key="CATEGORIES" />
  </div>
  <div class="folderBody">
    <mm:node number="$education" notfound="skip">
      <mm:relatednodescontainer type="urlcategories">
        <mm:relatednodes>

          <mm:import id="currenturlcat"><mm:field name="number"/></mm:import>

          <%-- open default the urls of the first urlcategorie --%>
          <mm:first>
            <mm:compare referid="urlcat" value="-1">
              <mm:remove referid="urlcat"/>
              <mm:import id="urlcat"><mm:field name="number"/></mm:import>
            </mm:compare>
          </mm:first>

          <%-- folder is open --%>
          <mm:compare referid="currenturlcat" referid2="urlcat">
            <img src="<mm:treefile page="/sources/gfx/mapopen.gif" objectlist="$includePath" referids="$referids"/>" alt="<fmt:message key="FOLDEROPENED" />"/>
          </mm:compare>

          <%-- folder is closed --%>
          <mm:compare referid="currenturlcat" referid2="urlcat" inverse="true">
            <img src="<mm:treefile page="/sources/gfx/mapdicht.gif" objectlist="$includePath" referids="$referids"/>" alt="<fmt:message key="FOLDERCLOSED" />"/>
          </mm:compare>

          <a href="<mm:treefile page="/sources/index.jsp" objectlist="$includePath" referids="$referids">
                     <mm:param name="urlcat"><mm:field name="number" /></mm:param>
                   </mm:treefile>">
            <mm:field name="name" />
          </a><br />

        </mm:relatednodes>
      </mm:relatednodescontainer>
    </mm:node>
  </div>
</div>

<div class="mainContent">
  <div class="contentHeader">
    <mm:node number="$urlcat" notfound="skip">
      <mm:field name="name"/>
    </mm:node>
  </div>
  <div class="contentSubHeader">
    <mm:node number="$urlcat" notfound="skip">
      <mm:field name="description"/>
  </div>
  <div class="contentBody">
      <mm:relatednodescontainer type="urls">
        <di:table maxitems="10">
          <di:row>
            <di:headercell sortfield="name" default="true"><fmt:message key="URLNAME" /></di:headercell>
            <di:headercell sortfield="url"><fmt:message key="URLLINK" /></di:headercell>
            <di:headercell sortfield="description"><fmt:message key="URLDESCRIPTION" /></di:headercell>
          </di:row>
          <mm:relatednodes>
            <di:row>
              <%-- Open de link in a new window (target unknownframe) --%>
              <mm:import id="link" jspvar="linkText"><mm:field name="url"/></mm:import>
			  <%
			    if ( linkText.indexOf( "http://" ) == -1 ) {
			  %>
			    <mm:remove referid="link"/>
			    <mm:import id="link">http://<mm:field name="url"/></mm:import>
			  <%
			    }
			  %>
              <di:cell><a target="unknownframe" href="<mm:write referid="link" />"><mm:field name="name" /></a></di:cell>
              <di:cell><a target="unknownframe" href="<mm:write referid="link" />"><mm:field name="url" /></a></di:cell>
              <di:cell><a target="unknownframe" href="<mm:write referid="link" />"><mm:field name="description" /></a></di:cell>
            </di:row>
          </mm:relatednodes>
        </di:table>
      </mm:relatednodescontainer>
    </mm:node>
  </div>
</div>
</div>

<mm:treeinclude page="/cockpit/cockpit_footer.jsp" objectlist="$includePath" referids="$referids" />

</fmt:bundle>
</mm:cloud>
</mm:content>
