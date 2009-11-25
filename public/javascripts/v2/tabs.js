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
});
