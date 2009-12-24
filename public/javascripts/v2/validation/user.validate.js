$(document).ready(function() {
    $("#new_user").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#user_first_name').simplyCountable({
        counter: '#user_first_name_counter',
        countType: 'characters',
        maxCount: 40,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#user_last_name').simplyCountable({
        counter: '#user_last_name_counter',
        countType: 'characters',
        maxCount: 40,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});