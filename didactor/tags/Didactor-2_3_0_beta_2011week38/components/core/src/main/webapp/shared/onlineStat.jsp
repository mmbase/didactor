<jsp:root
    version="2.0"
    xmlns:jsp="http://java.sun.com/JSP/Page"
    xmlns:mm="http://www.mmbase.org/mmbase-taglib-2.0"
    xmlns:di="http://www.didactor.nl/ditaglib_1.0">
  <mm:cloudinfo type="user" id="username2" write="false" />
  <mm:import jspvar="username" externid="username2" from="this" />
  <mm:node element="classrel">
    <mm:write referid="oldLastActivity" jspvar="oldLastActivity" vartype="Integer">
      <mm:field name="onlinetime" jspvar="onlinetime" vartype="Integer" write="false">
        <mm:import id="newOnlineTime" jspvar="newOnlineTime" vartype="Integer">
          <jsp:expression>onlinetime.intValue()+Math.min(120,(System.currentTimeMillis()/1000-oldLastActivity.intValue()))</jsp:expression>
        </mm:import>
      </mm:field>
    </mm:write>
    <mm:setfield name="onlinetime"><mm:write referid="newOnlineTime"/></mm:setfield>

    <mm:import from="session" externid="educationId" />
    <mm:compare referid="educationId" value="${education}-${username}-${pageContext.session.id}" inverse="true">
      <mm:remove referid="educationId" />
      <mm:write session="educationId" value="${education}-${username}-${pageContext.session.id}" />
      <mm:import from="session" externid="educationId" />

      <mm:field name="logincount" vartype="integer">
        <mm:log>Increasing logincount of ${username} to ${_+ 1} for session ${educationId}</mm:log>
        <mm:setfield name="logincount">${_ + 1}</mm:setfield>
      </mm:field>
      <di:event eventtype="reading_education" educationId="${education}" eventvalue="now" note="read education" />
    </mm:compare>

  </mm:node>
</jsp:root>
