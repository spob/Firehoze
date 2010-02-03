/**
 * jQuery plugin always_at_bottom
 *
 * If the content of web page is tiny then footer shows up in the middle of the page.
 * This plugin ensures that footer is always at the bottom.
 *
 * Usage:
 * $('#footer').always_at_bottom();
 *
 * This plugin depends on jQuery 1.3+
 *
 * Author: Neeraj
 * Blog: www.neeraj.name
 * version: 0.0.1
 * Last updated: 19-August-2009
 *
 */


(function($){
 
  $.fn.always_at_bottom = function(){
 
    return this.each(function(){
      var $this = $(this);

      if($(document.body).height() < $(window).height()){

//				alert("setting footer");
        //exteranl css properties are available only on window.onLoad (safari/chrome)
        $(window).load(function(){
          var footer_width = $this.css('width');
          var footer_margin_bottom = $this.css('margin-bottom');
          var footer_margin_bottom_d = getDigitFromDigitPX(footer_margin_bottom);
          var footer_bottom_position_should_be = 0  - footer_margin_bottom_d;
          $this.css({position: "absolute", bottom:(footer_bottom_position_should_be + "px"), 'width':footer_width});
        });

      }; // end of if statement
 
      // getDigitFromDigitPX('20px') => 20 
      function getDigitFromDigitPX(input){
        var re = new RegExp(/(\d*)px/);
        var m = re.exec(input);
        if (m == null) {
          return 0;
        } else {
          return  parseInt(m[1]);
        }
      };// end of function getDigitFromDigitPX


    }); // end of return this.each(function())
  }; // end of pluging
})(jQuery);


/*******
	***	Anchor Slider by Cedric Dugas   ***
	*** Http://www.position-absolute.com ***
*****/
jQuery.fn.anchorAnimate = function(settings) {

    settings = jQuery.extend({
        speed : 400
    }, settings);

    return this.each(function(){
        var caller = this
        $(caller).click(function (event) {

            event.preventDefault()
            var locationHref = window.location.href
            var elementClick = $(caller).attr("href")

            var destination = $(elementClick).offset().top;
            $("html:not(:animated),body:not(:animated)").animate({
                scrollTop: destination
            }, settings.speed, function() {
                window.location.hash = elementClick
            });
            return false;
        })
    })
}

/**
* Cornerz 0.6 - Bullet Proof Corners
* Jonah Fox (jonah@parkerfox.co.uk) 2008
* 
* Usage: $('.myclass').curve(options)
* options is a hash with the following parameters. Bracketed is the default
*   radius (10)
*   borderWidth (read from BorderTopWidth or 0)
*   background ("white"). Note that this is not calculated from the HTML as it is expensive
*   borderColor (read from BorderTopColor)
*   corners ("tl br tr bl"). Specify which borders
*   fixIE ("padding") - attmepts to fix IE by incrementing the property by 1 if the outer width/height is odd.

CHANGELIST from  v0.4

0.5 - Now attempts to fix the odd dimension problem in IE 
0.6 - Added semicolons for packing and fixed a problem with odd border width's in IE

*/
    
;(function($){

  if($.browser.msie && document.namespaces["v"] == null) {
    document.namespaces.add("v", "urn:schemas-microsoft-com:vml", "#default#VML");
  }

  $.fn.cornerz = function(options){
    
    function canvasCorner(t,l, r,bw,bc,bg){
	    var sa,ea,cw,sx,sy,x,y, p = 1.57, css="position:absolute;";
	    if(t) 
		    {sa=-p; sy=r; y=0; css+="top:-"+bw+"px;";  }
	    else 
		    {sa=p; sy=0; y=r; css+="bottom:-"+bw+"px;"; }
	    if(l) 
		    {ea=p*2; sx=r; x=0;	css+="left:-"+bw+"px;";}
	    else 
		    {ea=0; sx=0; x=r; css+="right:-"+bw+"px;";	}
		
	    var canvas=$("<canvas width="+r+"px height="+ r +"px style='" + css+"' ></canvas>");
	    var ctx=canvas[0].getContext('2d');
	    ctx.beginPath();
	    ctx.lineWidth=bw*2;	
	    ctx.arc(sx,sy,r,sa,ea,!(t^l));
	    ctx.strokeStyle=bc;
	    ctx.stroke();
	    ctx.lineWidth = 0;
	    ctx.lineTo(x,y);
	    ctx.fillStyle=bg;
	    ctx.fill();
	    return canvas;
    };

    function canvasCorners(corners, r, bw,bc,bg) {
	    var hh = $("<div style='display: inherit' />"); // trying out style='float:left' 
	    $.each(corners.split(" "), function() {
	      hh.append(canvasCorner(this[0]=="t",this[1]=="l", r,bw,bc,bg));
	    });
	    return hh;
    };

    function vmlCurve(r,b,c,m,ml,mt, right_fix) {
        var l = m-ml-right_fix;
        var t = m-mt;
        return "<v:arc filled='False' strokeweight='"+b+"px' strokecolor='"+c+"' startangle='0' endangle='361' style=' top:" + t +"px;left: "+ l + "px;width:" + r+ "px; height:" + r+ "px' />";
    }
    

    function vmlCorners(corners, r, bw, bc, bg, w) {
      var h ="<div style='text-align:left; '>";
      $.each($.trim(corners).split(" "), function() {
        var css,ml=1,mt=1,right_fix=0;
        if(this.charAt(0)=="t") {
          css="top:-"+bw+"px;";
        }
        else {
          css= "bottom:-"+bw+"px;";
          mt=r+1;
        }
        if(this.charAt(1)=="l")
          css+="left:-"+bw+"px;";
        else {
          css +="right:-"+(bw)+"px; "; // odd width gives wrong margin?
           ml=r;
           right_fix = 1;
        }

        h+="<div style='"+css+"; position: absolute; overflow:hidden; width:"+ r +"px; height: " + r + "px;'>";
        h+= "<v:group  style='width:1000px;height:1000px;position:absolute;' coordsize='1000,1000' >";
        h+= vmlCurve(r*3,r+bw,bg, -r/2,ml,mt,right_fix); 
        if(bw>0)
          h+= vmlCurve(r*2-bw,bw,bc, Math.floor(bw/2+0.5),ml,mt,right_fix);
        h+="</v:group>";
        h+= "</div>"; 
      });
      h += "</div>";
      
      return h;
    };

    var settings = {
      corners : "tl tr bl br",
      radius : 10,
      background: "white",
      borderWidth: 0,
      fixIE: true };              
    $.extend(settings, options || {});
    
    var incrementProperty = function(elem, prop, x) {
      var y = parseInt(elem.css(prop), 10) || 0 ;
      elem.css(prop, x+y);
    };
    
    
    return this.each(function() {
      
      var $$ = $(this);
      var r = settings.radius*1.0;
      var bw = (settings.borderWidth || parseInt($$.css("borderTopWidth"), 10) || 0)*1.0;
      var bg = settings.background;
      var bc = settings.borderColor;
      bc = bc || ( bw > 0 ? $$.css("borderTopColor") : bg);
            
      var cs = settings.corners;

      if($.browser.msie) {//need to use innerHTML rather than jQuery
        h = vmlCorners(cs,r,bw,bc,bg, $(this).width() );     
        this.insertAdjacentHTML('beforeEnd', h);
        
      }
      else  //canvasCorners returns a DOM element
        $$.append(canvasCorners(cs,r,bw,bc,bg));
      
      
      if(this.style.position != "absolute")
        this.style.position = "relative";
     
       this.style.zoom = 1; // give it a layout in IE
      
       if($.browser.msie && settings.fixIE) {
          var ow = $$.outerWidth();
          var oh = $$.outerHeight();
          
          if(ow%2 == 1) {
            incrementProperty($$, "padding-right", 1);
            incrementProperty($$, "margin-right", 1);
          }

          if(oh%2 == 1) { 
            incrementProperty($$, "padding-bottom", 1);
            incrementProperty($$, "margin-bottom", 1);
          }
        }
          
      }
      
    );
 
  };
})(jQuery);


