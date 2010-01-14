$(function() {
    $("#user_accordion").accordion({
        active: 0,
        fillSpace: true
    });

    $("#instructor_accordion").accordion({
        active: 0,
        fillSpace: true
    });

    $("#lesson_stats_accordion").accordion({
        active: -1
    });

    $("#faqs_accordian").accordion({
        active: -1,
        header: 'h4',
        collapsible: true,
        autoHeight: false
    });

});
