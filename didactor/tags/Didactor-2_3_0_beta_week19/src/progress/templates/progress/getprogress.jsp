<%@taglib uri="http://www.mmbase.org/mmbase-taglib-2.0" prefix="mm" 
%><%@taglib uri="http://www.didactor.nl/ditaglib_1.0" prefix="di" 
%><%@taglib uri="http://www.opensymphony.com/oscache" prefix="os"
%>
<mm:cloud method="delegate">

<jsp:directive.include file="/shared/setImports.jsp" />
<jsp:directive.include file="/education/tests/definitions.jsp" />


<%-- report either the current user's progress, or the one given by "student" argument --%>
<mm:import externid="student" id="student"><mm:write referid="user"/></mm:import>


<mm:node number="$student" notfound="skip">

   <%-- find user's copybook --%>
   <jsp:directive.include file="find_copybook.jsp" />

   
   <os:cache time="${empty copybookNo ? 600 : 0}" key="progress-${education}-${student}-${copybookNo}">
     <%-- performance of this is very bad if no copybook DIDACTOR-50 
          So caching it some time, to increase responsiveness.
     --%>
     <%
     int nof_tests= 0;
     int nof_tests_passed= 0;
     %>
     
     <mm:node number="$education" notfound="skip">
       <mm:import id="previousnumber"><mm:field name="number"/></mm:import>
       
       <mm:relatednodescontainer type="learnobjects" role="posrel">
         <mm:sortorder field="posrel.pos" direction="up"/>
         
         <mm:tree type="learnobjects" role="posrel" searchdir="destination" orderby="posrel.pos" directions="up">
           <mm:nodeinfo type="type">
             <mm:compare value="tests">
               <% nof_tests++; %>
               <mm:import id="testNo" reset="true"><mm:field name="number"/></mm:import>
               
               <jsp:directive.include file="teststatus.jspx" />

               <mm:compare referid="teststatus" value="passed">
                  <% nof_tests_passed++; %>
               </mm:compare>
            </mm:compare>
           </mm:nodeinfo>
         </mm:tree>
      </mm:relatednodescontainer>
      
      <%=(double)nof_tests_passed / (double)nof_tests%>

     </mm:node>
   </os:cache>

</mm:node>

</mm:cloud>


