$(function() {
    $('.bio').truncate({
        max_length: 260,
        more : "more",
        less : "less",
        fade : 500
    });

    $('.group-description').truncate({
        max_length: 360,
        more : "more",
        less : "less",
        fade : 500
    });

    $('.review-body').truncate({
        max_length: 300,
        more : "more",
        less : "less",
        fade : 500
    });

    $('.lessons-row-format .details .synopsis').truncate({
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
});
