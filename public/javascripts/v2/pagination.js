$(function() {
    $(".pagination a, .filter-activity-by a").live("click", function() {
        var loader = $('.loader')
        loader.show()   // <-- hidden loader div
        $.getScript(this.href, function() { loader.hide(); });
        return false;
    })
});
