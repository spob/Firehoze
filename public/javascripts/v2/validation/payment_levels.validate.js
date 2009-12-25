$(document).ready(function() {
    $("#payment_level").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#payment_level_name').simplyCountable({
        counter: '#payment_level_name_counter',
        countType: 'characters',
        maxCount: 30,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#payment_level_code').simplyCountable({
        counter: '#payment_level_code_counter',
        countType: 'characters',
        maxCount: 5,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});