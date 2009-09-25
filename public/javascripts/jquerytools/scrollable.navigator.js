$(function() {
  $("#browsable").scrollable().navigator();	

  $("div.scrollable").scrollable({
        size: 4,
        items: '#thumbs',
        hoverClass: 'hover',

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
    }).navigator();	


});
