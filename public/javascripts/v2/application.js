// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// make forms do remote requests
jQuery.fn.submitWithAjax = function(){
    this.submit(function () {
        // Amend the URL for submitting this form to have a .js extension
        // Otherwise users on Internet Explorer will get a
        // Security Warning - File Download
        // and no remote form processing.
        $.post($(this).attr('action')+".js", $(this).serialize(), null, "script");

        //
        // On submit, set the button to have the 'spinning' class --
        // which I define to
        // .spinning { background: #ccc url('/images/u/spinner-sun-28.gif') no-repeat right !important; }
        // using
        // http://assets3.infochimps.org/images/u/spinner-sun-28.gif
        // (see http://www.ajaxload.info to get your own.)
        //
        // Your response will want to use a similar recipe to
        // $('<%= selector_for_the_form_what_called_us %>').find('input[type="submit"]').each(function(){ $(this).toggleClass('spinning', false); });
        // on the buttons within the form.
        //
        $(this).find('input[type="submit"]').each(function(){
            $(this).toggleClass('spinning', true);
        });

        // Don't follow the link to load a new page
        return false;
    });
};

$(document).ready(function(){
    // Have AJAX forms ask for JSON in the headers
    jQuery.ajaxSetup({
        'beforeSend': function (xhr) {
            xhr.setRequestHeader("Accept", "text/javascript")
        }
    });
    // Have all remote-classed forms submit AJAX
    $('form.remote').submitWithAjax();

    // clear the seach input field on focus
    $("form #search_criteria").focus(function () {
        $(this).val("");
    });
});
