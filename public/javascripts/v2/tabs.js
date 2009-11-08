// setup ul.tabs to work as tabs for each div directly under div.panes 
$(function() {
    $(".sub-navigation ul.buttons").tabs("div.panes > div");
});
