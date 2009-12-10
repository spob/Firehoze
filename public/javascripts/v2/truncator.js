$(function() {
    $('.bio').truncate({
        max_length: 260,
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
});
