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

$(function() {

    $("h5").next("div").hide();

    $("h5").click(function () {
        $(this).next("div").slideToggle();
    });

    $("a.anchorLink").anchorAnimate();

});



$(function(){
    if ($(".flash").is(":hidden")) {
        $(".flash").slideDown(500);
    }
});


$(function(){
    $('#footer').always_at_bottom();
});


$(function() {
    $(".ajax-pagination a, .filter-activity-by a").live("click", function() {
        var loader = $('.loader')
        loader.show()   // <-- hidden loader div
        $.getScript(this.href, function() {
            loader.hide();
        });
        return false;
    })
});


$(function() {
    $('#marketing_fpo').cornerz({
        radius: 5,
        background: "#FFF"
    });

    $('.box').cornerz({
        radius: 5
    });

    $('.inner_box').cornerz({
        radius: 5,
        background: "#EDEDED"
    });

    $('div.widget-box').cornerz({
        radius: 5,
        background: "#FFF"
    });

    $('div.category-container').cornerz({
        radius: 8,
        background: "#e3e9f2"
    });

    $('ul#breadcrumb').cornerz({
        radius: 5
    });

    $('div#lessons_pagination.pagination').cornerz({
        radius: 5
    });

    $('div#faqs_section div#questions, div#faqs_section div.answers').cornerz({
        radius: 5
    });

    $('#faqs_section .answers h4').cornerz({
        radius: 5,
        background: "#FFF"
    });
});


$(function() {

    // MY-FIREHOZE TABS
    // my-stuff
    $("#my_stuff ul.tabs").tabs("#my_stuff > div.panes > div", {
        effect: 'fade'
    });

    // account history
    $("#account_history ul.tabs").tabs("#account_history > div.panes > div", {
        effect: 'fade'
    });

    // instructor history
    $("#instructor_dashboard ul.tabs").tabs("#instructor_dashboard > div.panes > div", {
        effect: 'fade'
    });

    // ALL secondary sub navigation
    $("div.nested-navigation > ul.links").tabs("div.nested-navigation-panes > div", {
        effect: 'fade'
    });

    // SEARCH RESULTS
    $("#search-results ul.tabs").tabs("#search-results > div.panes > div", {
        effect: 'fade'
    });

    // account settings
    $("#account-settings-tabs ul.tabs").tabs("#account-settings-tabs > div.panes > div", {
        effect: 'fade'
    });

    // HIDE & SHOW the advance lesson search link
    $('li#lessons-tab a').click(function () {
        $('a#advanced-search-link').show();
        return false;
    });

    $('li#groups-tab a,li#users-tab a').click(function () {
        $('a#advanced-search-link').hide();
        return false;
    });

    // group details
    $("#group-details-tabs ul.tabs").tabs("#group-details-tabs > div.panes > div", {
        effect: 'fade'
    });

    // lesson details
    $("#lesson-details-tabs ul.tabs").tabs("#lesson-details-tabs > div.panes > div", {
        effect: 'fade'
    });

    // lesson content
    $("#lesson-content-tabs ul.tabs").tabs("#lesson-content-tabs > div.panes > div", {
        effect: 'ajax'
    });

    // admin edit user tabs
    $("#admin-user-tabs ul.tabs").tabs("#admin-user-tabs > div.panes > div", {
        effect: 'fade'
    });

    // public user tabs
    $("#user-show-tabs ul.tabs").tabs("#user-show-tabs > div.panes > div", {
        effect: 'fade'
    });

    // public user tabs
    $("#help-center-tabs ul.tabs").tabs("#help-center-tabs > div.panes > div", {
        effect: 'fade'
    });


});


$(function() {

  $("li#advanced-search-icon a").tipTip(
    {maxWidth: "auto", edgeOffset: 0, delay:100}
  );

});


$(function(){

    $("ul.subnav").parent().append("<span></span>"); //Only shows drop down trigger when js is enabled - Adds empty span tag after ul.subnav

    $("ul#top-navigation li.with-subnav").hover(function() { //When trigger is clicked...

        //Following events are applied to the subnav itself (moving subnav up and down)
        // $(this).parent().find("ul.subnav").slideDown('fast').show(); //Drop down the subnav on click
        $(this).find("ul.subnav").slideDown('fast').show(); //Drop down the subnav on click

        // $(this).parent().hover(function() {
	        $(this).hover(function() {
            }, function(){
              // $(this).parent().find("ul.subnav").slideUp('slow'); //When the mouse hovers out of the subnav, move it back up
                $(this).find("ul.subnav").slideUp('fast'); //When the mouse hovers out of the subnav, move it back up
            });

    //Following events are applied to the trigger (Hover events for the trigger)
    }).hover(function() {
        $(this).find("span").addClass("subhover"); //On hover over, add class "subhover"
    }, function(){	//On Hover Out
        $(this).find("span").removeClass("subhover"); //On hover out, remove class "subhover"
    });

});


$(function() {
    $('div.bio').truncate({
        max_length: 260,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div.group-description').truncate({
        max_length: 360,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div.review-body').truncate({
        max_length: 300,
        more : "more",
        less : "less",
        fade : 500
    });

    $('ul.lessons-row-format div.details div.synopsis').truncate({
        max_length: 240,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div#group-container div#description ul li.description').truncate({
        max_length: 450,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div#lesson-synopsis, div#lesson-instructor-bio').truncate({
        max_length: 350,
        more : "more",
        less : "less",
        fade : 500
    });
});
