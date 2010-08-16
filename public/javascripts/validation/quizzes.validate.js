$(document).ready(function() {
    $("#new_quiz, #edit_quiz").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#quiz_name').simplyCountable({
        counter: '#quiz_name_counter',
        countType: 'characters',
        maxCount: 100,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });


    $('#quiz_disabled_at').datepicker({
        changeMonth: true,
        changeYear: true 
    });
});