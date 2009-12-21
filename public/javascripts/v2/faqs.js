$(function() {

    $("h5").next("div").hide();

    $("h5").click(function () {
        $(this).next("div").slideToggle();
    });

    $("a.anchorLink").anchorAnimate();

});

