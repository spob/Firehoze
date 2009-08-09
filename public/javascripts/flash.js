$(function(){
    if ($(".flash").is(":hidden")) {
        $(".flash").slideDown(400);
    }
    setTimeout(function(){
        $(".flash").fadeOut(750, function () {
            $(".flash").remove();
        });
    }, 3000);
});
