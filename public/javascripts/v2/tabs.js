$(function() {

    // MY-FIREHOZE TABS
    // my-stuff
    $("#my_stuff div.sub-navigation > ul.buttons").tabs("#my_stuff > div.sub-navigation-panes > div", {
        effect: 'fade'
    });

    $("#my_stuff div.sub-sub-navigation > ul.links").tabs("#my_stuff div.sub-sub-navigation-panes > div", {
        effect: 'fade'
    });

    // account history
    $("#account_history div.sub-navigation > ul.buttons").tabs("#account_history > div.sub-navigation-panes > div", {
        effect: 'fade'
    });

    $("#account_history div.sub-sub-navigation > ul.links").tabs("#account_history div.sub-sub-navigation-panes > div", {
        effect: 'fade'
    });

    // instructor history
    $("#instructor_stuff div.sub-navigation > ul.buttons").tabs("#instructor_stuff > div.sub-navigation-panes > div", {
        effect: 'fade'
    });

    $("#instructor_stuff div.sub-sub-navigation-1 > ul.links").tabs("#instructor_stuff div.sub-sub-navigation-panes > div", {
        effect: 'fade'
    });

    $("#instructor_stuff div.sub-sub-navigation-2 > ul.links").tabs("#instructor_stuff div.sub-sub-navigation-panes > div", {
        effect: 'fade'
    });
    // END MY-FIREHOZE TABS

});
