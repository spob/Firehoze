$(document).ready(function() {
    $(".register").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    })

    $('#registration_username').simplyCountable({
        counter: '#registration_username_counter',
        countType: 'characters',
        maxCount: 25,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#registration_email').simplyCountable({
        counter: '#registration_email_counter',
        countType: 'characters',
        maxCount: 100,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});