$(function() {

    // MY-FIREHOZE TABS
    // my-stuff
    $("#my_stuff div.sub-navigation > ul.buttons").tabs("#my_stuff > div.sub-navigation-panes > div", {
        effect: 'fade'
    });

    // account history
    $("#account_history div.sub-navigation > ul.buttons").tabs("#account_history > div.sub-navigation-panes > div", {
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
