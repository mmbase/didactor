<%@ page import = "org.mmbase.bridge.*" %>


<mm:node number="component.assessment" notfound="skip">
   <mm:node number="$learnobject" jspvar="nodeLearnObject">
     <mm:hasrelationmanager role="DescriptionRel" sourcemanager="$_node" destinationmanager="object" >
      <mm:related path="descriptionrel,object" searchdir="destination">
         <a href="#" style="text-decoration:none">
            <% //so that Mozilla thinks the table below is an URL and shows a correct cursor :) %>
            <table border="1" cellpadding="0" cellspacing="0" width="70%" style="color:#FFFFFF;background:#949494;cursor:hand"
               onClick="top.location.href='<mm:url referids="provider,education,class" page="../index.jsp">
                                              <mm:node element="object">
                                                 <mm:param name="learnobject"><mm:field name="number"/></mm:param>
                                                 <mm:param name="the_only_node_to_show"><mm:field name="number"/></mm:param>
                                                 <mm:param name="return_to"><%= nodeLearnObject.getNumber() %></mm:param>
                                                 <mm:param name="return_to_type"><%= nodeLearnObject.getNodeManager().getName() %></mm:param>
                                              </mm:node>
                                           </mm:url>'">

               <tr>
                  <td width="0px">
                     <mm:node element="object" jspvar="nodeObject">
                        <%
                           Node nodeParent = nodeObject;
                           while(true){
                              if("learnblocks".equals(nodeObject.getCloud().getNode(nodeParent.getNumber()).getNodeManager().getName())){
                                 break;
                              }
                              else{
                                 NodeList nlParents = nodeParent.getRelatedNodes("object", "posrel", "source");
                                 if(nlParents.size() > 0){
                                    nodeParent = nlParents.getNode(0);
                                 }
                                 else{
                                    break;
                                 }
                              }
                           }

                        %>

                        <mm:node number="<%= "" + nodeParent.getNumber() %>">
                           <mm:relatednodes type="images" max="1">
                              <img src="<mm:image template="s(200)"/>" />
                           </mm:relatednodes>
                        </mm:node>
                     </mm:node>
                  </td>
                  <td width="100%">
                     <div style="padding-left:20px;">
                        <mm:node element="object">
                           <mm:field name="name"/>
                        </mm:node>
                        <br />
                        <mm:node element="descriptionrel">
                           <mm:field name="description"/>
                        </mm:node>
                     </div>
                  </td>
               </tr>
            </table>
         </a>
      </mm:related>
      </mm:hasrelationmanager>
   </mm:node>
</mm:node>
