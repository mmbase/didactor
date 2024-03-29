/**
 * Didactor javascript object.
 * Currently only arranged 'online reporting' and 'page stay reporting'.
 * But more could perhaps be done here. E.g. content loading of /content/js could perhaps be generalized and migrated to here.
 *
 * One global variable 'didactor' is automaticly created, which can be be referenced (as long as the di:head tag is used).
 * @since Didactor 2.3.0
 * @author Michiel Meeuwissen
 * @version $Id$
 */


function Didactor() {
    var self = this;
    $(document).ready(
        function() {
            self.onlineReporter = self.getSetting("Didactor-OnlineReporter");
            self.url            = self.getSetting("Didactor-URL");
            self.root           = self.getSetting("Didactor-Root");
            self.lastCheck      = new Date();
            self.pageReporter   = self.getSetting("Didactor-PageReporter") == "true";
            self.lastPage       = self.getSetting("Didactor-LastPage"); // not currently used
            self.usedFrames     = {};
            self.questions      = {};

            self.fragments      = [];

            $.timer(500, function(timer) {
	                self.reportOnline();
                        var interval = self.getSetting("Didactor-PageReporterInterval");
                        interval = interval == "" ? 10000 : interval * 1000;
                        if (interval < 10000) interval = 10000;
	                timer.reset(self.pageReporter ? interval : 1000 * 60 * 2);
                    });
            if (self.pageReporter) {
	        $(window).bind("beforeunload", function() {
				   self.loadIconOn();
				   self.reportOnline(null, false); 
				   // we are leaving the page, asynchronous gives 'aborted' in FF
	                       });
            }

            self.content = null;
            for (var i = 0; i < Didactor.contentParameters.length; i++) {
	        var param = Didactor.contentParameters[i];
	        self.content = $.query.get(param);
	        $.query.REMOVE(param);
	        if (self.content != null) break;
            }
            self.block = self.content; // This is the content as defined by the URL. 'block' will not be changed.
            for (var j = 0; j < Didactor.ignoredParameters.length; j++) {
	        var param = Didactor.ignoredParameters[j];
	        $.query.REMOVE(param);
            }
            self.q = $.query.toString();

	    /* Anchors are used for navigation too, so need to refresh the page also if only anchor changed */
	    $("div.mmxf a").live(
		"click",
		function() {
		    var href = this.href;

		    var documentHref = document.location.protocol + "//" + document.location.host + document.location.pathname + document.location.search; // so no hash

		    var hashIndex = href.indexOf("#");
		    var hash = "";
		    if (hashIndex > 0) {
			hash = href.substring(hashIndex);
			href = href.substring(0, hashIndex);
			if (documentHref == href) {
			    var append = href.indexOf("?") > 0 ? "&" : "?";
			    href = href + append + "reload";
			}
		    }
		    document.location.href = href + hash;

		});


            for (var i = 0; i < Didactor.welcomeFiles.length; i++) {
	        var welcomeFile = Didactor.welcomeFiles[i];
	        self.url = self.url.replace(new RegExp(welcomeFile + "$"), "");
            }



            $(document).bind("didactorContentLoaded",  function(ev, data) {
                                 self.setContent(data.number);
                                 self.resolveQuestions(data.loaded);
                             });
            $(document).bind("didactorContent",  function(ev, data) {
                                 self.setContent(data.number);
                                 self.setUpQuestionEvents(data.loaded);
                             });

            // if content is replaced, then first save question
            $(document).bind("didactorContentBeforeUnload",  function(ev, el) {
                                 self.saveQuestions();
                             });
            // if browsing away, then too
            $(window).bind("beforeunload", function() {
			       self.saveQuestions();
                           });



            $(document).bind("didactorContent",
                             function(ev, data) {

                                 $("ul.navigation li:last-child").addClass("last"); // There is a horrible browser which does not understand last-child itself

                                 // Arrange active class of sublearnblock divs.
                                 if (self.sublearnblock != null) {
                                     $(self.sublearnblock).removeClass("active");
                                     $(self.sublearnblock_navigation).removeClass("active");
                                 }
                                 self.sublearnblock            = null;
                                 self.sublearnblock_navigation = null;
                                 self.fillFragments();
                                 if (self.fragments.length > 1) {
                                     self.sublearnblock = "#" + self.fragments[0] + "_" + self.fragments[1] + "_block";
                                     $(self.sublearnblock).addClass("active");
                                 }
                                 $(".subnavigationPage  ul.navigation li").each(
                                     function() {
                                         var li = this;
                                         var a = $(li).find("a")[0];
                                         var href = a.href;
                                         var i = href.indexOf('#');
                                         var div = href.substring(i) + "_block";
                                         if (self.sublearnblock == null) {
                                             // if no explict sub fragment on the URL, take the first one.
                                             self.sublearnblock = div;
                                             self.sublearnblock_navigation = li;
                                         }

                                         if (self.sublearnblock == div) {
                                             // if this is the active sub fragment, make it active
                                             $(li).addClass("active");                  // both the navigation item
                                             $(self.sublearnblock).addClass("active");     // as the block itself
                                         }

                                         $(this).click(function() {
                                                           $(".subnavigationPage  ul.navigation li").removeClass("active");
                                                           $(this).addClass("active");
                                                           $(self.sublearnblock).removeClass("active");
                                                           self.sublearnblock = div;
                                                           self.sublearnblock_navigation = li;
                                                           $(self.sublearnblock).addClass("active");
                                                           document.location.href = href;
                                                           return false;
                                                       });

                                     });
                             });
            // Now load content
            {
                self.fillFragments();
                if (self.fragments.length > 0) {
                    self.openContent(self.fragments[0]);
                }
            }

            // if this is a staticly loaded piece of html, there may be some questions already
            self.resolveQuestions(document);


        });
}

