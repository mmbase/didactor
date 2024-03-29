<jsp:root
    xmlns:jsp="http://java.sun.com/JSP/Page"
    xmlns:mm="http://www.mmbase.org/mmbase-taglib-2.0"
    xmlns:di="http://www.didactor.nl/ditaglib_1.0"
    xmlns:c="http://java.sun.com/jsp/jstl/core"
    version="2.0">
  <!--
      Closing a lesson means:

      - making a 'classrel' relation between the user and the learnblock.
      - perhaps also make a popfeedback object and relate it to this new classrel relation
      - Send mail to the teachers of the education of this happening


  -->
  <mm:cloud method="delegate">



    <mm:import externid="lesson" required="true" />

    <mm:node number="${lesson}">

      <!--
           The actual 'closing' of the lesson
      -->
      <mm:createrelation role="classrel" source="user" destination="_node" id="this_classrel" />


      <!--
           Also make a 'popfeedback' object
           I don't quite know who or what is going to use this object.
      -->
      <mm:hasnodemanager name="popfeedback">
        <mm:maycreate type="popfeedback">
          <mm:createnode type="popfeedback" id="this_feedback" />
          <mm:createrelation role="related" source="this_classrel" destination="this_feedback"/>
        </mm:maycreate>
      </mm:hasnodemanager>


      <!--
          Now send mail to coach
      -->
      <c:if test="${di:setting('assessment', 'send_email') eq 'true'}">
        <mm:node number="$user">
          <mm:import id="from"><mm:field name="email"/></mm:import>
          <mm:import id="subject">
            <di:translate key="assessment.give_feedback_subj" write="true">
              <mm:param name="0"><di:person /></mm:param>
              <mm:param name="1"><mm:node number="${classNode}"><mm:nodeinfo type="gui" /></mm:node></mm:param>
            </di:translate>
          </mm:import>

          <mm:node number="${classNode}">
            <mm:nodelistfunction id="teacher" name="teachers">
              <mm:createnode type="emails">
                <mm:setfield name="from"><mm:write referid="from"/></mm:setfield>
                <mm:setfield name="to"><mm:field name="email" node="teacher" /></mm:setfield>
                <mm:setfield name="subject"><mm:write referid="subject"/></mm:setfield>
                <mm:setfield name="body">
                  <di:translate key="assessment.give_feedback_body" write="true">
                    <mm:param name="0"><mm:node number="$user"><di:person /></mm:node></mm:param>
                    <mm:param name="1"><mm:node number="${classNode}"><mm:nodeinfo type="gui" /></mm:node></mm:param>
                    <!-- hmm -->
                    <mm:param name="2">
                      <mm:url page="/homework" referids="classNode@class,user@student_id" absolute="true" escapeamps="false">
                        <mm:param name="sub">assessment</mm:param>
                        <mm:param name="subsub">coach_student_overview</mm:param>
                      </mm:url>
                    </mm:param>
                  </di:translate>
                </mm:setfield>
                <mm:setfield name="type">TYPE_ONESHOT</mm:setfield>
                <mm:function name="startmail" />
              </mm:createnode>
            </mm:nodelistfunction>
          </mm:node>
        </mm:node>
      </c:if>

      <!--
        And to the student
      -->
      <c:if test="${di:setting('assessment', 'send_student_email') eq 'true'}">
        <mm:include page="send_student_mail.jspx" referids="user,lesson" />
      </c:if>


    </mm:node>

    <!--
         And redirect back to where we came from.
    -->
    <mm:redirect page="/homework/" referids="$referids">
      <mm:param name="step">lessonclosed</mm:param>
      <mm:param name="coachmode">false</mm:param>
      <mm:param name="justclosed">true</mm:param>
    </mm:redirect>

  </mm:cloud>
</jsp:root>
