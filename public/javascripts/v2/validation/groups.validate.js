$(document).ready(function() {
    $(".new_group, .edit_group").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#group_name').simplyCountable({
        counter: '#group_name_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});