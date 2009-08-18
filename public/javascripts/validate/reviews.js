$(document).ready(function()
    {
       $("#review_link").click(function () {
           $("#review_form").slideToggle("normal");
           return false;
       });
       
       $('#review_headline').simplyCountable({
           counter: '#headline_counter',
           countType: 'characters',
           maxCount: 50,
           countDirection: 'down'
       });
        $(document).ready(function() {
            $("#review_form #inline").submitWithAjax();
        })
    });