/*
* jQuery Simply Countable plugin
* Provides a character counter for any text input or textarea
* 
* @version  0.3
* @homepage http://github.com/aaronrussell/jquery-simply-countable/
* @author   Aaron Russell (http://www.aaronrussell.co.uk)
*
* Copyright (c) 2009 Aaron Russell (aaron@gc4.co.uk)
* Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
* and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
*/

(function($){

  $.fn.simplyCountable = function(options){
    
    options = $.extend({
      counter: '#counter',
      countType: 'characters',
      maxCount: 140,
      strictMax: false,
      countDirection: 'down',
      safeClass: 'safe',
      overClass: 'over',
      thousandSeparator: ','
    }, options);
    
    var countable = this;
    
    var countCheck = function(){
           
      var count;
      
      /* Calculates count for either words or characters */
      if (options.countType === 'words'){
        count = options.maxCount - countable.val().split(/[\s]+/).length;
        if (countable.val() === ''){ count += 1; }
      }
      else { count = options.maxCount - countable.val().length; }
      
      /* If strictMax set restrict further characters */
      if (options.strictMax && count <= 0){
        var content = countable.val();
        if (options.countType === 'words'){
          countable.val(content.split(/[\s]+/).slice(0, options.maxCount).join(' '));
        }
        else { countable.val(content.substring(0, options.maxCount)); }
        count = 0;
      }
      
      /* Set CSS class rules */
      if (!$(options.counter).hasClass(options.safeClass) && !$(options.counter).hasClass(options.overClass)){
        if (count < 0){ $(options.counter).addClass(options.overClass); }
        else { $(options.counter).addClass(options.safeClass); }
      }
      else if (count < 0 && $(options.counter).hasClass(options.safeClass)){
        $(options.counter).removeClass(options.safeClass).addClass(options.overClass);
      }
      else if (count >= 0 && $(options.counter).hasClass(options.overClass)){
        $(options.counter).removeClass(options.overClass).addClass(options.safeClass);
      }
      
      /* If countDirect is 'up' then reverse the count */
      if (options.countDirection === 'up'){
        count = count - (count*2) + options.maxCount;
      }
      
      /* Add thousandSeparator for those massive counts */
      if (options.thousandSeparator){
        count = count.toString();
        for (var i = count.length-3; i > 0; i -= 3){
          count = count.substr(0,i) + options.thousandSeparator + count.substr(i);
        }
      }
      $(options.counter).text(count);
    };
    countCheck();
    
    countable.keyup(countCheck);
    
  };

})(jQuery);


// HTML Truncator for jQuery
// by Henrik Nyh <http://henrik.nyh.se> 2008-02-28.
// Free to modify and redistribute with credit.

