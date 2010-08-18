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

});


$(function() {
    // make the cursor over <li> element to be a pointer instead of default
    $('ul.clickable li').css('cursor', 'pointer')
    // iterate through all <li> elements with CSS class = "clickable"
    // and bind onclick event to each of them
    .click(function() {
        // when user clicks this <li> element, redirect it to the page
        // to where the fist child <a> element points
        window.location = $('a', this).attr('href');
    });


    // these methods are required for complex forms 
  $('form a.add_child').click(function() {
    var assoc   = $(this).attr('data-association');
    var content = $('#' + assoc + '_fields_template').html();
    var regexp  = new RegExp('new_' + assoc, 'g');
    var new_id  = new Date().getTime();

    $(this).parent().before(content.replace(regexp, new_id));
    return false;
  });

  $('form a.remove_child').live('click', function() {
    var hidden_field = $(this).prev('input[type=hidden]')[0];
    if(hidden_field) {
      hidden_field.value = '1';
    }
    $(this).parents('.fields').hide();
    return false;
  });
});

