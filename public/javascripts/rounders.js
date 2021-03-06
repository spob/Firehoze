$(function() {
    $('#marketing_fpo').cornerz({
        radius: 5,
        background: "#FFF"
    });

    $('.box').cornerz({
        radius: 5
    });

    $('.inner_box').cornerz({
        radius: 5,
        background: "#EDEDED"
    });

    $('div.widget-box').cornerz({
        radius: 5,
        background: "#FFF"
    });

    $('div.category-container').cornerz({
        radius: 8,
        background: "#e3e9f2"
    });

    $('ul#breadcrumb').cornerz({
        radius: 5
    });

    $('div#lessons_pagination.pagination').cornerz({
        radius: 5
    });

    $('div#faqs_section div#questions, div#faqs_section div.answers, div#howtos_section div.answers').cornerz({
        radius: 5
    });

    $('#faqs_section .answers h4, div#howtos_section .answers h4').cornerz({
        radius: 5,
        background: "#FFF"
    });
});
