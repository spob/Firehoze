$(function() {
    $(".pagination a, .filter_activity_by a").live("click", function() {
        var loader = $('.loader')
        loader.show()   // <-- hidden loader div
        $.getScript(this.href, function() { loader.hide(); });
        return false;
    })
});
