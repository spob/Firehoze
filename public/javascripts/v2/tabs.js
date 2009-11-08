// setup ul.tabs to work as tabs for each div directly under div.panes 
$(function() {
    $(".sub-navigation ul.buttons").tabs("div.sub-navigation-panes > div", {
        effect: 'fade'
    });

    $(".sub-sub-navigation ul.buttons").tabs("div.sub-sub-navigation-panes > div", {
        effect: 'fade'
    });
});