(function($) {

    var trailing_whitespace = true;

    $.fn.truncate = function(options) {

        var opts = $.extend({}, $.fn.truncate.defaults, options);

        $(this).each(function() {

            var content_length = $.trim(squeeze($(this).text())).length;
            if (content_length <= opts.max_length)
                return;  // bail early if not overlong

            var actual_max_length = opts.max_length - opts.more.length - 3;  // 3 for " ()"
            var truncated_node = recursivelyTruncate(this, actual_max_length);
            var full_node = $(this).hide();
            truncated_node.insertAfter(full_node);

            findNodeForMore(truncated_node).append(' ... <a href="#show more content">'+opts.more+'</a>');
            findNodeForLess(full_node).append(' <a href="#show less content">'+opts.less+'</a>');

            var fade = 0; // 0 will create no fade for fadeIn() fadeOut() otherwise these functions still use fading 'normal'

            // And the fade option here:
            if(opts.fade){
                fade = opts.fade;
            } // Added fade option..

            truncated_node.find('a:last').click(function() {
                truncated_node.fadeOut(fade,function() {
                    full_node.fadeIn(fade);
                });
                return false; // New Fading Settings
            });
            full_node.find('a:last').click(function() {
                full_node.fadeOut(fade,function(){
                    truncated_node.fadeIn(fade);
                });
                return false; // New Fading Settings
            });
        });
    }

    // Note that the " (…more)" bit counts towards the max length – so a max
    // length of 10 would truncate "1234567890" to "12 (…more)".
    $.fn.truncate.defaults = {
        max_length: 100,
        more: '…more',
        less: 'less'
    };

    function recursivelyTruncate(node, max_length) {
        return (node.nodeType == 3) ? truncateText(node, max_length) : truncateNode(node, max_length);
    }

    function truncateNode(node, max_length) {
        var node = $(node);
        var new_node = node.clone().empty();
        var truncatedChild;
        node.contents().each(function() {
            var remaining_length = max_length - new_node.text().length;
            if (remaining_length == 0) return;  // breaks the loop
            truncatedChild = recursivelyTruncate(this, remaining_length);
            if (truncatedChild) new_node.append(truncatedChild);
        });
        return new_node;
    }

    function truncateText(node, max_length) {
        var text = squeeze(node.data);
        if (trailing_whitespace)  // remove initial whitespace if last text
            text = text.replace(/^ /, '');  // node had trailing whitespace.
        trailing_whitespace = !!text.match(/ $/);
        var text = text.slice(0, max_length);
        // Ensure HTML entities are encoded
        // http://debuggable.com/posts/encode-html-entities-with-jquery:480f4dd6-13cc-4ce9-8071-4710cbdd56cb
        text = $('<div/>').text(text).html();
        return text;
    }

    // Collapses a sequence of whitespace into a single space.
    function squeeze(string) {
        return string.replace(/\s+/g, ' ');
    }

    // Finds the last, innermost block-level element
    function findNodeForMore(node) {
        var $node = $(node);
        var last_child = $node.children(":last");
        if (!last_child) return node;
        var display = last_child.css('display');
        if (!display || display=='inline') return $node;
        return findNodeForMore(last_child);
    };

    // Finds the last child if it's a p; otherwise the parent
    function findNodeForLess(node) {
        var $node = $(node);
        var last_child = $node.children(":last");
        if (last_child && last_child.is('p')) return last_child;
        return node;
    };

})(jQuery);