Didactor.contentParameters = ["learnobject", "openSub" ];
Didactor.ignoredParameters = ["referrer" ];
Didactor.welcomeFiles = ["index.jsp", "index.jspx" ];

Didactor.prototype.getSetting = function(name) {
    return $("html head meta[name='" + name + "']").attr("content");
}

Didactor.prototype.reportOnline = function (timer, async) {
    var params;
    var thisCheck = new Date();
    if (this.getSetting("Didactor-PageReporter") == "true") {
	    params = {
            page: this.url + this.q,
            add: thisCheck.getTime() - this.lastCheck.getTime()
        };
	    if (this.content != undefined && this.content != null && this.content != "") {
	        params.content = this.content;
	    }
    } else {
	    params = {};
    }

    params.user = this.getSetting("Didactor-User");
    var self = this;
    $.ajax({async: (async == null ? true : async),
            url: this.onlineReporter,
            type: "GET",
            data: params,
	    complete: function(res, status) {
                var xml = res.responseXML;
		if (xml != null && "offline" == xml.firstChild.nodeName) {
		    window.location.href = this.getSetting("Didactor-Root");
		}
	    }
	   });
    this.lastCheck = thisCheck;
}

Didactor.prototype.setContent = function(c) {
    if (this.pageReporter) {
	this.reportOnline();
    }
    this.content = c;
}

