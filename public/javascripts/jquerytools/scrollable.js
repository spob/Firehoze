// execute your scripts when DOM is ready. this is a good habit
$(function() {
    // initialize scrollable
    $("div.scrollable").scrollable({
        size: 4,
        items: '#thumbs',
        hoverClass: 'hover',

        // items are auto-scrolled in 2 secnod interval
        interval: 6000,

        // when last item is encountered go back to first item
        loop: true,

        // make animation a little slower than the default
        speed: 900,

        // when seek starts make items little transparent
        onBeforeSeek: function() {
            this.getItems().fadeTo(500, 0.9);
        },

        // when seek ends resume items to full transparency
        onSeek: function() {
            this.getItems().fadeTo(400, 1);
        }
    });
});
