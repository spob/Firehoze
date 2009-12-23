$(function() {
    $('div.bio').truncate({
        max_length: 260,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div.group-description').truncate({
        max_length: 360,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div.review-body').truncate({
        max_length: 300,
        more : "more",
        less : "less",
        fade : 500
    });

    $('ul.lessons-row-format div.details div.synopsis').truncate({
        max_length: 240,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div#group-container div#description ul li.description').truncate({
        max_length: 450,
        more : "more",
        less : "less",
        fade : 500
    });

    $('div#lesson-synopsis, div#lesson-instructor-bio').truncate({
        max_length: 450,
        more : "more",
        less : "less",
        fade : 500
    });


});
