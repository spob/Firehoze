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

});
