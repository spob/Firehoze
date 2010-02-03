$(document).ready(function() {
    $("#new_attachment, #edit_attachment").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    })

    $('#attachment_title').simplyCountable({
        counter: '#attachment_title_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});
