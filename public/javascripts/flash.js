$(function(){
    if ($(".flash").is(":hidden")) {
        $(".flash").slideDown(500);
    }
    setTimeout(function(){
        $(".flash").slideUp(750, function () {
            $(".flash").remove();
        });
    }, 3000);
});
