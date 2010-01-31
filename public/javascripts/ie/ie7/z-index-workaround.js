$(function() {
    var zIndexNumber = 1000;
    $('div').each(function() {
        $(this).css('zIndex', zIndexNumber);
        zIndexNumber -= 10;
        // console.log("%o",this);
    });

    // handle GetSatisfaction and others
    $('div#fdbk_overlay').css('zIndex', 2000);
    $('div.lesson-tooltip').css('zIndex', 2000);
    $('div.pagination').css('zIndex', 1);
    $('div.small-lesson-container').css('zIndex', 1);
    $('div#top-navigation-container').css('zIndex', 1999);
});
