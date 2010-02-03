$(document).ready(function() {
    $("#review").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    })

    $('#review_headline').simplyCountable({
        counter: '#headline_counter',
        countType: 'characters',
        maxCount: 100,
        countDirection: 'down'
    });
});