/*
 * jQuery validation plug-in 1.6
 *
 * http://bassistance.de/jquery-plugins/jquery-plugin-validation/
 * http://docs.jquery.com/Plugins/Validation
 *
 * Copyright (c) 2006 - 2008 Jörn Zaefferer
 *
 * $Id: jquery.validate.js 6403 2009-06-17 14:27:16Z joern.zaefferer $
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */
(function($){$.extend($.fn,{validate:function(options){if(!this.length){options&&options.debug&&window.console&&console.warn("nothing selected, can't validate, returning nothing");return;}var validator=$.data(this[0],'validator');if(validator){return validator;}validator=new $.validator(options,this[0]);$.data(this[0],'validator',validator);if(validator.settings.onsubmit){this.find("input, button").filter(".cancel").click(function(){validator.cancelSubmit=true;});if(validator.settings.submitHandler){this.find("input, button").filter(":submit").click(function(){validator.submitButton=this;});}this.submit(function(event){if(validator.settings.debug)event.preventDefault();function handle(){if(validator.settings.submitHandler){if(validator.submitButton){var hidden=$("<input type='hidden'/>").attr("name",validator.submitButton.name).val(validator.submitButton.value).appendTo(validator.currentForm);}validator.settings.submitHandler.call(validator,validator.currentForm);if(validator.submitButton){hidden.remove();}return false;}return true;}if(validator.cancelSubmit){validator.cancelSubmit=false;return handle();}if(validator.form()){if(validator.pendingRequest){validator.formSubmitted=true;return false;}return handle();}else{validator.focusInvalid();return false;}});}return validator;},valid:function(){if($(this[0]).is('form')){return this.validate().form();}else{var valid=true;var validator=$(this[0].form).validate();this.each(function(){valid&=validator.element(this);});return valid;}},removeAttrs:function(attributes){var result={},$element=this;$.each(attributes.split(/\s/),function(index,value){result[value]=$element.attr(value);$element.removeAttr(value);});return result;},rules:function(command,argument){var element=this[0];if(command){var settings=$.data(element.form,'validator').settings;var staticRules=settings.rules;var existingRules=$.validator.staticRules(element);switch(command){case"add":$.extend(existingRules,$.validator.normalizeRule(argument));staticRules[element.name]=existingRules;if(argument.messages)settings.messages[element.name]=$.extend(settings.messages[element.name],argument.messages);break;case"remove":if(!argument){delete staticRules[element.name];return existingRules;}var filtered={};$.each(argument.split(/\s/),function(index,method){filtered[method]=existingRules[method];delete existingRules[method];});return filtered;}}var data=$.validator.normalizeRules($.extend({},$.validator.metadataRules(element),$.validator.classRules(element),$.validator.attributeRules(element),$.validator.staticRules(element)),element);if(data.required){var param=data.required;delete data.required;data=$.extend({required:param},data);}return data;}});$.extend($.expr[":"],{blank:function(a){return!$.trim(""+a.value);},filled:function(a){return!!$.trim(""+a.value);},unchecked:function(a){return!a.checked;}});$.validator=function(options,form){this.settings=$.extend({},$.validator.defaults,options);this.currentForm=form;this.init();};$.validator.format=function(source,params){if(arguments.length==1)return function(){var args=$.makeArray(arguments);args.unshift(source);return $.validator.format.apply(this,args);};if(arguments.length>2&&params.constructor!=Array){params=$.makeArray(arguments).slice(1);}if(params.constructor!=Array){params=[params];}$.each(params,function(i,n){source=source.replace(new RegExp("\\{"+i+"\\}","g"),n);});return source;};$.extend($.validator,{defaults:{messages:{},groups:{},rules:{},errorClass:"error",validClass:"valid",errorElement:"label",focusInvalid:true,errorContainer:$([]),errorLabelContainer:$([]),onsubmit:true,ignore:[],ignoreTitle:false,onfocusin:function(element){this.lastActive=element;if(this.settings.focusCleanup&&!this.blockFocusCleanup){this.settings.unhighlight&&this.settings.unhighlight.call(this,element,this.settings.errorClass,this.settings.validClass);this.errorsFor(element).hide();}},onfocusout:function(element){if(!this.checkable(element)&&(element.name in this.submitted||!this.optional(element))){this.element(element);}},onkeyup:function(element){if(element.name in this.submitted||element==this.lastElement){this.element(element);}},onclick:function(element){if(element.name in this.submitted)this.element(element);else if(element.parentNode.name in this.submitted)this.element(element.parentNode)},highlight:function(element,errorClass,validClass){$(element).addClass(errorClass).removeClass(validClass);},unhighlight:function(element,errorClass,validClass){$(element).removeClass(errorClass).addClass(validClass);}},setDefaults:function(settings){$.extend($.validator.defaults,settings);},messages:{required:"This field is required.",remote:"Please fix this field.",email:"Please enter a valid email address.",url:"Please enter a valid URL.",date:"Please enter a valid date.",dateISO:"Please enter a valid date (ISO).",number:"Please enter a valid number.",digits:"Please enter only digits.",creditcard:"Please enter a valid credit card number.",equalTo:"Please enter the same value again.",accept:"Please enter a value with a valid extension.",maxlength:$.validator.format("Please enter no more than {0} characters."),minlength:$.validator.format("Please enter at least {0} characters."),rangelength:$.validator.format("Please enter a value between {0} and {1} characters long."),range:$.validator.format("Please enter a value between {0} and {1}."),max:$.validator.format("Please enter a value less than or equal to {0}."),min:$.validator.format("Please enter a value greater than or equal to {0}.")},autoCreateRanges:false,prototype:{init:function(){this.labelContainer=$(this.settings.errorLabelContainer);this.errorContext=this.labelContainer.length&&this.labelContainer||$(this.currentForm);this.containers=$(this.settings.errorContainer).add(this.settings.errorLabelContainer);this.submitted={};this.valueCache={};this.pendingRequest=0;this.pending={};this.invalid={};this.reset();var groups=(this.groups={});$.each(this.settings.groups,function(key,value){$.each(value.split(/\s/),function(index,name){groups[name]=key;});});var rules=this.settings.rules;$.each(rules,function(key,value){rules[key]=$.validator.normalizeRule(value);});function delegate(event){var validator=$.data(this[0].form,"validator");validator.settings["on"+event.type]&&validator.settings["on"+event.type].call(validator,this[0]);}$(this.currentForm).delegate("focusin focusout keyup",":text, :password, :file, select, textarea",delegate).delegate("click",":radio, :checkbox, select, option",delegate);if(this.settings.invalidHandler)$(this.currentForm).bind("invalid-form.validate",this.settings.invalidHandler);},form:function(){this.checkForm();$.extend(this.submitted,this.errorMap);this.invalid=$.extend({},this.errorMap);if(!this.valid())$(this.currentForm).triggerHandler("invalid-form",[this]);this.showErrors();return this.valid();},checkForm:function(){this.prepareForm();for(var i=0,elements=(this.currentElements=this.elements());elements[i];i++){this.check(elements[i]);}return this.valid();},element:function(element){element=this.clean(element);this.lastElement=element;this.prepareElement(element);this.currentElements=$(element);var result=this.check(element);if(result){delete this.invalid[element.name];}else{this.invalid[element.name]=true;}if(!this.numberOfInvalids()){this.toHide=this.toHide.add(this.containers);}this.showErrors();return result;},showErrors:function(errors){if(errors){$.extend(this.errorMap,errors);this.errorList=[];for(var name in errors){this.errorList.push({message:errors[name],element:this.findByName(name)[0]});}this.successList=$.grep(this.successList,function(element){return!(element.name in errors);});}this.settings.showErrors?this.settings.showErrors.call(this,this.errorMap,this.errorList):this.defaultShowErrors();},resetForm:function(){if($.fn.resetForm)$(this.currentForm).resetForm();this.submitted={};this.prepareForm();this.hideErrors();this.elements().removeClass(this.settings.errorClass);},numberOfInvalids:function(){return this.objectLength(this.invalid);},objectLength:function(obj){var count=0;for(var i in obj)count++;return count;},hideErrors:function(){this.addWrapper(this.toHide).hide();},valid:function(){return this.size()==0;},size:function(){return this.errorList.length;},focusInvalid:function(){if(this.settings.focusInvalid){try{$(this.findLastActive()||this.errorList.length&&this.errorList[0].element||[]).filter(":visible").focus();}catch(e){}}},findLastActive:function(){var lastActive=this.lastActive;return lastActive&&$.grep(this.errorList,function(n){return n.element.name==lastActive.name;}).length==1&&lastActive;},elements:function(){var validator=this,rulesCache={};return $([]).add(this.currentForm.elements).filter(":input").not(":submit, :reset, :image, [disabled]").not(this.settings.ignore).filter(function(){!this.name&&validator.settings.debug&&window.console&&console.error("%o has no name assigned",this);if(this.name in rulesCache||!validator.objectLength($(this).rules()))return false;rulesCache[this.name]=true;return true;});},clean:function(selector){return $(selector)[0];},errors:function(){return $(this.settings.errorElement+"."+this.settings.errorClass,this.errorContext);},reset:function(){this.successList=[];this.errorList=[];this.errorMap={};this.toShow=$([]);this.toHide=$([]);this.currentElements=$([]);},prepareForm:function(){this.reset();this.toHide=this.errors().add(this.containers);},prepareElement:function(element){this.reset();this.toHide=this.errorsFor(element);},check:function(element){element=this.clean(element);if(this.checkable(element)){element=this.findByName(element.name)[0];}var rules=$(element).rules();var dependencyMismatch=false;for(method in rules){var rule={method:method,parameters:rules[method]};try{var result=$.validator.methods[method].call(this,element.value.replace(/\r/g,""),element,rule.parameters);if(result=="dependency-mismatch"){dependencyMismatch=true;continue;}dependencyMismatch=false;if(result=="pending"){this.toHide=this.toHide.not(this.errorsFor(element));return;}if(!result){this.formatAndAdd(element,rule);return false;}}catch(e){this.settings.debug&&window.console&&console.log("exception occured when checking element "+element.id
+", check the '"+rule.method+"' method",e);throw e;}}if(dependencyMismatch)return;if(this.objectLength(rules))this.successList.push(element);return true;},customMetaMessage:function(element,method){if(!$.metadata)return;var meta=this.settings.meta?$(element).metadata()[this.settings.meta]:$(element).metadata();return meta&&meta.messages&&meta.messages[method];},customMessage:function(name,method){var m=this.settings.messages[name];return m&&(m.constructor==String?m:m[method]);},findDefined:function(){for(var i=0;i<arguments.length;i++){if(arguments[i]!==undefined)return arguments[i];}return undefined;},defaultMessage:function(element,method){return this.findDefined(this.customMessage(element.name,method),this.customMetaMessage(element,method),!this.settings.ignoreTitle&&element.title||undefined,$.validator.messages[method],"<strong>Warning: No message defined for "+element.name+"</strong>");},formatAndAdd:function(element,rule){var message=this.defaultMessage(element,rule.method),theregex=/\$?\{(\d+)\}/g;if(typeof message=="function"){message=message.call(this,rule.parameters,element);}else if(theregex.test(message)){message=jQuery.format(message.replace(theregex,'{$1}'),rule.parameters);}this.errorList.push({message:message,element:element});this.errorMap[element.name]=message;this.submitted[element.name]=message;},addWrapper:function(toToggle){if(this.settings.wrapper)toToggle=toToggle.add(toToggle.parent(this.settings.wrapper));return toToggle;},defaultShowErrors:function(){for(var i=0;this.errorList[i];i++){var error=this.errorList[i];this.settings.highlight&&this.settings.highlight.call(this,error.element,this.settings.errorClass,this.settings.validClass);this.showLabel(error.element,error.message);}if(this.errorList.length){this.toShow=this.toShow.add(this.containers);}if(this.settings.success){for(var i=0;this.successList[i];i++){this.showLabel(this.successList[i]);}}if(this.settings.unhighlight){for(var i=0,elements=this.validElements();elements[i];i++){this.settings.unhighlight.call(this,elements[i],this.settings.errorClass,this.settings.validClass);}}this.toHide=this.toHide.not(this.toShow);this.hideErrors();this.addWrapper(this.toShow).show();},validElements:function(){return this.currentElements.not(this.invalidElements());},invalidElements:function(){return $(this.errorList).map(function(){return this.element;});},showLabel:function(element,message){var label=this.errorsFor(element);if(label.length){label.removeClass().addClass(this.settings.errorClass);label.attr("generated")&&label.html(message);}else{label=$("<"+this.settings.errorElement+"/>").attr({"for":this.idOrName(element),generated:true}).addClass(this.settings.errorClass).html(message||"");if(this.settings.wrapper){label=label.hide().show().wrap("<"+this.settings.wrapper+"/>").parent();}if(!this.labelContainer.append(label).length)this.settings.errorPlacement?this.settings.errorPlacement(label,$(element)):label.insertAfter(element);}if(!message&&this.settings.success){label.text("");typeof this.settings.success=="string"?label.addClass(this.settings.success):this.settings.success(label);}this.toShow=this.toShow.add(label);},errorsFor:function(element){var name=this.idOrName(element);return this.errors().filter(function(){return $(this).attr('for')==name});},idOrName:function(element){return this.groups[element.name]||(this.checkable(element)?element.name:element.id||element.name);},checkable:function(element){return/radio|checkbox/i.test(element.type);},findByName:function(name){var form=this.currentForm;return $(document.getElementsByName(name)).map(function(index,element){return element.form==form&&element.name==name&&element||null;});},getLength:function(value,element){switch(element.nodeName.toLowerCase()){case'select':return $("option:selected",element).length;case'input':if(this.checkable(element))return this.findByName(element.name).filter(':checked').length;}return value.length;},depend:function(param,element){return this.dependTypes[typeof param]?this.dependTypes[typeof param](param,element):true;},dependTypes:{"boolean":function(param,element){return param;},"string":function(param,element){return!!$(param,element.form).length;},"function":function(param,element){return param(element);}},optional:function(element){return!$.validator.methods.required.call(this,$.trim(element.value),element)&&"dependency-mismatch";},startRequest:function(element){if(!this.pending[element.name]){this.pendingRequest++;this.pending[element.name]=true;}},stopRequest:function(element,valid){this.pendingRequest--;if(this.pendingRequest<0)this.pendingRequest=0;delete this.pending[element.name];if(valid&&this.pendingRequest==0&&this.formSubmitted&&this.form()){$(this.currentForm).submit();this.formSubmitted=false;}else if(!valid&&this.pendingRequest==0&&this.formSubmitted){$(this.currentForm).triggerHandler("invalid-form",[this]);this.formSubmitted=false;}},previousValue:function(element){return $.data(element,"previousValue")||$.data(element,"previousValue",{old:null,valid:true,message:this.defaultMessage(element,"remote")});}},classRuleSettings:{required:{required:true},email:{email:true},url:{url:true},date:{date:true},dateISO:{dateISO:true},dateDE:{dateDE:true},number:{number:true},numberDE:{numberDE:true},digits:{digits:true},creditcard:{creditcard:true}},addClassRules:function(className,rules){className.constructor==String?this.classRuleSettings[className]=rules:$.extend(this.classRuleSettings,className);},classRules:function(element){var rules={};var classes=$(element).attr('class');classes&&$.each(classes.split(' '),function(){if(this in $.validator.classRuleSettings){$.extend(rules,$.validator.classRuleSettings[this]);}});return rules;},attributeRules:function(element){var rules={};var $element=$(element);for(method in $.validator.methods){var value=$element.attr(method);if(value){rules[method]=value;}}if(rules.maxlength&&/-1|2147483647|524288/.test(rules.maxlength)){delete rules.maxlength;}return rules;},metadataRules:function(element){if(!$.metadata)return{};var meta=$.data(element.form,'validator').settings.meta;return meta?$(element).metadata()[meta]:$(element).metadata();},staticRules:function(element){var rules={};var validator=$.data(element.form,'validator');if(validator.settings.rules){rules=$.validator.normalizeRule(validator.settings.rules[element.name])||{};}return rules;},normalizeRules:function(rules,element){$.each(rules,function(prop,val){if(val===false){delete rules[prop];return;}if(val.param||val.depends){var keepRule=true;switch(typeof val.depends){case"string":keepRule=!!$(val.depends,element.form).length;break;case"function":keepRule=val.depends.call(element,element);break;}if(keepRule){rules[prop]=val.param!==undefined?val.param:true;}else{delete rules[prop];}}});$.each(rules,function(rule,parameter){rules[rule]=$.isFunction(parameter)?parameter(element):parameter;});$.each(['minlength','maxlength','min','max'],function(){if(rules[this]){rules[this]=Number(rules[this]);}});$.each(['rangelength','range'],function(){if(rules[this]){rules[this]=[Number(rules[this][0]),Number(rules[this][1])];}});if($.validator.autoCreateRanges){if(rules.min&&rules.max){rules.range=[rules.min,rules.max];delete rules.min;delete rules.max;}if(rules.minlength&&rules.maxlength){rules.rangelength=[rules.minlength,rules.maxlength];delete rules.minlength;delete rules.maxlength;}}if(rules.messages){delete rules.messages}return rules;},normalizeRule:function(data){if(typeof data=="string"){var transformed={};$.each(data.split(/\s/),function(){transformed[this]=true;});data=transformed;}return data;},addMethod:function(name,method,message){$.validator.methods[name]=method;$.validator.messages[name]=message!=undefined?message:$.validator.messages[name];if(method.length<3){$.validator.addClassRules(name,$.validator.normalizeRule(name));}},methods:{required:function(value,element,param){if(!this.depend(param,element))return"dependency-mismatch";switch(element.nodeName.toLowerCase()){case'select':var val=$(element).val();return val&&val.length>0;case'input':if(this.checkable(element))return this.getLength(value,element)>0;default:return $.trim(value).length>0;}},remote:function(value,element,param){if(this.optional(element))return"dependency-mismatch";var previous=this.previousValue(element);if(!this.settings.messages[element.name])this.settings.messages[element.name]={};previous.originalMessage=this.settings.messages[element.name].remote;this.settings.messages[element.name].remote=previous.message;param=typeof param=="string"&&{url:param}||param;if(previous.old!==value){previous.old=value;var validator=this;this.startRequest(element);var data={};data[element.name]=value;$.ajax($.extend(true,{url:param,mode:"abort",port:"validate"+element.name,dataType:"json",data:data,success:function(response){validator.settings.messages[element.name].remote=previous.originalMessage;var valid=response===true;if(valid){var submitted=validator.formSubmitted;validator.prepareElement(element);validator.formSubmitted=submitted;validator.successList.push(element);validator.showErrors();}else{var errors={};var message=(previous.message=response||validator.defaultMessage(element,"remote"));errors[element.name]=$.isFunction(message)?message(value):message;validator.showErrors(errors);}previous.valid=valid;validator.stopRequest(element,valid);}},param));return"pending";}else if(this.pending[element.name]){return"pending";}return previous.valid;},minlength:function(value,element,param){return this.optional(element)||this.getLength($.trim(value),element)>=param;},maxlength:function(value,element,param){return this.optional(element)||this.getLength($.trim(value),element)<=param;},rangelength:function(value,element,param){var length=this.getLength($.trim(value),element);return this.optional(element)||(length>=param[0]&&length<=param[1]);},min:function(value,element,param){return this.optional(element)||value>=param;},max:function(value,element,param){return this.optional(element)||value<=param;},range:function(value,element,param){return this.optional(element)||(value>=param[0]&&value<=param[1]);},email:function(value,element){return this.optional(element)||/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i.test(value);},url:function(value,element){return this.optional(element)||/^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);},date:function(value,element){return this.optional(element)||!/Invalid|NaN/.test(new Date(value));},dateISO:function(value,element){return this.optional(element)||/^\d{4}[\/-]\d{1,2}[\/-]\d{1,2}$/.test(value);},number:function(value,element){return this.optional(element)||/^-?(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$/.test(value);},digits:function(value,element){return this.optional(element)||/^\d+$/.test(value);},creditcard:function(value,element){if(this.optional(element))return"dependency-mismatch";if(/[^0-9-]+/.test(value))return false;var nCheck=0,nDigit=0,bEven=false;value=value.replace(/\D/g,"");for(var n=value.length-1;n>=0;n--){var cDigit=value.charAt(n);var nDigit=parseInt(cDigit,10);if(bEven){if((nDigit*=2)>9)nDigit-=9;}nCheck+=nDigit;bEven=!bEven;}return(nCheck%10)==0;},accept:function(value,element,param){param=typeof param=="string"?param.replace(/,/g,'|'):"png|jpe?g|gif";return this.optional(element)||value.match(new RegExp(".("+param+")$","i"));},equalTo:function(value,element,param){var target=$(param).unbind(".validate-equalTo").bind("blur.validate-equalTo",function(){$(element).valid();});return value==target.val();}}});$.format=$.validator.format;})(jQuery);;(function($){var ajax=$.ajax;var pendingRequests={};$.ajax=function(settings){settings=$.extend(settings,$.extend({},$.ajaxSettings,settings));var port=settings.port;if(settings.mode=="abort"){if(pendingRequests[port]){pendingRequests[port].abort();}return(pendingRequests[port]=ajax.apply(this,arguments));}return ajax.apply(this,arguments);};})(jQuery);;(function($){$.each({focus:'focusin',blur:'focusout'},function(original,fix){$.event.special[fix]={setup:function(){if($.browser.msie)return false;this.addEventListener(original,$.event.special[fix].handler,true);},teardown:function(){if($.browser.msie)return false;this.removeEventListener(original,$.event.special[fix].handler,true);},handler:function(e){arguments[0]=$.event.fix(e);arguments[0].type=fix;return $.event.handle.apply(this,arguments);}};});$.extend($.fn,{delegate:function(type,delegate,handler){return this.bind(type,function(event){var target=$(event.target);if(target.is(delegate)){return handler.apply(target,arguments);}});},triggerEvent:function(type,target){return this.triggerHandler(type,[$.event.fix({type:type,target:target})]);}})})(jQuery);

 /*
 * TipTip
 * Copyright 2010 Drew Wilson
 * www.drewwilson.com
 * code.drewwilson.com/entry/tiptip-jquery-plugin
 *
 * Version 1.2   -   Updated: Jan. 13, 2010
 *
 * This Plug-In will create a custom tooltip to replace the default
 * browser tooltip. It is extremely lightweight and very smart in
 * that it detects the edges of the browser window and will make sure
 * the tooltip stays within the current window size. As a result the
 * tooltip will adjust itself to be displayed above, below, to the left 
 * or to the right depending on what is necessary to stay within the
 * browser window. It is completely customizable as well via CSS.
 *
 * This TipTip jQuery plug-in is dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

(function($){
	$.fn.tipTip = function(options) {
		var defaults = { 
			maxWidth: "200px",
			edgeOffset: 3,
			delay: 400,
			fadeIn: 200,
			fadeOut: 200,
		  	enter: function(){},
		  	exit: function(){}
	  	};
	 	var opts = $.extend(defaults, options);
	 	
	 	// Setup tip tip elements and render them to the DOM
	 	if($("#tiptip_holder").length <= 0){
	 		var tiptip_holder = $('<div id="tiptip_holder" style="max-width:'+ opts.maxWidth +';"></div>');
			var tiptip_content = $('<div id="tiptip_content"></div>');
			var tiptip_arrow = $('<div id="tiptip_arrow"></div>');
			$("body").append(tiptip_holder.html(tiptip_content).prepend(tiptip_arrow.html('<div id="tiptip_arrow_inner"></div>')));
		} else {
			var tiptip_holder = $("#tiptip_holder");
			var tiptip_content = $("#tiptip_content");
			var tiptip_arrow = $("#tiptip_arrow");
		}
		
		return this.each(function(){
			var org_elem = $(this);
			var org_title = org_elem.attr("title");
			if(org_title != ""){
				org_elem.removeAttr("title"); //remove original Title attribute
				var timeout = false;
				org_elem.hover(function(){
					opts.enter.call(this);
					tiptip_content.html(org_title);
					tiptip_holder.hide().removeAttr("class").css("margin","0");
					tiptip_arrow.removeAttr("style");
					
					var top = parseInt(org_elem.offset()['top']);
					var left = parseInt(org_elem.offset()['left']);
					var org_width = parseInt(org_elem.outerWidth());
					var org_height = parseInt(org_elem.outerHeight());
					var tip_w = tiptip_holder.outerWidth();
					var tip_h = tiptip_holder.outerHeight();
					var w_compare = Math.round((org_width - tip_w) / 2);
					var h_compare = Math.round((org_height - tip_h) / 2);
					var marg_left = Math.round(left + w_compare);
					var marg_top = Math.round(top + org_height + opts.edgeOffset);
					var t_class = "";
					var arrow_top = "";
					var arrow_left = Math.round(tip_w - 12) / 2;
					
					if(w_compare < 0){
						if((w_compare + left) < parseInt($(window).scrollLeft())){
							t_class = "_right";
							arrow_top = Math.round(tip_h - 13) / 2;
							arrow_left = -12;
							marg_left = Math.round(left + org_width + opts.edgeOffset);
							marg_top = Math.round(top + h_compare);
						} else if((tip_w + left) > parseInt($(window).width())){
							t_class = "_left";
							arrow_top = Math.round(tip_h - 13) / 2;
							arrow_left =  Math.round(tip_w);
							marg_left = Math.round(left - (tip_w + opts.edgeOffset + 5));
							marg_top = Math.round(top + h_compare);
						}
					}
					if((top + org_height + opts.edgeOffset + tip_h + 8) > parseInt($(window).height() + $(window).scrollTop())){
						t_class = t_class+"_top";
						arrow_top = tip_h;
						marg_top = Math.round(top - (tip_h + 5 + opts.edgeOffset));
					} else if(((top + org_height) - (opts.edgeOffset + tip_h)) < 0 || t_class == ""){
						t_class = t_class+"_bottom";
						arrow_top = -12;						
						marg_top = Math.round(top + org_height + opts.edgeOffset);
					}
					if(t_class == "_right_top" || t_class == "_left_top"){
						marg_top = marg_top + 5;
					} else if(t_class == "_right_bottom" || t_class == "_left_bottom"){		
						marg_top = marg_top - 5;
					}
					if(t_class == "_left_top" || t_class == "_left_bottom"){	
						marg_left = marg_left + 5;
					}
					tiptip_arrow.css({"margin-left": arrow_left+"px", "margin-top": arrow_top+"px"});
					tiptip_holder.css({"margin-left": marg_left+"px", "margin-top": marg_top+"px"}).attr("class","tip"+t_class);
					
					if (timeout){ clearTimeout(timeout); }
					timeout = setTimeout(function(){ tiptip_holder.stop(true,true).fadeIn(opts.fadeIn); }, opts.delay);			
				}, function(){
					opts.exit.call(this);
					if (timeout){ clearTimeout(timeout); }
					tiptip_holder.fadeOut(opts.fadeOut);
				});
			}				
		});
	}
})(jQuery);  	

/*

Uniform v1.0
Copyright © 2009 Josh Pyles / Pixelmatrix Design LLC
http://pixelmatrixdesign.com

Requires jQuery 1.3 or newer

Much thanks to Thomas Reynolds and Buck Wilson for their help and advice on this

License:
MIT License - http://www.opensource.org/licenses/mit-license.php

Usage:

$(function(){
	
	$("select, :radio, :checkbox").uniform();
	
});

You can customize the classes that Uniform uses:

$("select, :radio, :checkbox").uniform({
	selectClass: 'mySelectClass', 
	radioClass: 'myRadioClass', 
	checkboxClass: 'myCheckboxClass', 
	checkedClass: 'myCheckedClass', 
	focusClass: 'myFocusClass'
});

Enjoy!

*/

