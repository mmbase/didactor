<%@ page import = "java.net.Socket" %>
<%@ page import = "java.net.URLDecoder" %>
<%@ page import = "java.io.*" %>




<%
//       String sRequest = "request=verify_ticket&ticket=BA7059BB518D353ABD2F651DED539935C3963449084BD13FC36E7F35D2E272914696E9BCFA853442F1CB8BB3684FC4CE20AF137A8B68D7CE9515EEAA8AF9F29C9CE9040C79F93597C244D8FE1517A4177B1DF6FF30BBD00FBA77B1776FB5BCF9AC5B8911C20A03E2C47909E91F2B06F529AA6B95A7A066CBB565C8E9B38F7BD020999C6CBEB3448118457940A48C9AC12932A1EDE214C8AC9899288911843B8ACA1C3C6CE598CAE9D43FB723EC39E52A6B414D492B07BB5878994C5C66C65B9F13C3C7F87BDC672115C402FB499ECF8C8145A85B5966900898A4CD82CEFB7B3ED421E139EEDB8CF3A1D10221473F1DDAC5A358FB4DACE65B0A85242AECF6B1A5&app_id=mmbase&uid=john doe&organization=testorg";
//       String sRequest =   "request=kill_ticket&ticket=BA7059BB518D353ABD2F651DED539935C3963449084BD13FC36E7F35D2E272914696E9BCFA853442F1CB8BB3684FC4CE20AF137A8B68D7CE9515EEAA8AF9F29C9CE9040C79F93597C244D8FE1517A4177B1DF6FF30BBD00FBA77B1776FB5BCF9AC5B8911C20A03E2C47909E91F2B06F529AA6B95A7A066CBB565C8E9B38F7BD020999C6CBEB3448118457940A48C9AC12932A1EDE214C8AC9899288911843B8ACA1C3C6CE598CAE9D43FB723EC39E52A6B414D492B07BB5878994C5C66C65B9F13C3C7F87BDC672115C402FB499ECF8C8145A85B5966900898A4CD82CEFB7B3ED421E139EEDB8CF3A1D10221473F1DDAC5A358FB4DACE65B0A85242AECF6B1A5&app_id=mmbase";
         String sRequest = "request=authenticate&app_url=http://localhost:8080/didactor/login_aselect.jsp&app_id=mmbase";

       String agentAddress = "127.0.0.1";
       int agentPort = 1495;

       out.println("<b>request:</b><br/>" + sRequest);
       Socket xSocket = null;
       PrintStream xOut = null;
       BufferedReader xIn = null;
       String xAgentResponse = null;

       xSocket = new Socket(agentAddress, agentPort);
       xOut = new PrintStream(xSocket.getOutputStream());
       xIn = new BufferedReader(new InputStreamReader(xSocket.getInputStream()));

%>

<br>
---------------------------
<br/>


<%

       xOut.println(request);
       xAgentResponse = xIn.readLine();

       out.println("<b>agent's response:</b><br/>" + xAgentResponse);
%>
