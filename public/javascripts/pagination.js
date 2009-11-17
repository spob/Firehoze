$(function() {
    $(".pagination a, .filter_activity_by a").live("click", function() {
        var loader = $('.loader')
        loader.show()   // <-- hidden loader div
        $.get(this.href, null,
            function()
            {
                loader.hide();
            }, "script");
        return false;
    })
});
