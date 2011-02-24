/*<%@taglib uri="http://www.mmbase.org/mmbase-taglib-2.0" prefix="mm"
%><%@taglib uri="http://www.didactor.nl/ditaglib_1.0" prefix="di"
%>*///<mm:content expires="604800" type="text/javascript" postprocessor="javascript-compress"><mm:cloud>

$(document).ready(
    function() {
	$("thead.togglehead").click(
	    function() {
		$(this).find("th.listHeader img").toggle();
		$(this).next("tbody.toggle_div").toggle();
		
	    });
    });
//</mm:cloud></mm:content>