Didactor.prototype.fillFragments = function() {
    var url = document.location.href;
    var fragmentIndex = url.indexOf('#');
    if (fragmentIndex > 0) {
        this.fragments = url.substring(fragmentIndex + 1).split(/[_#]/);
    }
}

Didactor.prototype.setUpQuestionEvents = function(div) {
    var did = this;
    $(div).find("div.question").each(
        function() {
	    if (this.alreadySetUpQuestionEvents) return;
	    this.alreadySetUpQuestionEvents = true;
            var qdiv = this;
            var a = qdiv.a;
            $(qdiv).find("textarea").keyup(function() {
                                               did.questions[a][0] = true;
                                           });
            $(qdiv).find("input").change(function() {
                                             did.questions[a][0] = true;
                                         });
            $(qdiv).find(".answerquestion").click(
                function() {
                    var params = {};
                    $(qdiv).find("textarea").each(function() {
                                                      params[this.name] = this.value;
                                                  });
                    $(qdiv).find("input").each(function() {
                                                   if ((this.type == "checkbox" || this.type == "radio") && ! this.checked) {
                                                   } else {
                                                       params[this.name] = this.value;
                                                   }
                                               });
                    $.ajax({url: this.href, async: false,  // Does work very well on unload if async (at least not in FF)
			    type: "POST", dataType: "xml", data: params,
                            complete: function(res, status) { 
                                if (status == "success") {
                                    $(div).append(res.responseText);
                                } else {
                                    alert(status + " " + res.responseText);
                                }
                            }
                           });
                    return false;
                });
        });
}

Didactor.prototype.resolveQuestions = function(el) {
    var did = this;
    this.loadIconOn();
    try {
	$(el).find(".nm_questions").each(
            function() {
		var div = $("<div  />");
		var d = div[0];
		var a = this;
		if (did.questions[a] == null) {
                    did.questions[a] = [false, d];
		}
		var href = a.href + "&learnobject=" + did.content;
		$.ajax({async: true, url: href, type: "GET", dataType: "xml", data: null,
			complete: function(res, status){
                            div.append(res.responseText);
                            div.find("div.question")[0].a = a;
                            did.setUpQuestionEvents(d);
                    }});
		$(this).after(div);
		$(this).remove();
            });
    } catch (e) {
	alert(e);
    }
    this.loadIconOff();

}

Didactor.prototype.saveQuestions = function() {
    var didactor = this;
    for (key in didactor.questions) {
        var status = didactor.questions[key];
        var changed = status[0];
        var div = status[1];
        if (changed) {
            $(div).find(".answerquestion").click();
            didactor.questions[key][0] = false;
        }
    }
}


/**
 * Request content using AJAX from the server
 */
Didactor.prototype.requestContent = function(href, number) {
    var contentEl = document.getElementById('contentFrame');
    $(document).trigger("didactorContentBeforeUnload",  { unloaded: contentEl });
    var content = this.usedFrames[href];
    var self = this;
    if (content == null) {
        self.loadIconOn();
        $.ajax({async: true, url: href, type: "GET", dataType: "xml", data: null,
                complete: function(res, status){
                    self.loadIconOff();
		    $(contentEl).css({opacity: 1.0});
                    if (status == "success") {
                        $(contentEl).empty();
                        $(document).trigger("didactorContentBeforeLoaded",  { response: res, number: number });
                        $(contentEl).append(res.responseText);
                        // console.log("updating " + contentEl + "with" + xmlhttp.responseXML);
                        contentEl.validator = new MMBaseValidator();
                        //contentEl.validator.logEnabled = true;
                        //contentEl.validator.traceEnabled = true;
                        contentEl.validator.validateHook = function(valid) {
                            var buttons = $(contentEl).find("input.formbutton");
                            for (i = 0; i < buttons.length; i++) {
                                var disabled = (contentEl.validator.invalidElements > 0);
                                buttons[i].disabled = disabled;
                                // just because IE does not recognize input[disabled]
                                // IE SUCKS
                                buttons[i].className = "formbutton " + (disabled ? "disabled" : "enabled");
                            }
                        };
                        contentEl.validator.validatePage(false, contentEl);
                        contentEl.validator.addValidation(contentEl);
                        check(res.responseXML.documentElement.getAttribute('class'));
                        document.href_frame = href;
                        var array = [];
                        // in case it is more than one element (e.g. comments or so), store all childnodes.

                        try {
                            for (var i = 0; i < contentEl.childNodes.length; i++) {
                                array.push(contentEl.childNodes[i]);
                            }
                        } catch (ex) {
                            alert(ex);
                        }
                        self.usedFrames[href] = array;
                        if ($.browser.msie && $.browser.version.substr(0, 3) <= 6.0) {
                            // alert("IE 6 is a horrible browser which cannot do this correctly at once
                            setTimeout(function() {
                                $(contentEl).empty();
                                for (var i = 0; i < array.length; i++) {
                                    contentEl.appendChild(array[i]);
                                }
                                $(document).trigger("didactorContentLoaded",  { loaded: contentEl, number: number });
                                $(document).trigger("didactorContent",  { loaded: contentEl, number: number });
                            }, 500);
                        } else {
                            $(document).trigger("didactorContentLoaded",  { loaded: contentEl, number: number });
                            $(document).trigger("didactorContent",  { loaded: contentEl, number: number });
                        }

                    }
                }
           });
    } else {
        $(contentEl).empty();
        for (var i = 0; i < content.length; i++) {
            contentEl.appendChild(content[i]);
        }
        document.href_frame = href;
        $(document).trigger("didactorContent",  { loaded: contentEl, number: number });
    }
    //scrollToTop();
};




/**
 * Opens content with a certain number
 * @param type (optional, is supposed to be absent if first argument numeric). The type of the content.
 * @param number MMBase object number as an integer.
 */
Didactor.prototype.openContent = function(type, number) {
    // The 'type' argument is optional.
    // So, of the first argument is numeric. Interpret that has the 'number".
    if (/^[+-]?\d+$/.test(type)) {
        number = type;
        type = null;
    }
    var navigationElement = $("#a_" + number)[0];

    if (this.currentNavigationElement == null) {
        // For some reason, e.g. on intial load and 'default 'navigation element is not yet known, try to determin it.
        this.currentNavigationElement = $(navigationElement).siblings("a.active");
    }
    if (this.currentNavigationElement != null) {
        $(this.currentNavigationElement).removeClass("active");
    }

    if ( number > 0 ) {
        currentnumber = number;
    }

    var href = addParameter(this.root + 'content/', 'object=' + number);
    if (type != null && type != '') {
        href = addParameter(href, 'type=' + type);
    }
    this.requestContent(href, number);
    this.currentNavigationElement = navigationElement;
    if (this.currentNavigationElement != null) {
        $(this.currentNavigationElement).addClass("active");
    }
    return false;

};



Didactor.prototype.loadIconOn = function()  {
    var ajax = document.getElementById("ajax_loader");
    if (ajax) ajax.style.display = "inline";
    var contentEls = $("#contentFrame").find("> *");
    contentEls.css({opacity: 0.3});
    contentEls.bind("click.loading", 
		    function() {
			return false;
		    });
}
Didactor.prototype.loadIconOff = function() {
    var ajax = document.getElementById("ajax_loader");
    if (ajax) ajax.style.display = "none";
    var contentEls = $("#contentFrame").find("> *");
    contentEls.css({opacity: 1});
    contentEls.unbind("click.loading");
}



var didactor = new Didactor();
