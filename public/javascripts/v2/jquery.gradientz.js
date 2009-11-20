// Gradientz 0.4
// Replace your gradient images
// USE
// $(document).ready(function() {
//  $('#box1').gradientz({
//    start: "#fcc",
//    end: "yellow",
//    angle: 45,
//    distance: 100,
//    css: "top: 0px"
//  })
// For more information: see www.parkerfox.co.uk/labs/gradientz

;(function($){

  if($.browser.msie && document.namespaces["v"] == null) {
    document.namespaces.add("v", "urn:schemas-microsoft-com:vml");
    var ss = document.createStyleSheet().owningElement;
    ss.styleSheet.cssText = "v\\:*{behavior:url(#default#VML);}";
  }
  
  function vmlGradient(angle, colorStart, colorEnd, width, height, distance, css) {
    var html ='<v:rect class=gradientz_inserted style="position:absolute; margin-top: -1;  margin-left: -1; width:' + (width+1) + "px;height:" + (height+1) + 'px;' + css + '" stroked="false"  fillcolor="' + colorEnd + '" >';
    html += '<v:fill method="sigma"  color2="' + colorStart + '" type="gradient" angle="' + angle + '">' ;
    html += '</v:rect>';
    return html;
  }
  
  function canvasGradient(angle, colorStart, colorEnd, width, height, distance, css) {
    var canvas=$("<canvas class=gradientz_inserted width="+width+"px height="+ height +"px style='position:absolute; ; " + css + "'></canvas>");
    var ctx=canvas[0].getContext('2d');
    
    var flip = angle < 0
    angle = Math.abs(angle)
    
    var x = Math.sin(angle) * distance;
    var y = Math.cos(angle) * distance;
    
    var lingrad = flip ? ctx.createLinearGradient(-x,0,0, -y) : ctx.createLinearGradient(0,0,x,y);
    
    lingrad.addColorStop(0, colorStart);
    lingrad.addColorStop(1, colorEnd);
    
    ctx.fillStyle = lingrad;
    ctx.fillRect(0,0,width,height);
    return canvas;
  }
  
  function minAbs(x,y) {
    x = Math.abs(x)
    y = Math.abs(y)
    return x<y ? x : y
  }

  $.fn.gradientz = function(options){
    
      var settings = {
        angle : 0,
        //zIndex: -1,
        css: "left:0px; top:0px; "
        };
      $.extend(settings, options || {});
    
      var radianConvert = Math.PI / 180;

      return this.each(function() {

        var $$ = $(this);
          
        if(this.style.position != "absolute") {
          this.style.position = "relative";
          this.style.zoom = 1; // give layout in IE
        }
          
        var w = $$.innerWidth();
        var h = $$.innerHeight();


        settings.start = settings.start || $$.css("backgroundColor")
        settings.end = settings.end || $$.css("backgroundColor")


        var radians = settings.angle * radianConvert;
        var cos = Math.cos(radians)
        var sin = Math.sin(radians) 
        var d = settings.distance || minAbs( h / cos, w / sin)

        w = minAbs( d / sin, w )
        h = minAbs( d / cos, h )

        $$.wrapInner("<div class=inner_gradient style='position: absolute; left: 0px; top: 0px;' ></div>")
          
        if($.browser.msie) {//need to use innerHTML rather than jQuery
          var h = vmlGradient(settings.angle, settings.start, settings.end, w, h, d, settings.css) ;    
          this.innerHTML = h + this.innerHTML ; 
          $(this).css({overflow: "hidden"})
        }
        else  //canvasGradient returns a DOM element
          $$.prepend(canvasGradient(radians, settings.start, settings.end, w, h, d,  settings.css));
      })  
    }
  })(jQuery);
