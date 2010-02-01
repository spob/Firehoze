$(function() {
    var zIndexNumber = 1000;

    $('div:not("div.lesson-tooltip")').each(function() {
        $(this).css('zIndex', zIndexNumber);
          zIndexNumber -= 10;
        // console.log("%o",this);
    });

    // handle GetSatisfaction
    $('div#fdbk_overlay').css('zIndex', 2000);
});
