$(function() {

    // MY-FIREHOZE TABS
    // my-firehoze-tab
    $("#my_firehoze div.top-level-navigation > ul.buttons").tabs("#my_firehoze > div.top-level-panes > div", {
        effect: 'fade'
    });

    // my-stuff
    $("#my_stuff ul.tabs").tabs("#my_stuff > div.panes > div", {
        effect: 'fade'
    });

    // account history
    $("#account_history ul.tabs").tabs("#account_history > div.panes > div", {
        effect: 'fade'
    });

    // instructor history
    $("#instructor_stuff div.sub-navigation > ul.buttons").tabs("#instructor_stuff > div.sub-navigation-panes > div", {
        effect: 'fade'
    });

    // ALL secondary sub navigation
    $("div.secondary-sub-navigation > ul.links").tabs("div.secondary-sub-navigation-panes > div", {
        effect: 'fade'
    });
// END MY-FIREHOZE TABS

});
