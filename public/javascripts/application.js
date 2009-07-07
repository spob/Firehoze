// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// public/javascripts/application.js



jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })
 // 
 // function _ajax_request(url, data, callback, type, method) {
 //     if (jQuery.isFunction(data)) {
 //         callback = data;
 //         data = {};
 //     }
 //     return jQuery.ajax({
 //         type: method,
 //         url: url,
 //         data: data,
 //         success: callback,
 //         dataType: type
 //         });
 // }
 //  
 // jQuery.extend({
 //     put: function(url, data, callback, type) {
 //         return _ajax_request(url, data, callback, type, 'PUT');
 //     },
 //     delete_: function(url, data, callback, type) {
 //         return _ajax_request(url, data, callback, type, 'DELETE');
 //     }
 // });
 //  
 // 
 