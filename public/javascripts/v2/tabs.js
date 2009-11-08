$(function() {

    $("#my_stuff div.sub-navigation > ul.buttons").tabs("#my_stuff > div.sub-navigation-panes > div", {
        effect: 'fade'
    });

    $("#my_stuff div.sub-sub-navigation > ul.links").tabs("#my_stuff div.sub-sub-navigation-panes > div", {
        effect: 'fade'
    });

    $("#account_history div.sub-navigation > ul.buttons").tabs("#account_history > div.sub-navigation-panes > div", {
        effect: 'fade'
    });

});
