$(function() {
    var zIndexNumber = 1000;

    $('div:not("div.lesson-tooltip")').each(function() {
        $(this).css('zIndex', zIndexNumber);
          zIndexNumber -= 10;
        // console.log("%o",this);
    });

    // handle GetSatisfaction and others
    $('div#fdbk_overlay').css('zIndex', 2000);
    $('div#top-navigation-container').css('zIndex', 1);
    $('div.lesson-tooltip').css('zIndex', 3000);
    $('div.pagination').css('zIndex', 1);
});