(function($) {
  $.uniform = {
    options: {
      selectClass:   'selector',
			radioClass: 'radio',
			checkboxClass: 'checker',
			checkedClass: 'checked',
      focusClass: 'focus'
    }
  };

	if($.browser.msie && $.browser.version < 7){
		$.selectOpacity = false;
	}else{
		$.selectOpacity = true;
	}

  $.fn.uniform = function(options) {
    
		options = $.extend($.uniform.options, options);
	
		function doSelect(elem){
			
			var divTag = $('<div />'),
	  			spanTag = $('<span />');
		
			divTag.addClass(options.selectClass);
			
			spanTag.html(elem.children(":selected").text());
			
			elem.css('opacity', 0);
			elem.wrap(divTag);
			elem.before(spanTag);
			
			//redefine variables
			
			divTag = elem.parent("div");
			spanTag = elem.siblings("span");
			
			elem.change(function() {
       	spanTag.text(elem.children(":selected").text());
     	})
     	.focus(function() {
      	divTag.addClass(options.focusClass);
     	})
     	.blur(function() {
      	divTag.removeClass(options.focusClass);
     	});
		}
		
		function doCheckbox(elem){
			
			var divTag = $('<div />'),
	  			spanTag = $('<span />');
			
			divTag.addClass(options.checkboxClass);
			
			//wrap with the proper elements
			$(elem).wrap(divTag);
			$(elem).wrap(spanTag);
			
			//redefine variables
			
			spanTag = elem.parent();
			divTag = spanTag.parent();

			//hide normal input and add focus classes
			$(elem)
			.css("opacity", 0)
			.focus(function(){
				
				divTag.addClass(options.focusClass);
			})
			.blur(function(){
				
				divTag.removeClass(options.focusClass);
			})
			.click(function(){
				
				if(!$(elem).attr("checked")){	
					//box was just unchecked, uncheck span
					spanTag.removeClass(options.checkedClass);	
				}else{
					//box was just checked, check span
					spanTag.addClass(options.checkedClass);
				}
			});

			//handle defaults
			if($(elem).attr("checked")){
				//box is checked by default, check our box
				spanTag.addClass(options.checkedClass);	
			}
		}
		
		function doRadio(elem){
			
			var divTag = $('<div />'),
	  			spanTag = $('<span />');
			
			divTag.addClass(options.radioClass);
			
			//wrap with the proper elements
			$(elem).wrap(divTag);
			$(elem).wrap(spanTag);

			//redefine variables
			
			spanTag = elem.parent();
			divTag = spanTag.parent();

			//hide normal input and add focus classes
			$(elem)
			.css("opacity", 0)
			.focus(function(){
				divTag.addClass(options.focusClass);
			})
			.blur(function(){
				divTag.removeClass(options.focusClass);
			})
			.click(function(){
				if(!$(elem).attr("checked")){
					//box was just unchecked, uncheck span
					spanTag.removeClass(options.checkedClass);	
				}else{
					//box was just checked, check span
					$("."+options.radioClass+" span."+options.checkedClass).removeClass(options.checkedClass);
					spanTag.addClass(options.checkedClass);
				}
			});

			//handle defaults
			if($(elem).attr("checked")){
				//box is checked by default, check span
				spanTag.addClass(options.checkedClass);	
			}
		}
		
    return this.each(function() {
			if($.selectOpacity){
				var elem = $(this);

				if(elem.is("select")){
					//element is a select
					doSelect(elem);

				}else if(elem.is(":checkbox")){
					//element is a checkbox
					doCheckbox(elem);

				}else if(elem.is(":radio")){
					//element is a radio
					doRadio(elem);
				}
			}
    });
  };
})(jQuery);