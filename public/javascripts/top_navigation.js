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
