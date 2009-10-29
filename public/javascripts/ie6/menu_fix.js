$(function() {
    if($.browser.msie && parseInt($.browser.version) < 7){ //Test if is IE < 7
        $("#menu li ul li:first").css({
            "border-top": "none"
        }); //Drop border from first element
        $("#menu li").mouseover(function(){ //Show submenus
            $(this).find("ul").css({
                "display" : "block"
            });
        }).mouseout(function(){ //Hide submenus
            $(this).find("ul").css({
                "display" : "none"
            });
        });
    }
});